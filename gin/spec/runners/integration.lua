-- dep
local http = require 'socket.http'
local url = require 'socket.url'
local json = require 'cjson'
local ltn12 = require 'ltn12'

-- gin
local Gin = require 'gin.core.gin'
local Application = require 'config.application'


local IntegrationRunner = {}

-- Code portion taken from:
-- <https://github.com/keplerproject/cgilua/blob/master/src/cgilua/urlcode.lua>
function IntegrationRunner.encode_table(args)
    if args == nil or next(args) == nil then return "" end

    local strp = ""
    for key, vals in pairs(args) do
        if type(vals) ~= "table" then vals = {vals} end

        for i, val in ipairs(vals) do
            strp = strp .. "&" .. key .. "=" .. url.escape(val)
        end
    end

    return string.sub(strp, 2)
end

local function ensure_content_length(request)
    if request.headers == nil then request.headers = {} end
    if request.headers["content-length"] == nil and request.headers["Content-Length"] == nil then
        if request.body ~= nil then
            request.headers["Content-Length"] = request.body:len()
        else
            request.headers["Content-Length"] = 0
        end
    end
    return request
end

function IntegrationRunner.source_for_caller_at(i)
    return debug.getinfo(i).source
end

local function major_version_for_caller()
    local major_version
    -- limit to 10 stacktrace items
    for i = 1, 10 do
        -- local source = debug.getinfo(i).source
        local source = IntegrationRunner.source_for_caller_at(i)
        if source == nil then break end

        major_version = string.match(source, "controllers/(%d+)/(.*)_spec.lua")
        if major_version ~= nil then break end
    end
    if major_version == nil then error("Could not determine API major version from controller spec file. Ensure to follow naming conventions.") end

    return major_version
end

local function check_and_get_request_api_version(request, major_version)
    local api_version
    if request.api_version ~= nil and request.api_version ~= major_version then
        if string.match(request.api_version, major_version .. '%.') == nil then
            error("Specified API version " .. request.api_version .. " does not match controller spec namespace (" .. major_version .. ")")
        end
        api_version = request.api_version
    else
        api_version = major_version
    end

    return api_version
end

local function set_accept_header(request, api_version)
    request.headers["accept"] = nil
    request.headers["Accept"] = "application/vnd." .. Application.name .. ".v" .. api_version .. "+json"

    return request
end

local function hit_server(request)
    local full_url = url.build({
        scheme = 'http',
        host = '127.0.0.1',
        port = Gin.settings.port,
        path = request.path,
        query = IntegrationRunner.encode_table(request.uri_params)
    })

    local response_body = {}
    local ok, response_status, response_headers = http.request({
        method = request.method,
        url = full_url,
        source = ltn12.source.string(request.body),
        headers = request.headers,
        sink = ltn12.sink.table(response_body),
        redirect = false
    })

    response_body = table.concat(response_body, "")

    return ok, response_status, response_headers, response_body
end

function IntegrationRunner.hit(request)
    local launcher = require 'gin.cli.launcher'
    local ResponseSpec = require 'gin.spec.runners.response'

    -- convert body to JSON request
    if request.body ~= nil then
        request.body = json.encode(request.body)
    end

    -- ensure content-length is set
    request = ensure_content_length(request)

    -- get major version for caller
    local major_version = major_version_for_caller()

    -- check request.api_version
    local api_version = check_and_get_request_api_version(request, major_version)

    -- set Accept header
    request = set_accept_header(request, api_version)

    -- start nginx
    launcher.start(Gin.env)

    -- hit server
    local ok, response_status, response_headers, response_body = hit_server(request)

    -- stop nginx
    launcher.stop(Gin.env)

    if ok == nil then error("An error occurred while connecting to the test server.") end

    -- build response object and return
    local response = ResponseSpec.new({
        status = response_status,
        headers = response_headers,
        body = response_body
    })

    return response
end

return IntegrationRunner

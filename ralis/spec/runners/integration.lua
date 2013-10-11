local http = require 'socket.http'
local url = require 'socket.url'
local launcher = require 'ralis.cli.launcher'
local ResponseSpec = require 'ralis.spec.runners.response'

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

function IntegrationRunner.hit(request)
    -- build full url
    local full_url = url.build({
        scheme = 'http',
        host = '127.0.0.1',
        port = Ralis.settings.port,
        path = request.url,
        query = IntegrationRunner.encode_table(request.uri_params)
    })

    -- ensure content-length is set
    if request.headers == nil then request.headers = {} end
    if request.headers["content-length"] == nil and request.headers["Content-Length"] == nil then
        if request.body ~= nil then
            request.headers["content-length"] = request.body:len()
        end
    end

    -- get application name
    package.loaded['config.application'] = nil
    require 'config.application'

    -- get major version from caller, limit to 10 stacktrace items
    local major_version
    for i = 1, 10 do
        local source = debug.getinfo(i).source
        if source == nil then break end

        major_version = string.match(debug.getinfo(i).source, "controllers/(%d+)/(.*)_spec.lua")
        if major_version ~= nil then break end
    end
    if major_version == nil then error("Could not determine API major version from controller spec file. Ensure to follow naming conventions.") end

    -- check request.api_version
    local api_version
    if request.api_version ~= nil and request.api_version ~= major_version then
        if string.match(request.api_version, major_version .. '%.') == nil then
            error("Specified API version " .. request.api_version .. " does not match controller spec namespace (" .. major_version .. ")")
        end
        api_version = request.api_version
    else
        api_version = major_version
    end

    -- set Accept header
    request.headers["accept"] = nil
    request.headers["Accept"] = "application/vnd." .. Application.name .. ".v" .. api_version .. "+json"

    -- start nginx
    launcher.start()

    -- hit server
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

    -- stop nginx
    launcher.stop()

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

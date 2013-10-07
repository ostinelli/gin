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

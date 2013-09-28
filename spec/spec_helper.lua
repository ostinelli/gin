package.path = './?.lua;' .. package.path

require 'core/ralis'
Ralis.env = 'test'

local http = require 'socket.http'
local url = require 'socket.url'
local launcher = require 'cli/ralis_launcher'


SpecResponse = {}
SpecResponse.__index = SpecResponse

function SpecResponse.new(options)
    options = options or {}

    local instance = {
        status = options.status,
        headers = options.headers or {},
        body = options.body or "",
    }
    setmetatable(instance, SpecResponse)
    return instance
end

local SpecHelper = {}

-- Code portion taken from:
-- <https://github.com/keplerproject/cgilua/blob/master/src/cgilua/urlcode.lua>
function SpecHelper.encode_table(args)
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

function SpecHelper.hit(request)
    launcher.start()

    local full_url = url.build({
        scheme = 'http',
        host = '127.0.0.1',
        port = 7201,
        path = request.url,
        query = SpecHelper.encode_table(request.uri_params)
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

    launcher.stop()

    if ok == nil then error("An error occurred while connecting to the test server.") end

    local response = SpecResponse.new({
        status = response_status,
        headers = response_headers,
        body = response_body
    })

    return response
end

-- helpers
function hit(request)
    return SpecHelper.hit(request)
end

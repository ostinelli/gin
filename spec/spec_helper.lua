package.path = './?.lua;' .. package.path

local cjson = require 'cjson'
require 'urlcode'
local http = require 'socket.http'

require 'core/ralis'
Ralis.env = 'test'

local launcher = require 'cli/ralis_launcher'

local SpecHelper = {}

function SpecHelper.visit(method, relative_url, query, body, headers)
    launcher.start()

    local url = "http://127.0.0.1:7201" .. relative_url
    local response_body = {}

    local ok, response_status, response_headers = http.request({
        method = method,
        url = url,
        source = ltn12.source.string(body),
        headers = headers,
        sink = ltn12.sink.table(response_body),
        redirect = false
    })

    launcher.stop()

    if ok == nil then error("Received an invalid response from server.") end

    return response_status, response_headers, table.concat(response_body, "")
end

-- helpers
function visit(method, url, query, body)
    SpecHelper.visit(method, url, query, body)
end

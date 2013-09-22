
local cjson = require 'cjson'
local http = require 'socket.http'
local launcher = require 'cli/ralis_launcher'

local BASE_TEST_URL = "http://127.0.0.1:7201"

local Integration = {}

function Integration.hit()
    launcher.start()

    local url = BASE_TEST_URL .. relative_url
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

return Integration

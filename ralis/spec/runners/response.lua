local json = require 'cjson'


local ResponseSpec = {}
ResponseSpec.__index = ResponseSpec

function ResponseSpec.new(options)
    options = options or {}

    -- body
    local json_body = {}
    if options.body ~= nil then
        json_body = json.decode(options.body)
    end

    -- init instance
    local instance = {
        status = options.status,
        headers = options.headers or {},
        body = json_body,
    }
    setmetatable(instance, ResponseSpec)
    return instance
end

return ResponseSpec

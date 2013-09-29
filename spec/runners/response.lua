local ResponseSpec = {}
ResponseSpec.__index = ResponseSpec

function ResponseSpec.new(options)
    options = options or {}

    local instance = {
        status = options.status,
        headers = options.headers or {},
        body = options.body or "",
    }
    setmetatable(instance, ResponseSpec)
    return instance
end

return ResponseSpec

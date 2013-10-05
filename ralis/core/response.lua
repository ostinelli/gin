Response = {}
Response.__index = Response

function Response.new(options)
    options = options or {}

    local instance = {
        status = options.status,
        headers = options.headers or {},
        body = options.body,
    }
    setmetatable(instance, Response)
    return instance
end

return Response

Response = {}
Response.__index = Response

function Response.new(options)
    options = options or {}

    local instance = {
        method = options.method or 'GET',
        url = options.url or "/",
        query = options.query or {},
        headers = options.headers or {},
        body = options.body or "",
    }
    setmetatable(instance, Response)
    return instance
end

return Response

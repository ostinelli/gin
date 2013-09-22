local Request = {}
Request.__index = Request

function Request.new(options)
    options = options or {}

    local instance = {
        method = options.method or 'GET',
        url = options.url or "/",
        query = options.query or {},
        headers = options.headers or {},
        body = options.body or "",
    }
    setmetatable(instance, Request)
    return instance
end

return Request

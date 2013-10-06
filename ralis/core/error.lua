-- ensure global Errors is defined
Errors = Errors or {}

Error = {}
Error.__index = Error

function Error.new(code)
    local err = Errors[code]
    if err == nil then error("invalid error code") end

    local body = {
        code = code,
        message = err.message
    }

    local instance = {
        status = err.status,
        headers = err.headers or {},
        body = body,
    }
    setmetatable(instance, Error)
    return instance
end

return Error

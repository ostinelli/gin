local Controller = {}
Controller.__index = Controller

function Controller.new(request, params)
    params = params or {}

    local instance = {
        params = params,
        request = request
    }
    setmetatable(instance, Controller)
    return instance
end

function Controller:raise_error(code)
    error({ code = code })
end

return Controller

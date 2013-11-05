-- perf
local error = error
local setmetatable = setmetatable


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

function Controller:raise_error(code, custom_attrs)
    error({ code = code, custom_attrs = custom_attrs })
end

return Controller

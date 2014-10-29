-- perf
local error = error
local pairs = pairs
local setmetatable = setmetatable


local Controller = {}
Controller.__index = Controller

function Controller.new(request, params)
    local p = params or {}

    local instance = {
        params = p,
        request = request
    }
    return instance
end

function Controller:raise_error(code, custom_attrs)
    error({ code = code, custom_attrs = custom_attrs })
end

function Controller:accepted_params(param_filters, params)
    local accepted_params = {}
    for _, param in pairs(param_filters) do
        accepted_params[param] = params[param]
    end
    return accepted_params
end

return Controller

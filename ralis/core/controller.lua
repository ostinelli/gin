local Controller = {}
Controller.__index = Controller

function Controller.new(ngx, params)
    params = params or {}

    local instance = {
        ngx = ngx,
        params = params,
        request = Request.new(ngx)
    }
    setmetatable(instance, Controller)
    return instance
end

return Controller

local Controller = {}
Controller.__index = Controller

function Controller.new(ngx, params)
    local instance = {
        ngx = ngx,
        params = params,
        request = Request.new(ngx)
    }
    setmetatable(instance, Controller)
    return instance
end

return Controller

package.path = './app/controllers/?.lua;' .. package.path

-- init module dependencies
require 'ralis.core.ralis'

-- load modules
local routes = require 'config.routes'
local Controller = require 'ralis.core.controller'

-- init Router and set routes
local Router = {}
Router.dispatchers = routes.dispatchers

-- main handler function, called from nginx
function Router.handler(ngx)
    -- add headers
    ngx.header.content_type = 'application/json'
    ngx.header["X-Server"] = 'ralis/'.. Ralis.version;
    -- get routes
    local controller_name, action, params = Router.match(ngx)

    if controller_name then
        -- load matched controller
        local matched_controller = require(controller_name)
        -- create instance and set metatable
        local controller_instance = Controller.new(ngx, params)
        setmetatable(controller_instance, {__index = matched_controller})
        -- call action
        local result = controller_instance[action](controller_instance)
        -- set status
        ngx.status = controller_instance.response.status
        -- set headers
        for k, v in pairs(controller_instance.response.headers) do
            ngx.header[k] = v
        end
        -- print body
        ngx.print(JSON.encode(result))
    else
        -- 404
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end
end

-- match request to routes
function Router.match(ngx)
    local uri = ngx.var.uri
    local method = ngx.var.request_method

    for _, dispatcher in ipairs(Router.dispatchers) do
        if dispatcher[method] then -- avoid matching if method is not defined in dispatcher
            local match = { string.match(uri, dispatcher.pattern) }

            if #match > 0 then
                local params = {}
                for i, v in ipairs(match) do
                    if dispatcher[method].params[i] then
                        params[dispatcher[method].params[i]] = match[i]
                    else
                        table.insert(params, match[i])
                    end
                end

                return dispatcher[method].controller, dispatcher[method].action, params
            end
        end
    end
end

return Router

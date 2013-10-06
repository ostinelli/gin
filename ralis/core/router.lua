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
        Router.call_controller(ngx, controller_name, action, params)
    else
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

-- call the controller
function Router.call_controller(ngx, controller_name, action, params)
    -- load matched controller and set metatable
    local matched_controller = require(controller_name)
    setmetatable(matched_controller, { __index = Controller })
    -- create controller instance
    local controller_instance = Controller.new(ngx, params)

    -- call action
    local ok, result = pcall(function() return matched_controller[action](controller_instance) end)

    local status, headers, body

    if ok then
        -- successful
        status = controller_instance.response.status
        headers = controller_instance.response.headers
        body = JSON.encode(result)
    else
        -- controller raised an error
        local ok, err = pcall(function() return Error.new(result.code) end)

        if ok then
            -- API error
            status = err.status
            headers = err.headers
            body = JSON.encode(err.body)
        else
            -- another error, throw
            error(result)
        end
    end

    -- set status
    ngx.status = status
    -- set headers
    for k, v in pairs(headers) do
        ngx.header[k] = v
    end
    -- print body
    ngx.print(body)
end

return Router

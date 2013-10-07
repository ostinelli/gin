package.path = './app/controllers/?.lua;' .. package.path

-- init module dependencies
require 'ralis.core.ralis'

-- load modules
local routes = require 'config.routes'
local Controller = require 'ralis.core.controller'

-- init Router and set routes
local Router = {}
Router.dispatchers = routes.dispatchers

-- version header
local version_header = 'ralis/'.. Ralis.version

-- main handler function, called from nginx
function Router.handler(ngx)
    -- add headers
    ngx.header.content_type = 'application/json'
    ngx.header["X-Server"] = version_header;
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
    -- load matched controller and set metatable to new instance of controller
    local matched_controller = require(controller_name)
    local controller_instance = Controller.new(ngx, params)
    setmetatable(matched_controller, { __index = controller_instance })

    -- call action
    local ok, status_or_error, body, headers = pcall(function() return matched_controller[action](matched_controller) end)

    local response

    if ok then
        -- successful
        response = Response.new({ status = status_or_error, headers = headers, body = body })
    else
        -- controller raised an error
        local ok, err = pcall(function() return Error.new(status_or_error.code) end)

        if ok then
            -- API error
            response = Response.new({ status = err.status, headers = err.headers, body = err.body })
        else
            -- another error, throw
            error(status_or_error)
        end
    end

    -- set status
    ngx.status = response.status
    -- set headers
    for k, v in pairs(response.headers) do
        ngx.header[k] = v
    end
    -- encode body
    local json_body = JSON.encode(response.body)
    -- ensure content-length is set
    ngx.header["Content-Length"] = ngx.header["Content-Length"] or ngx.header["content-length"] or json_body:len()
    -- print body
    ngx.print(json_body)
end

return Router

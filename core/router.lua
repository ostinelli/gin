package.path = './app/controllers/?.lua;' .. package.path

local Router = {}

local routes = require('config/routes')
Router.dispatchers = routes.dispatchers


function Router.handler(ngx)
    ngx.header.content_type = 'application/json'

    controller_name, action, params = Router.match(ngx)

    if controller_name then
        local controller = require(controller_name)
        controller[action](ngx, params)
    else
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end
end

function Router.match(ngx)
    uri = ngx.var.uri
    method = ngx.var.request_method

    for _, dispatcher in ipairs(Router.dispatchers) do
        if dispatcher[method] then -- avoid matching if method is not defined
            match = { string.match(uri, dispatcher.pattern) }

            if #match > 0 then
                params = {}
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

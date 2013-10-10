package.path = './app/controllers/?.lua;' .. package.path

-- init module dependencies
require 'ralis.core.ralis'
local Controller = require 'ralis.core.controller'

-- load application routes
require 'config.routes'

-- init Router and set routes
local Router = {}

-- version header
local version_header = 'ralis/'.. Ralis.version

-- main handler function, called from nginx
function Router.handler(ngx)
    -- add headers
    ngx.header.content_type = 'application/json'
    ngx.header["X-Server"] = version_header;

    -- create request object
    local request = Request.new(ngx)

    -- get routes
    local controller_name, action, params = Router.match(request)

    if controller_name then
        local response = Router.call_controller(ngx, controller_name, action, params)
        Router.respond(ngx, response)
    else
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end
end

-- match request to routes
function Router.match(request)
    local uri = request.uri
    local method = request.method

    -- match version based on headers
    local headers = request.headers
    local major_version, rest_version = string.match(headers['accept'], "^application/vnd.myapp.v(%d+)(.*)+json")

    -- loop dispatchers to find route
    for _, dispatcher in ipairs(Routes.dispatchers[tonumber(major_version)]) do
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

                local version = major_version .. rest_version

                return major_version .. '/' .. dispatcher[method].controller, dispatcher[method].action, params, version
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

    return response
end

function Router.respond(ngx, response)
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

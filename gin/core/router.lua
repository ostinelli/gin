package.path = './app/controllers/?.lua;' .. package.path

-- dep
local json = require 'cjson'

-- gin
local Gin = require 'gin.core.gin'
local Controller = require 'gin.core.controller'
local Request = require 'gin.core.request'
local Response = require 'gin.core.response'
local Error = require 'gin.core.error'

-- app
local Routes = require 'config.routes'
local Application = require 'config.application'

-- perf
local error = error
local ipairs = ipairs
local jencode = json.encode
local pairs = pairs
local pcall = pcall
local require = require
local setmetatable = setmetatable
local smatch = string.match
local tinsert = table.insert


-- init Router and set routes
local Router = {}

-- response version header
local response_version_header = 'gin/'.. Gin.version

-- accept header for application
local accept_header_matcher = "^application/vnd." .. Application.name .. ".v(%d+)(.*)+json$"


local function create_request(ngx)
    local ok, request_or_error = pcall(function() return Request.new(ngx) end)
    if ok == false then
        -- parsing errors
        local response = Router.handle_error(request_or_error)
        Router.respond(ngx, response)
        return false
    end
    return request_or_error
end

-- main handler function, called from nginx
function Router.handler(ngx)
    -- add headers
    ngx.header.content_type = 'application/json'
    ngx.header["X-Framework"] = response_version_header;

    -- create request object
    local request = create_request(ngx)
    if request == false then return end

    -- get routes
    local ok, controller_name_or_error, action, params, request = pcall(function() return Router.match(request) end)

    local response

    if ok == false then
        -- match returned an error (for instance a 412 for no header match)
        response = Router.handle_error(controller_name_or_error)
        Router.respond(ngx, response)

    elseif controller_name_or_error then
        -- matching routes found
        response = Router.call_controller(request, controller_name_or_error, action, params)
        Router.respond(ngx, response)

    else
        -- no matching routes found
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end
end

-- match request to routes
function Router.match(request)
    local uri = request.uri
    local method = request.method

    -- match version based on headers
    if request.headers['accept'] == nil then error({ code = 100 }) end

    local major_version, rest_version = smatch(request.headers['accept'], accept_header_matcher)
    if major_version == nil then error({ code = 101 }) end

    local routes_dispatchers = Routes.dispatchers[tonumber(major_version)]
    if routes_dispatchers == nil then error({ code = 102 }) end

    -- loop dispatchers to find route
    for _, dispatcher in ipairs(routes_dispatchers) do
        if dispatcher[method] then -- avoid matching if method is not defined in dispatcher
            local match = { smatch(uri, dispatcher.pattern) }

            if #match > 0 then
                local params = {}
                for i, v in ipairs(match) do
                    if dispatcher[method].params[i] then
                        params[dispatcher[method].params[i]] = match[i]
                    else
                        tinsert(params, match[i])
                    end
                end

                -- set version on request
                request.api_version = major_version .. rest_version
                -- return
                return major_version .. '/' .. dispatcher[method].controller, dispatcher[method].action, params, request
            end
        end
    end
end

-- call the controller
function Router.call_controller(request, controller_name, action, params)
    -- load matched controller and set metatable to new instance of controller
    local matched_controller = require(controller_name)
    local controller_instance = Controller.new(request, params)
    setmetatable(matched_controller, { __index = controller_instance })

    local response

    -- look after default signals on matched controller
    local actions = {'before_action', action, 'after_action'}

    for index, action in ipairs(actions) do

        if matched_controller[action] ~= nil then
            -- call action
            local ok, status_or_error, body, headers = pcall(function() return matched_controller[action](matched_controller) end)

            if ok then
                -- successful
                response = Response.new({ status = status_or_error, headers = headers, body = body })
            else
                -- controller raised an error
                return Router.handle_error(status_or_error)
            end
        end
    end

    return response
end

function Router.handle_error(status_or_error)
  local response

  local ok, err = pcall(function() return Error.new(status_or_error.code, status_or_error.custom_attrs) end)

  if ok then
      -- API error
      response = Response.new({ status = err.status, headers = err.headers, body = err.body })
  else
      -- another error, throw
      error(status_or_error)
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
    local json_body = jencode(response.body)
    -- ensure content-length is set
    ngx.header["Content-Length"] = ngx.header["Content-Length"] or ngx.header["content-length"] or json_body:len()
    -- print body
    ngx.print(json_body)
end

return Router

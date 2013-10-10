--  versions
local Version = {}
Version.__index = Version

function Version.new(number)
    if type(number) ~= 'number' then error("version is not an integer number (got string).") end
    if string.match(tostring(number), "%.") ~= nil then error("version is not an integer number (got float).") end

    local instance = {
        number = number
    }
    setmetatable(instance, Version)
    return instance
end


function Version:add(method, pattern, route_info)
    local pattern, params = self:build_named_parameters(pattern)

    pattern = "^" .. pattern .. "/???$"

    route_info.controller = route_info.controller .. "_controller"
    route_info.params = params

    table.insert(Routes.dispatchers[self.number], { pattern = pattern, [method] = route_info })
end

function Version:build_named_parameters(pattern)
    local params = {}
    local new_pattern = string.gsub(pattern, "/:([A-Za-z0-9_]+)", function(m)
        table.insert(params, m)
        return "/([A-Za-z0-9_]+)"
    end)
    return new_pattern, params
end

local supported_http_methods = {
    GET = true,
    POST = true,
    HEAD = true,
    OPTIONS = true,
    PUT = true,
    PATCH = true,
    DELETE = true,
    TRACE = true,
    CONNECT = true
}

for http_method, _ in pairs(supported_http_methods) do
    Version[http_method] = function(self, pattern, route_info)
        self:add(http_method, pattern, route_info)
    end
end


--  global routes
Routes = {}
Routes.dispatchers = {}

function Routes.version(number)
    local version = Version.new(number)

    if Routes.dispatchers[number] then error("version has already been defined (got " .. number .. ").") end
    Routes.dispatchers[number] = {}

    return version
end

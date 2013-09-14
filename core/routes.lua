local Routes = {}
Routes.dispatchers = {}

-- format of dispatchers:
-- {
-- 	"$/users^": {
-- 		regex = regex,
-- 		GET = { controller = "users", action = "index", params = {} }
-- 	},
-- 	...
-- }

function Routes.get(pattern, route_info)
	Routes.dispatchers[pattern] = route_info
end

function Routes.add(method, pattern, route_info)
	pattern = "$" .. pattern .. "^"

	if Routes.dispatchers[pattern] == nil then
		Routes.dispatchers[pattern] = { regex = nil }
	end

	Routes.dispatchers[pattern][method] = {controller = "users", action = "index", params = {} }
end

return Routes

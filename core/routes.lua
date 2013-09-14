local Routes = {}
local route_dispatchers = {}

function Routes.get(pattern, route_info)
	route_dispatchers[pattern] = route_info
end

function Routes.dispatchers()
	return route_dispatchers
end

return Routes

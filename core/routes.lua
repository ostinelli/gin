local Routes = {}
Routes.dispatchers = {}


function Routes.get(pattern, route_info)
	Routes.dispatchers[pattern] = route_info
end

function Routes.add(method, pattern, route_info)
	pattern, params = Routes.build_named_parameters(pattern)

	pattern = "^" .. pattern .. "/?\\??$"

	if Routes.dispatchers[pattern] == nil then
		Routes.dispatchers[pattern] = {}
	end

	Routes.dispatchers[pattern][method] = route_info
	Routes.dispatchers[pattern][method].params = params
end

function Routes.build_named_parameters(pattern)
	params = {}
	new_pattern = string.gsub(pattern, "/:([A-Za-z_]+)", function(m)
		params[m] = nil
		return "/([^/]+)"
	end)
	return new_pattern, params
end


return Routes

local Routes = {}
Routes.dispatchers = {}

Routes.supported_http_methods = {
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

meta = {
	__index = function(_, method)
		if Routes.supported_http_methods[method] == nil then
			error("Unsupported HTTP method")
		end

		return function(pattern, route_info)
			Routes.add(method, pattern, route_info)
		end
	end
}
setmetatable(Routes, meta)

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

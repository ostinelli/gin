local M = {}

function M.routes(ngx)
	M.get("/users", { controller = "users", action = "index" })
end

function M.get(pattern, route_info)
	return 'ok'
end

return M

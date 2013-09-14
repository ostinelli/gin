package.path = './app/controllers/?.lua;' .. package.path

local Router = {}

function Router.handler(ngx)
	ngx.header.content_type = 'application/json'

	Router.build_routes(ngx)

	local controller = require 'users_controller'
	controller.index(ngx)
end

function Router.build_routes(ngx)
	local routes = require('app/routes')
	return routes.dispatchers
end

return Router

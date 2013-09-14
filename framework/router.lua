package.path = './app/?.lua;./app/controllers/?.lua;' .. package.path

local M = {}

function M.handler(ngx)
	ngx.header.content_type = 'application/json'

	local routes = require('routes')
	routes.routes(ngx)


	local controller = require 'users_controller'
	controller.index(ngx)
end


return M

package.path = './app/controllers/?.lua;' .. package.path
local utils = require('core/utils')

local Router = {}

local routes = require('app/routes')
Router.dispatchers = routes.dispatchers


function Router.handler(ngx)
	ngx.header.content_type = 'application/json'

	controller_name, action, params = Router.match(ngx)

	if controller_name then
		local controller = require(controller_name)
		controller[action](ngx, params)
	else
		ngx.exit(ngx.HTTP_NOT_FOUND)
	end
end

function Router.match(ngx)
	uri = ngx.var.uri
	-- method = ngx.req.get_method()

			-- ngx.error("URI", 'test')
			-- ngx.error("PATTERN", dispatcher.pattern)

	-- for _, dispatcher in ipairs(Router.dispatchers) do
	-- 	-- avoid matching if method is not defined
	-- 	if dispatcher[method] then
	-- 		ngx.error("URI", uri)
	-- 		ngx.error("PATTERN", dispatcher.pattern)
	-- 		match = utils.pack(string.match(uri, dispatcher.pattern))

	-- 		if #match > 0 then
	-- 			ngx.error("MATCH", match[1])
	-- 			-- match found"
	-- 			return dispatcher[method].controller,
	-- 				dispatcher[method].action
	-- 		end
	-- 	end
	-- end
	-- return "users_controller", "index"
end

return Router

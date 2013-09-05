package.path = './spec/?.lua;' .. package.path
require 'spec_helper'

describe(".dispatcher", function()
	before_each(function()
		router = require 'router'

		ngx = {
			var = {
				request_method = "",
				uri = ""
			},
				req = {
					get_uri_args = function() end,
					get_headers = function() end
				}
			}
	end)

	it("routes /users ", function()
		local routes = {
			["/users"] = {
				GET = { controller = "users", action = "index" }
			}
		}

		ngx.var.request_method = "GET"
		ngx.var.uri = "/users"
		dispatch_info = router.dispatcher(ngx, routes)

		assert.same(dispatch_info, { controller = "users", action = "index" })
	end)
end)

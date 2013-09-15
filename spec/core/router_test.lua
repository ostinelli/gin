require 'spec/spec_helper'

describe("Router", function()

	before_each(function()
		router = require 'core/router'
		router.dispatchers = {}
	end)

	after_each(function()
		package.loaded['core/router'] = nil
	end)

	describe(".match", function()
		before_each(function()
			-- set routes
			local routes = require('core/routes')

			routes.POST("/users", { controller = "users", action = "create" })
			routes.GET("/users", { controller = "users", action = "index" })
			routes.GET("/users/:id", { controller = "users", action = "show" })
			routes.PUT("/users/:id", { controller = "users", action = "edit" })

			router.dispatchers = routes.dispatchers
		end)

		it("returns the controller, action and params", function()
			ngx = {
				var = {
					uri = "/users/roberto",
					request_method = "GET"
				}
			}

			controller, action, params = router.match(ngx)

			assert.are.same("users_controller", controller)
			assert.are.same("show", action)
			assert.are.same({ id = "roberto" }, params)
		end)
	end)
end)

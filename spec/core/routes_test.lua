require 'spec/spec_helper'

describe("Routes", function()

	before_each(function()
		routes = require 'core/routes'
	end)

	after_each(function()
		package.loaded['core/routes'] = nil
	end)

	describe(".add", function()
		it("adds a simple route", function()
			routes.add('GET', "/users", { controller = "users", action = "index" })

			assert.are.same({
				[1] = {
					pattern = "^/users/?\\??$",
					GET = { controller = "users_controller", action = "index", params = {} }
				}
			}, routes.dispatchers)
		end)

		it("adds a named parameter route", function()
			routes.add('GET', "/users/:id", { controller = "users", action = "show" })

			assert.are.same({
				[1] = {
					pattern = "^/users/([^/]+)/?\\??$",
					GET = { controller = "users_controller", action = "show", params = { id = nil } }
				}
			}, routes.dispatchers)
		end)

		it("adds routes with multiple named parameters", function()
			routes.add('GET', "/users/:user_id/messages/:id", { controller = "messages", action = "show" })

			assert.are.same({
				[1] = {
					pattern = "^/users/([^/]+)/messages/([^/]+)/?\\??$",
					GET = { controller = "messages_controller", action = "show", params = { user_id = nil, id = nil } }
				}
			}, routes.dispatchers)
		end)

		it("add multiple routes", function()
			routes.add('GET', "/users", { controller = "users", action = "index" })
			routes.add('POST', "/users", { controller = "users", action = "create" })

			assert.are.same({
				[1] = {
					pattern = "^/users/?\\??$",
					GET = { controller = "users_controller", action = "index", params = {} }
				},
				[2] = {
					pattern = "^/users/?\\??$",
					POST = { controller = "users_controller", action = "create", params = {} }
				}
			}, routes.dispatchers)
		end)

		it("does not modify entered regexes", function()
			routes.add('PUT', "/users/:(.*)", { controller = "messages", action = "show" })

			assert.are.same({
				[1] = {
					pattern = "^/users/:(.*)/?\\??$",
					PUT = { controller = "messages_controller", action = "show", params = {} }
				}
			}, routes.dispatchers)
		end)
	end)

	describe("Helpers", function()

		before_each(function()
			spy.on(routes, 'add')
			t = { controller = "users", action = "index" }
		end)

		after_each(function()
			routes.add:revert()
		end)

		supported_http_methods = {
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

		for method, _ in pairs(supported_http_methods) do

			describe("." .. method, function()
				it("calls the .add method with ".. method, function()
					routes[method]("/users", t)
					assert.spy(routes.add).was_called_with(method, "/users", t)
				end)
			end)
		end
	end)
end)

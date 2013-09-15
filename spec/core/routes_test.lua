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
				["^/users/?\\??$"] = {
					GET = { controller = "users", action = "index", params = {} }
				}
			}, routes.dispatchers)
		end)

		it("adds a named parameter route", function()
			routes.add('POST', "/users/:id", { controller = "users", action = "show" })

			assert.are.same({
				["^/users/([^/]+)/?\\??$"] = {
					POST = { controller = "users", action = "show", params = { id = nil } }
				}
			}, routes.dispatchers)
		end)

		it("adds multiple named parameter routes", function()
			routes.add('POST', "/users/:user_id/messages/:id", { controller = "messages", action = "show" })

			assert.are.same({
				["^/users/([^/]+)/messages/([^/]+)/?\\??$"] = {
					POST = { controller = "messages", action = "show", params = { user_id = nil, id = nil } }
				}
			}, routes.dispatchers)
		end)

		it("does not modify entered regexes", function()
			routes.add('PUT', "/users/:(.*)", { controller = "messages", action = "show" })

			assert.are.same({
				["^/users/:(.*)/?\\??$"] = {
					PUT = { controller = "messages", action = "show", params = {} }
				}
			}, routes.dispatchers)
		end)
	end)
end)

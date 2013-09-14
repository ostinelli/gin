require 'spec/spec_helper'

describe("Routes", function()

	before_each(function()
		routes = require 'core/routes'
	end)

	describe(".add", function()
		it("adds a simple route", function()
			routes.add('GET', "/users", { controller = "users", action = "index" })

			assert.are.same({
				["$/users^"] = {
					regex = nil,
					GET = { controller = "users", action = "index", params = {} }
				}
			}, routes.dispatchers)
		end)
	end)
end)

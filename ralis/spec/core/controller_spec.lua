require 'ralis.spec.spec_helper'

local c = require 'ralis.core.controller'

describe("Controller", function()

    describe(".new", function()
        before_each(function()
            ngx = { req = {
                read_body = function() return end,
                get_body_data = function() return "request-body" end,
            } }
            params = {}
            controller = c.new(ngx, params)
        end)

        after_each(function()
            ngx = nil
            params = nil
            controller = nil
        end)

        it("creates a new instance of a controller with ngx and params", function()
            assert.are.equals(ngx, controller.ngx)
            assert.are.equals(params, controller.params)
        end)

        it("creates and initializes the controller's request object", function()
            assert.are.equals("request-body", controller.request.body)
        end)

        it("creates and initializes the controller's response object", function()
            assert.are.equals(200, controller.response.status)
            assert.are.same({}, controller.response.headers)
            assert.are.equals(nil, controller.response.body)
        end)
    end)
end)

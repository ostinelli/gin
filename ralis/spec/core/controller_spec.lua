require 'ralis.spec.spec_helper'

local c = require 'ralis.core.controller'

describe("Controller", function()
    before_each(function()
        ngx = {
            req = {
                read_body = function() return end,
                get_body_data = function() return "request-body" end,
            },
            var = {
                uri = "/uri",
                request_method = 'POST'
            }
        }
        params = {}
        controller = c.new(ngx, params)
    end)

    after_each(function()
        ngx = nil
        params = nil
        controller = nil
    end)

    describe(".new", function()
        it("creates a new instance of a controller with ngx and params", function()
            assert.are.equals(ngx, controller.ngx)
            assert.are.equals(params, controller.params)
        end)

        it("creates and initializes the controller's request object", function()
            assert.are.equals("request-body", controller.request.body)
        end)
    end)

    describe("#raise_error", function()
        it("raises an error with a code", function()
            ok, err = pcall(function() controller:raise_error(1000) end)

            assert.are.equal(false, ok)
            assert.are.equal(1000, err.code)
        end)
    end)
end)

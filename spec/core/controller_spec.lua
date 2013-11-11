require 'spec.spec_helper'

describe("Controller", function()
    before_each(function()
        Controller = require 'zebra.core.controller'
        Request = require 'zebra.core.request'

        ngx = {
            req = {
                read_body = function() return end,
                get_body_data = function() return '{"param":"value"}' end,
                get_headers = function() return {} end,
            },
            var = {
                uri = "/uri",
                request_method = 'POST'
            }
        }
        request = Request.new(ngx)
        params = {}
        controller = Controller.new(request, params)
    end)

    after_each(function()
        package.loaded['zebra.core.controller'] = nil
        package.loaded['zebra.core.request'] = nil
        ngx = nil
        request = nil
        params = nil
        controller = nil
    end)

    describe(".new", function()
        it("creates a new instance of a controller with request and params", function()
            assert.are.same(request, controller.request)
            assert.are.same(params, controller.params)
        end)

        it("creates and initializes the controller's request object", function()
            assert.are.same({ param = "value" }, controller.request.body)
        end)
    end)

    describe("#raise_error", function()
        it("raises an error with a code", function()
            ok, err = pcall(function() controller:raise_error(1000) end)

            assert.are.equal(false, ok)
            assert.are.equal(1000, err.code)
        end)

        it("raises an error with a code and custom attributes", function()
            local custom_attrs = { custom_attr_1 = "1", custom_attr_2 = "2" }
            ok, err = pcall(function() controller:raise_error(1000, custom_attrs) end)

            assert.are.equal(false, ok)
            assert.are.equal(1000, err.code)
            assert.are.same(custom_attrs, err.custom_attrs)
        end)
    end)
end)

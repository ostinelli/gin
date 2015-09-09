require 'spec.spec_helper'


describe("Controller", function()
    before_each(function()
        Controller = require 'gin.core.controller'
        Request = require 'gin.core.request'

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
        package.loaded['gin.core.controller'] = nil
        package.loaded['gin.core.request'] = nil
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
            local ok, err = pcall(function() controller:raise_error(1000) end)

            assert.are.equal(false, ok)
            assert.are.equal(1000, err.code)
        end)

        it("raises an error with a code and custom attributes", function()
            local custom_attrs = { custom_attr_1 = "1", custom_attr_2 = "2" }
            local ok, err = pcall(function() controller:raise_error(1000, custom_attrs) end)

            assert.are.equal(false, ok)
            assert.are.equal(1000, err.code)
            assert.are.same(custom_attrs, err.custom_attrs)
        end)
    end)

    describe("#accepted_params", function()
        it("keeps only the params specified in filters", function()
            local param_filters = { 'first_name', 'last_name', 'other_param' }
            params = {
                first_name = 'roberto',
                last_name = 'gin',
                injection_param = 4
            }

            local accepted_params = controller:accepted_params(param_filters, params)
            assert.are.same({
                first_name = 'roberto',
                last_name = 'gin'
            }, accepted_params)
        end)
    end)
end)

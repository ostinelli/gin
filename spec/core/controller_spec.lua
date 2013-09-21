require 'spec/spec_helper'

describe("Controller", function()

    before_each(function()
        controller = require 'core/controller'
    end)

    after_each(function()
        package.loaded['core/controller'] = nil
        controller = nil
    end)

    describe(".new", function()
        it("creates a new instance of a controller", function()
            ngx = {}
            params = {}
            local c = controller.new(ngx, params)

            assert.are.equals(ngx, c.ngx)
            assert.are.equals(params, c.params)
        end)
    end)
end)

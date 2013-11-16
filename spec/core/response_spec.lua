require 'spec.spec_helper'

-- gin
local Response = require 'gin.core.response'


describe("Response", function()
    describe(".new", function()
        describe("when no options are passed in", function()
            it("initializes an instance with defaults", function()
                local response = Response.new()

                assert.are.same(200, response.status)
                assert.are.same({}, response.headers)
                assert.are.same({}, response.body)
            end)
        end)

        describe("when options are passed in", function()
            it("saves them to the instance", function()
                local response = Response.new({
                    status = 403,
                    headers = { ["X-Custom"] = "custom" },
                    body = "The body."
                })

                assert.are.same(403, response.status)
                assert.are.same({ ["X-Custom"] = "custom" }, response.headers)
                assert.are.same("The body.", response.body)
            end)
        end)
    end)
end)
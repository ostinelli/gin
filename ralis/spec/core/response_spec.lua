require 'ralis.spec.spec_helper'

describe("Response", function()
    describe(".new", function()
        describe("when no options are passed in", function()
            it("initializes an instance with defaults", function()
                local response = Response.new()

                assert.are.same(nil, response.status)
                assert.are.same({}, response.headers)
                assert.are.same(nil, response.body)
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
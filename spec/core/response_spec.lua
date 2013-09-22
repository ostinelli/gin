require 'spec/spec_helper'

describe("Response", function()
    describe(".new", function()
        describe("when no options are passed in", function()
            it("initializes an instance with defaults", function()
                local response = require('core/response').new()

                assert.are.same('GET', response.method)
                assert.are.same("/", response.url)
                assert.are.same({}, response.query)
                assert.are.same({}, response.headers)
                assert.are.same("", response.body)
            end)
        end)

        describe("when options are passed in", function()
            it("saves them to the instance", function()
                local response = require('core/response').new({
                    method = 'PUT',
                    url = "/users",
                    query = { page = 2 },
                    headers = { ["X-Custom"] = "custom" },
                    body = "The body."
                })

                assert.are.same('PUT', response.method)
                assert.are.same("/users", response.url)
                assert.are.same({ page = 2 }, response.query)
                assert.are.same({ ["X-Custom"] = "custom" }, response.headers)
                assert.are.same("The body.", response.body)
            end)
        end)
    end)
end)

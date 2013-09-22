require 'spec/spec_helper'

describe("Request", function()
    describe(".new", function()
        describe("when no options are passed in", function()
            it("initializes an instance with defaults", function()
                local request = require('core/request').new()

                assert.are.same('GET', request.method)
                assert.are.same("/", request.url)
                assert.are.same({}, request.query)
                assert.are.same({}, request.headers)
                assert.are.same("", request.body)
            end)
        end)

        describe("when options are passed in", function()
            it("saves them to the instance", function()
                local request = require('core/request').new({
                    method = 'PUT',
                    url = "/users",
                    query = { page = 2 },
                    headers = { ["X-Custom"] = "custom" },
                    body = "The body."
                })

                assert.are.same('PUT', request.method)
                assert.are.same("/users", request.url)
                assert.are.same({ page = 2 }, request.query)
                assert.are.same({ ["X-Custom"] = "custom" }, request.headers)
                assert.are.same("The body.", request.body)
            end)
        end)
    end)
end)

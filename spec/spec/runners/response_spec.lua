require 'spec.spec_helper'

describe("ResponseSpec", function()
    before_each(function()
        ResponseSpec = require 'zebra.spec.runners.response'
    end)

    after_each(function()
        package.loaded['zebra.spec.runners.response'] = nil
        ResponseSpec = nil
    end)

    describe(".new", function()
        describe("when no options are passed in", function()
            it("initializes an instance with defaults", function()
                local response = ResponseSpec.new()

                assert.are.same(nil, response.status)
                assert.are.same({}, response.headers)
                assert.are.same({}, response.body)
            end)
        end)

        describe("when a blank body string is passed in", function()
            it("initializes an instance with defaults", function()
                local response = ResponseSpec.new({
                    body = ""
                })

                assert.are.same(nil, response.status)
                assert.are.same({}, response.headers)
                assert.are.same({}, response.body)
            end)
        end)

        describe("when options are passed in", function()
            it("saves them to the instance", function()
                local response = ResponseSpec.new({
                    status = 403,
                    headers = { ["X-Custom"] = "custom" },
                    body = '{"name":"zebra"}'
                })

                assert.are.same(403, response.status)
                assert.are.same({ ["X-Custom"] = "custom" }, response.headers)
                assert.are.same({ name = "zebra" }, response.body)
            end)
        end)
    end)
end)
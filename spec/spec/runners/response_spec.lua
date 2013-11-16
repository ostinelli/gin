require 'spec.spec_helper'


describe("ResponseSpec", function()
    before_each(function()
        ResponseSpec = require 'gin.spec.runners.response'
    end)

    after_each(function()
        package.loaded['gin.spec.runners.response'] = nil
        ResponseSpec = nil
    end)

    describe(".new", function()
        describe("when no options are passed in", function()
            it("initializes an instance with defaults", function()
                local response = ResponseSpec.new()

                assert.are.same(nil, response.status)
                assert.are.same({}, response.headers)
                assert.are.same({}, response.body)
                assert.are.same(nil, response.body_raw)
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
                assert.are.same("", response.body_raw)
            end)
        end)

        describe("when an html body string is passed in", function()
            it("initializes an instance with defaults", function()
                local response = ResponseSpec.new({
                    body = "<html><h1>404 Not Found</h1></html>"
                })

                assert.are.same(nil, response.status)
                assert.are.same({}, response.headers)
                assert.are.same(nil, response.body)
                assert.are.same("<html><h1>404 Not Found</h1></html>", response.body_raw)
            end)
        end)

        describe("when options are passed in", function()
            it("saves them to the instance", function()
                local response = ResponseSpec.new({
                    status = 403,
                    headers = { ["X-Custom"] = "custom" },
                    body = '{"name":"gin"}'
                })

                assert.are.same(403, response.status)
                assert.are.same({ ["X-Custom"] = "custom" }, response.headers)
                assert.are.same({ name = "gin" }, response.body)
                assert.are.same('{"name":"gin"}', response.body_raw)
            end)
        end)
    end)
end)
require 'spec.spec_helper'


describe("Error", function()
    before_each(function()
        Error = require 'gin.core.error'
    end)

    after_each(function()
        package.loaded['gin.core.error'] = nil
        Error = nil
    end)

    describe(".new", function()
        describe("when no matching error can be found", function()
            it("raises an error", function()
                local ok, err = pcall(function()
                    Error.new(9999)
                end)

                assert.are.equal(false, ok)

                local contains_error = string.match(err, "invalid error code") ~= nil
                assert.are.equal(true, contains_error)
            end)
        end)

        describe("when a matching error can be found", function()
            describe("when no custom attributes are passed in", function()
                describe("when headers are defined in Errors", function()
                    before_each(function()
                        Error.list = {
                            [1000] = {
                                status = 500,
                                headers = { ["X-Info"] = "additional-info"},
                                message = "Something bad happened here"
                            }
                        }
                    end)

                    it("sets the appropriate values", function()
                        local err = Error.new(1000)

                        local expected_body = {
                            code = 1000,
                            message = "Something bad happened here"
                        }

                        assert.are.equal(500, err.status)
                        assert.are.same({ ["X-Info"] = "additional-info"}, err.headers)
                        assert.are.same(expected_body, err.body)
                    end)
                end)

                describe("when headers are not defined in Errors", function()
                    before_each(function()
                        Error.list = {
                            [1000] = {
                                status = 500,
                                message = "Something bad happened here"
                            }
                        }
                    end)

                    it("sets the appropriate values", function()
                        local err = Error.new(1000)

                        local expected_body = {
                            code = 1000,
                            message = "Something bad happened here"
                        }

                        assert.are.equal(500, err.status)
                        assert.are.same({}, err.headers)
                        assert.are.same(expected_body, err.body)
                    end)
                end)
            end)

            describe("when custom attributes are passed in", function()
                before_each(function()
                    Error.list = {
                        [1000] = {
                            status = 500,
                            message = "Something bad happened here"
                        }
                    }
                end)

                it("adds them to the error", function()
                    local err = Error.new(1000, { custom_attr = "custom_value" })

                    local expected_body = {
                        code = 1000,
                        message = "Something bad happened here",
                        custom_attr = "custom_value"
                    }

                    assert.are.equal(500, err.status)
                    assert.are.same({}, err.headers)
                    assert.are.same(expected_body, err.body)
                end)
            end)
        end)
    end)
end)
require 'spec.spec_helper'

-- gin
local Request = require 'gin.core.request'


describe("Request", function()
    before_each(function()
        ngx = {
            var = {
                uri = "/uri",
                request_method = 'POST'
            },

            req = {
                read_body = function() return end,
                get_body_data = function() return nil end,
                get_uri_args = function() return { uri_param = '2' } end,
                get_headers = function() return { ["Content-Type"] = "application/json" } end,
                get_post_args = function() return { body_param = '2' } end
            }
        }
    end)

    after_each(function()
        ngx = nil
    end)

    describe("body", function()
        it("reads the body on init", function()
            spy.on(ngx.req, "read_body")
            local request = Request.new(ngx)

            assert.spy(ngx.req.read_body).was.called(1)

            ngx.req.read_body:revert()
        end)

        it("sets raw body to the returned value", function()
            ngx.req.get_body_data = function() return '{"param":"value"}' end
            local request = Request.new(ngx)

            assert.are.equal('{"param":"value"}', request.body_raw)
        end)

        describe("when body is a valid JSON", function()
            it("sets request body to a table", function()
                ngx.req.get_body_data = function() return '{"param":"value"}' end

                local request = Request.new(ngx)

                assert.are.same({ param = "value" }, request.body)
            end)
        end)

        describe("when body is nil", function()
            it("sets request body to nil", function()
                ngx.req.get_body_data = function() return nil end

                local request = Request.new(ngx)

                assert.are.same(nil, request.body)
            end)
        end)

        describe("when body is an invalid JSON", function()
            it("raises an error", function()
                ngx.req.get_body_data = function() return "not-json" end

                local ok, err = pcall(function() return Request.new(ngx) end)

                assert.are.equal(false, ok)
                assert.are.equal(103, err.code)
            end)
        end)

        describe("when body is not a JSON hash", function()
            it("raises an error", function()
                ngx.req.get_body_data = function() return'["one", "two"]' end

                local ok, err = pcall(function() return Request.new(ngx) end)

                assert.are.equal(false, ok)
                assert.are.equal(104, err.code)
            end)
        end)
    end)

    describe("common attributes", function()
        before_each(function()
            request = Request.new(ngx)
        end)

        after_each(function()
            request = nil
        end)

        it("returns nil for unset attrs", function()
            assert.are.same(nil, request.unexisting_attr)
        end)

        it("returns uri", function()
            assert.are.same('/uri', request.uri)
        end)

        it("returns method", function()
            assert.are.same('POST', request.method)
        end)

        it("returns uri_params", function()
            assert.are.same({ uri_param = '2' }, request.uri_params)
        end)

        it("returns headers", function()
            assert.are.same({ ["Content-Type"] = "application/json" }, request.headers)
        end)

        it("sets and returns api_version", function()
            request.api_version = '1.2'
            assert.are.same('1.2', request.api_version)
        end)
    end)
end)

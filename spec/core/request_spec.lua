require 'spec/spec_helper'

describe("Request", function()
    before_each(function()
        ngx = {
            req = {
                read_body = function() return "" end,
                get_uri_args = function() return { uri_param = '2' } end,
                get_headers = function() return { ["Content-Type"] = "application/json" } end,
                get_post_args = function() return { body_param = '2' } end
            }
        }
        request = Request.new(ngx)
    end)

    after_each(function()
        ngx = nil
        request = nil
    end)

    it("reads the body on init", function()
        spy.on(ngx.req, "read_body")
        local new_request = Request.new(ngx)

        assert.spy(ngx.req.read_body).was.called(1)

        ngx.req.read_body:revert()
    end)

    it("returns uri_params", function()
        assert.are.same({ uri_param = '2' }, request:uri_params())
    end)

    it("returns headers", function()
        assert.are.same({ ["Content-Type"] = "application/json" }, request:headers())
    end)

    it("returns post_params", function()
        assert.are.same({ body_param = '2' }, request:post_params())
    end)
end)

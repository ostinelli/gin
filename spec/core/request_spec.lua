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

            -- var = {
                -- content_length = "1000",
                -- content_type="text/html",
                -- filename="index.html",
                -- host="www.example.com",
                -- hostname="example",
                -- query_string="a=b&1=2",
                -- request_method="GET",
                -- schema="http",
                -- uri="/uri",
                -- http_user_agent="Chrome",
                -- http_referer="http://another.com",
                -- server_port=80
            -- }
            -- req = {
            --     get_headers=function() end,
            --     get_post_args=function() end,
            --     get_uri_args=function() end,
            --     read_body=function() end
            -- }
        -- }

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

    it("returns nil for unset attrs", function()
        assert.are.same(nil, request.unexisting_attr)
    end)

    it("returns uri_params", function()
        assert.are.same({ uri_param = '2' }, request.uri_params)
    end)

    it("returns headers", function()
        assert.are.same({ ["Content-Type"] = "application/json" }, request.headers)
    end)

    it("returns post_params", function()
        assert.are.same({ body_param = '2' }, request.post_params)
    end)
end)

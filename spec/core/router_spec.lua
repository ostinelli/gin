require 'spec.spec_helper'


describe("Router", function()
    before_each(function()
        -- stub application packages
        package.loaded['config.routes'] = {}
        Application = require 'config.application'

        Router = require 'gin.core.router'
        Routes = require 'gin.core.routes'
        Controller = require 'gin.core.controller'
        Request = require 'gin.core.request'

        ngx = {
            HTTP_NOT_FOUND = 404,
            exit = function(code) return end,
            print = function(print) return end,
            status = 200,
            header = {},
            req = {
                read_body = function() return end,
                get_body_data = function() return end,
                get_headers = function() return end,
            },
            var = {
                uri = "/users",
                request_method = 'GET'
            }
        }
    end)

    after_each(function()
        package.loaded['config.routes'] = nil
        Application = nil

        package.loaded['gin.core.router'] = nil
        package.loaded['gin.core.routes'] = nil
        package.loaded['gin.core.controller'] = nil
        package.loaded['gin.core.request'] = nil

        Router = nil
        Routes = nil
        Controller = nil
        Request = nil

        ngx = nil
    end)

    describe(".handler", function()

        describe("when a request error is raised", function()
            before_each(function()
                Request.new = function(_) error({ code = 104, custom_attrs = { custom_attr = "custom_attr_value" } }) end
            end)

            it("responds with an error response", function()
                local arg_ngx, arg_response
                Router.respond = function(...) arg_ngx, arg_response = ... end

                Router.handler(ngx)

                assert.are.same(arg_ngx, ngx)
                assert.are.same(104, arg_response.body.code)
                assert.are.same("custom_attr_value", arg_response.body.custom_attr)
            end)
        end)

        it("calls the router match", function()
            local arg_request
            Router.match = function(...) arg_request = ... end

            Router.handler(ngx)

            assert.are.same(arg_request, Request.new(ngx))
        end)

        describe("when the router match returns an error", function()
            before_each(function()
                Router.match = function(req) error({ code = 100, custom_attrs = { custom_attr = "custom_attr_value" } }) end
            end)

            it("responds with an error response", function()
                local arg_ngx, arg_response
                Router.respond = function(...) arg_ngx, arg_response = ... end

                Router.handler(ngx)

                assert.are.same(arg_ngx, ngx)
                assert.are.same(100, arg_response.body.code)
                assert.are.same("custom_attr_value", arg_response.body.custom_attr)
            end)
        end)

        describe("when a router match does not find a matching API", function()
            before_each(function()
                Router.match = function(req) return end
            end)

            it("raises a 404 error if no match is found", function()
                stub(ngx, 'exit')

                Router.handler(ngx)

                assert.stub(ngx.exit).was.called_with(ngx.HTTP_NOT_FOUND)

                ngx.exit:revert()
            end)
        end)

        describe("when a router match is found", function()
            before_each(function()
                request = Request.new(ngx)
                Router.match = function(req) return "controller_name", "action", "params", request end
            end)

            after_each(function()
                request = nil
            end)

            it("calls controller", function()
                stub(Router, 'respond') -- stub to avoid calling the function

                local arg_request, arg_controller_name, arg_action, arg_params
                Router.call_controller = function(...) arg_request, arg_controller_name, arg_action, arg_params = ... end

                Router.handler(ngx)

                assert.are.same(ngx, arg_request.ngx)
                assert.are.same("/users", arg_request.uri)
                assert.are.same('GET', arg_request.method)

                assert.are.equal("controller_name", arg_controller_name)
                assert.are.equal("action", arg_action)
                assert.are.equal("params", arg_params)

                Router.respond:revert()
            end)

            it("responds with the response", function()
                Router.call_controller = function() return "response" end

                stub(Router, 'respond')

                Router.handler(ngx)

                assert.stub(Router.respond).was.called_with(ngx, "response")
            end)
        end)
    end)

    describe(".call_controller", function()
        before_each(function()
            Error.list = {
                [1000] = {
                    status = 500,
                    headers = { ["X-Info"] = "additional-info"},
                    message = "Something bad happened here"
                }
            }

            instance = {} -- we're going to set self to instance so we can assert on it
            TestController = {}
            function TestController:action()
                instance = self
            end
            package.loaded['controller_name'] = TestController
        end)

        after_each(function()
            instance = nil
            TestController = nil
            package.loaded['controller_name'] = nil
        end)

        it("calls the action of an instance of the matched controller name", function()
            spy.on(TestController, 'action')

            local request = Request.new(ngx)
            Router.call_controller(request, "controller_name", "action", "params")

            assert.spy(TestController.action).was.called()

            -- assert the instance was initialized with the correct arguments
            assert.are.same(request, instance.request)
            assert.are.same("params", instance.params)

            TestController.action:revert()
        end)

        describe("when the controller successfully returns", function()
            describe("when the controller only returns the status code", function()
                before_each(function()
                    TestController = {}
                    function TestController:action()
                        return 403
                    end
                    package.loaded['controller_name'] = TestController
                end)

                it("returns a response with the status", function()
                    local response = Router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.equal(403, response.status)
                end)

                it("returns a response with the body to an empty json", function()
                    local response = Router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.same({}, response.body)
                end)
            end)

            describe("when the controller returns the status code and the body", function()
                before_each(function()
                    TestController = {}
                    function TestController:action()
                        return 403, { name = 'gin' }
                    end
                    package.loaded['controller_name'] = TestController
                end)

                it("sets the response response status to the controller's response status", function()
                    local response = Router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.equal(403, response.status)
                end)

                it("calls nginx with the serialized json of the controller response body", function()
                    local response = Router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.same({ name = 'gin' }, response.body)
                end)
            end)

            describe("when the controller returns the status code, the body and headers", function()
                before_each(function()
                    TestController = {}
                    function TestController:action()
                        local headers = { ["Cache-Control"] = "max-age=3600", ["Retry-After"] = "120" }
                        return 403, { name = 'gin' }, headers
                    end
                    package.loaded['controller_name'] = TestController
                end)

                it("sets the response status to the controller's response status", function()
                    local response = Router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.equal(403, response.status)
                end)

                it("calls nginx with the serialized json of the controller response body", function()
                    local response = Router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.same({ name = 'gin' }, response.body)
                end)

                it("sets the nginx response headers", function()
                    local response = Router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.equal("max-age=3600", response.headers["Cache-Control"])
                    assert.are.equal("120", response.headers["Retry-After"])
                end)
            end)
        end)

        describe("when the controller raises an API error", function()
            before_each(function()
                TestController = {}
                function TestController:action()
                    self:raise_error(1000, { additional_info = "some-info" })
                    return { name = 'gin' }
                end
                package.loaded['controller_name'] = TestController
            end)

            it("sets the response status to the controller's error status", function()
                local response = Router.call_controller(ngx, "controller_name", "action", "params")

                assert.are.equal(500, response.status)
            end)

            it("sets the response headers", function()
                local response = Router.call_controller(ngx, "controller_name", "action", "params")

                assert.are.equal("additional-info", response.headers["X-Info"])
            end)

            it("calls nginx with the serialized json of the controller response", function()
                local response = Router.call_controller(ngx, "controller_name", "action", "params")

                assert.are.same({
                    code = 1000,
                    message = "Something bad happened here",
                    additional_info = "some-info"
                }, response.body)
            end)
        end)

        describe("when the controller raises an API error", function()
            before_each(function()
                TestController = {}
                function TestController:action()
                    error("blew up!")
                end
                package.loaded['controller_name'] = TestController
            end)

            it("doesn't eat up the error", function()
                local ok, err = pcall(function()
                    Router.call_controller(ngx, "controller_name", "action", "params")
                end)

                assert.are.equal(false, ok)

                local contains_error = string.match(err, "blew up!") ~= nil
                assert.are.equal(true, contains_error)
            end)
        end)
    end)

    describe(".match", function()
        before_each(function()
            -- set routes
            local Routes = require 'gin.core.routes'

            local v1 = Routes.version(1)

            v1:POST("/users", { controller = "users", action = "create" })
            v1:GET("/users", { controller = "users", action = "index" })
            v1:GET("/users/:id", { controller = "users", action = "show" })
            v1:PUT("/users/:id", { controller = "users", action = "edit" })

            local v2 = Routes.version(2)
            v2:DELETE("/users/:user_id/messages/:id", { controller = "messages", action = "destroy" })

            package.loaded['config.routes'] = Routes

            package.loaded['gin.core.router'] = nil
            Router = require 'gin.core.router'
        end)

        after_each(function()
            package.loaded['config.routes'] = {}
        end)

        it("returns the controller, action and params for a single param", function()
            ngx.var.uri = "/users/roberto"
            ngx.var.request_method = "GET"
            ngx.req.get_headers = function() return { ['accept'] = "application/vnd." .. Application.name .. ".v1+json" } end

            local request = Request.new(ngx)

            controller, action, params, request = Router.match(request)

            assert.are.same("1/users_controller", controller)
            assert.are.same("show", action)
            assert.are.same({ id = "roberto" }, params)
            assert.are.same('1', request.api_version)
        end)

        it("returns the controller, action and params for a multiple params", function()
            ngx.var.uri = "/users/roberto/messages/123"
            ngx.var.request_method = "DELETE"
            ngx.req.get_headers = function() return { ['accept'] = "application/vnd." .. Application.name .. ".v2.1-p3+json" } end

            local request = Request.new(ngx)

            controller, action, params, version = Router.match(request)

            assert.are.same("2/messages_controller", controller)
            assert.are.same("destroy", action)
            assert.are.same({ user_id = "roberto", id = "123" }, params)
            assert.are.same('2.1-p3', request.api_version)
        end)

        it("raises an error if an Accept header is not set", function()
            ngx.req.get_headers = function() return {} end

            local request = Request.new(ngx)

            local ok, err = pcall(function() return Router.match(request) end)

            assert.are.equal(false, ok)
            assert.are.equal(100, err.code)
        end)

        it("raises an error if an Accept header set does not match the appropriate vendor format", function()
            ngx.req.get_headers = function() return { ['accept'] = "application/vnd.other.v1+json" } end

            local request = Request.new(ngx)

            local ok, err = pcall(function() return Router.match(request) end)

            assert.are.equal(false, ok)
            assert.are.equal(101, err.code)
        end)

        it("raises an error if an Accept header corresponds to an unsupported version", function()
            ngx.req.get_headers = function() return { ['accept'] = "application/vnd." .. Application.name .. ".v3+json" } end

            local request = Request.new(ngx)

            local ok, err = pcall(function() return Router.match(request) end)

            assert.are.equal(false, ok)
            assert.are.equal(102, err.code)
        end)
    end)

    describe(".respond", function()
        before_each(function()
            local Response = require 'gin.core.response'
            response = Response.new({
                status = 200,
                headers = { ['one'] = 'first', ['two'] = 'second' },
                body = { name = 'gin'}
            })
        end)

        it("sets the ngx status", function()
            Router.respond(ngx, response)

            assert.are.equal(200, ngx.status)
        end)

        it("sets the ngx headers", function()
            Router.respond(ngx, response)

            assert.are.equal('first', ngx.header['one'])
            assert.are.equal('second', ngx.header['two'])
        end)

        it("sets the content length header", function()
            Router.respond(ngx, response)

            assert.are.equal(14, ngx.header['Content-Length'])
        end)

        it("calls ngx print with the encoded body", function()
            stub(ngx, 'print')

            Router.respond(ngx, response)

            assert.stub(ngx.print).was_called_with('{"name":"gin"}')
        end)
    end)
end)

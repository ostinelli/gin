require 'ralis.spec.spec_helper'

describe("Router", function()
    before_each(function()
        package.loaded['config.routes'] = {}    -- stub the real routes loading
        router = require 'ralis.core.router'
        routes = require 'ralis.core.routes'
        Controller = require 'ralis.core.controller'
        ngx = {
            HTTP_NOT_FOUND = 404,
            exit = function(code) return end,
            print = function(print) return end,
            status = 200,
            header = { content_type = '' },
            req = {
                read_body = function() return end,
                get_body_data = function() return end
            }
        }
    end)

    after_each(function()
        package.loaded['ralis.core.router'] = nil
        package.loaded['ralis.core.routes'] = nil
        package.loaded['ralis.core.controller'] = nil
        router = nil
        routes = nil
        Controller = nil
        ngx = nil
    end)

    describe(".handler", function()
        describe("when no match is found", function()
            before_each(function()
                router.match = function(ngx) return end
            end)

            it("raises a 404 error if no match is found", function()
                stub(ngx, 'exit')

                router.handler(ngx)

                assert.stub(ngx.exit).was.called_with(ngx.HTTP_NOT_FOUND)

                ngx.exit:revert()
            end)
        end)

        describe("when a match is found", function()
            before_each(function()
                router.match = function(ngx) return "controller_name", "action", "params" end
            end)

            it("calls controller", function()
                stub(router, "call_controller")

                router.handler(ngx)

                assert.stub(router.call_controller).was.called_with(ngx, "controller_name", "action", "params")

                router.call_controller:revert()
            end)
        end)
    end)

    describe(".call_controller", function()
        before_each(function()
            original_errors = Errors
            Errors = {
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
            Errors = original_errors
        end)

        it("calls the action of an instance of the matched controller name", function()
            spy.on(TestController, 'action')

            router.call_controller(ngx, "controller_name", "action", "params")

            assert.spy(TestController.action).was.called()

            -- assert the instance was initialized with the correct arguments
            assert.are.same(ngx, instance.ngx)
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

                it("sets the nginx response status to the controller's response status", function()
                    router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.equal(403, ngx.status)
                end)

                it("sets the content-length header", function()
                    router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.equal(2, ngx.header["Content-Length"])
                end)

                it("sets the body to an empty json", function()
                    stub(ngx, 'print')

                    router.call_controller(ngx, "controller_name", "action", "params")

                    assert.stub(ngx.print).was.called_with('{}')

                    ngx.print:revert()
                end)
            end)

            describe("when the controller returns the status code and the body", function()
                before_each(function()
                    TestController = {}
                    function TestController:action()
                        return 403, { name = 'ralis' }
                    end
                    package.loaded['controller_name'] = TestController
                end)

                it("sets the nginx response status to the controller's response status", function()
                    router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.equal(403, ngx.status)
                end)

                it("sets the content-length header", function()
                    router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.equal(16, ngx.header["Content-Length"])
                end)

                it("calls nginx with the serialized json of the controller response body", function()
                    stub(ngx, 'print')

                    router.call_controller(ngx, "controller_name", "action", "params")

                    assert.stub(ngx.print).was.called_with('{"name":"ralis"}')

                    ngx.print:revert()
                end)
            end)

            describe("when the controller returns the status code, the body and headers", function()
                before_each(function()
                    TestController = {}
                    function TestController:action()
                        local headers = { ["Cache-Control"] = "max-age=3600", ["Retry-After"] = "120" }
                        return 403, { name = 'ralis' }, headers
                    end
                    package.loaded['controller_name'] = TestController
                end)

                it("sets the nginx response status to the controller's response status", function()
                    router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.equal(403, ngx.status)
                end)

                it("calls nginx with the serialized json of the controller response body", function()
                    stub(ngx, 'print')

                    router.call_controller(ngx, "controller_name", "action", "params")

                    assert.stub(ngx.print).was.called_with('{"name":"ralis"}')

                    ngx.print:revert()
                end)

                it("sets the nginx response headers", function()
                    router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.equal(16, ngx.header["Content-Length"])
                    assert.are.equal("max-age=3600", ngx.header["Cache-Control"])
                    assert.are.equal("120", ngx.header["Retry-After"])
                end)
            end)
        end)

        describe("when the controller raises an API error", function()
            before_each(function()
                TestController = {}
                function TestController:action()
                    self:raise_error(1000)
                    return { name = 'ralis' }
                end
                package.loaded['controller_name'] = TestController
            end)

            it("sets the nginx response status to the controller's error status", function()
                router.call_controller(ngx, "controller_name", "action", "params")

                assert.are.equal(500, ngx.status)
            end)

            it("sets the nginx response headers", function()
                router.call_controller(ngx, "controller_name", "action", "params")

                assert.are.equal("additional-info", ngx.header["X-Info"])
            end)

            it("calls nginx with the serialized json of the controller response", function()
                stub(ngx, 'print')

                router.call_controller(ngx, "controller_name", "action", "params")

                assert.stub(ngx.print).was.called_with('{"code":1000,"message":"Something bad happened here"}')

                ngx.print:revert()
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
                ok, err = pcall(function()
                    router.call_controller(ngx, "controller_name", "action", "params")
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
            routes.POST("/users", { controller = "users", action = "create" })
            routes.GET("/users", { controller = "users", action = "index" })
            routes.GET("/users/:id", { controller = "users", action = "show" })
            routes.PUT("/users/:id", { controller = "users", action = "edit" })
            routes.DELETE("/users/:user_id/messages/:id", { controller = "messages", action = "destroy" })

            router.dispatchers = routes.dispatchers
        end)

        it("returns the controller, action and params for a single param", function()
            ngx = {
                var = {
                    uri = "/users/roberto",
                    request_method = "GET"
                }
            }

            controller, action, params = router.match(ngx)

            assert.are.same("users_controller", controller)
            assert.are.same("show", action)
            assert.are.same({ id = "roberto" }, params)
        end)

        it("returns the controller, action and params for a multiple params", function()
            ngx = {
                var = {
                    uri = "/users/roberto/messages/123",
                    request_method = "DELETE"
                }
            }

            controller, action, params = router.match(ngx)

            assert.are.same("messages_controller", controller)
            assert.are.same("destroy", action)
            assert.are.same({ user_id = "roberto", id = "123" }, params)
        end)
    end)
end)

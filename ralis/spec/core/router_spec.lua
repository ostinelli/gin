require 'ralis.spec.spec_helper'

describe("Router", function()
    before_each(function()
        package.loaded['config.routes'] = {}    -- stub the real routes loading
        router = require 'ralis.core.router'
        require 'ralis.core.routes'
        Controller = require 'ralis.core.controller'
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
                request_method = "GET"
            }
        }
    end)

    after_each(function()
        package.loaded['ralis.core.router'] = nil
        package.loaded['ralis.core.routes'] = nil
        Routes = nil
        package.loaded['ralis.core.controller'] = nil
        router = nil
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
                stub(router, 'respond') -- stub to avoid calling the function
                stub(router, "call_controller")

                router.handler(ngx)

                assert.stub(router.call_controller).was.called_with(ngx, "controller_name", "action", "params")

                router.call_controller:revert()
                router.respond:revert()
            end)

            it("responds with the response", function()
                router.call_controller = function() return "response" end

                stub(router, 'respond')

                router.handler(ngx)

                assert.stub(router.respond).was.called_with(ngx, "response")
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

                it("returns a response with the status", function()
                    local response = router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.equal(403, response.status)
                end)

                it("returns a response with the body to an empty json", function()
                    local response = router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.same({}, response.body)
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

                it("sets the response response status to the controller's response status", function()
                    local response = router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.equal(403, response.status)
                end)

                it("calls nginx with the serialized json of the controller response body", function()
                    local response = router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.same({ name = 'ralis' }, response.body)
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

                it("sets the response status to the controller's response status", function()
                    local response = router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.equal(403, response.status)
                end)

                it("calls nginx with the serialized json of the controller response body", function()
                    local response = router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.same({ name = 'ralis' }, response.body)
                end)

                it("sets the nginx response headers", function()
                    local response = router.call_controller(ngx, "controller_name", "action", "params")

                    assert.are.equal("max-age=3600", response.headers["Cache-Control"])
                    assert.are.equal("120", response.headers["Retry-After"])
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

            it("sets the response status to the controller's error status", function()
                local response = router.call_controller(ngx, "controller_name", "action", "params")

                assert.are.equal(500, response.status)
            end)

            it("sets the response headers", function()
                local response = router.call_controller(ngx, "controller_name", "action", "params")

                assert.are.equal("additional-info", response.headers["X-Info"])
            end)

            it("calls nginx with the serialized json of the controller response", function()
                local response = router.call_controller(ngx, "controller_name", "action", "params")

                assert.are.same({ code = 1000, message = "Something bad happened here" }, response.body)
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
            local v1 = Routes.version(1)

            v1:POST("/users", { controller = "users", action = "create" })
            v1:GET("/users", { controller = "users", action = "index" })
            v1:GET("/users/:id", { controller = "users", action = "show" })
            v1:PUT("/users/:id", { controller = "users", action = "edit" })

            local v2 = Routes.version(2)

            v2:DELETE("/users/:user_id/messages/:id", { controller = "messages", action = "destroy" })
        end)

        it("returns the controller, action and params for a single param", function()
            ngx.var.uri = "/users/roberto"
            ngx.var.request_method = "GET"
            ngx.req.get_headers = function() return { ['accept'] = "application/vnd.myapp.v1+json" } end

            local request = Request.new(ngx)

            controller, action, params, version = router.match(request)

            assert.are.same("1/users_controller", controller)
            assert.are.same("show", action)
            assert.are.same({ id = "roberto" }, params)
            assert.are.same('1', version)
        end)

        it("returns the controller, action and params for a multiple params", function()
            ngx.var.uri = "/users/roberto/messages/123"
            ngx.var.request_method = "DELETE"
            ngx.req.get_headers = function() return { ['accept'] = "application/vnd.myapp.v2.1-p3+json" } end

            local request = Request.new(ngx)

            controller, action, params, version = router.match(request)

            assert.are.same("2/messages_controller", controller)
            assert.are.same("destroy", action)
            assert.are.same({ user_id = "roberto", id = "123" }, params)
            assert.are.same('2.1-p3', version)
        end)

        it("returns a 412 if an Accept header is not set", function()
                -- PENDING

        end)

        it("returns a 412 if an Accept header set does not match the appropriate vendor format", function()
                -- PENDING

        end)

        it("returns a 412 if an Accept header corresponds to an unsupported version", function()
                -- PENDING

        end)
    end)

    describe(".respond", function()
        before_each(function()
            response = Response.new({
                status = 200,
                headers = { ['one'] = 'first', ['two'] = 'second' },
                body = { name = 'ralis'}
            })
        end)

        it("sets the ngx status", function()
            router.respond(ngx, response)

            assert.are.equal(200, ngx.status)
        end)

        it("sets the ngx headers", function()
            router.respond(ngx, response)

            assert.are.equal('first', ngx.header['one'])
            assert.are.equal('second', ngx.header['two'])
        end)

        it("sets the content length header", function()
            router.respond(ngx, response)

            assert.are.equal(16, ngx.header['Content-Length'])
        end)

        it("calls ngx print with the encoded body", function()
            stub(ngx, 'print')

            router.respond(ngx, response)

            assert.stub(ngx.print).was_called_with('{"name":"ralis"}')
        end)
    end)
end)

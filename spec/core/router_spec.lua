require 'spec/spec_helper'

describe("Router", function()

    before_each(function()
        router = require 'core/router'
        routes = require 'core/routes'
        router.dispatchers = {}
    end)

    after_each(function()
        package.loaded['core/router'] = nil
        package.loaded['core/routes'] = nil
        router = nil
        routes = nil
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

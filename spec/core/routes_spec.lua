require 'spec.spec_helper'


describe("Routes", function()

    before_each(function()
        Routes = require('gin.core.routes')
    end)

    after_each(function()
        package.loaded['gin.core.routes'] = nil
        Routes = nil
    end)

    describe(".version", function()
        describe("when it's a string", function()
            it("raises an error", function()
                local ok, err = pcall(function() return Routes.version("1") end)

                assert.are.equal(false, ok)
                assert.are.same(true, string.find(err, "version is not an integer number %(got string%)") > 0)
            end)
        end)

        describe("when it's a float", function()
            it("raises an error", function()
                local ok, err = pcall(function() return Routes.version(1.2) end)

                assert.are.equal(false, ok)
                assert.are.same(true, string.find(err, "version is not an integer number %(got float%).") > 0)
            end)
        end)

        describe("when it's an integer", function()
            it("sets the dispatcher key and returns a version object", function()
                local version = Routes.version(1)

                assert.are.same({ [1] = {} }, Routes.dispatchers)
                assert.are.same(1, version.number)
            end)
        end)

        describe("when a version has already been created", function()
            it("returns an error", function()
                local version = Routes.version(1)


                local ok, err = pcall(function() return Routes.version(1) end)

                assert.are.equal(false, ok)
                assert.are.same(true, string.find(err, "version has already been defined %(got 1%).") > 0)
            end)
        end)

        describe("when another version gets created", function()
            it("sets the dispatcher keys", function()
                local version_1 = Routes.version(1)
                local version_2 = Routes.version(2)
                assert.are.same({ [1] = {}, [2] = {} }, Routes.dispatchers)
            end)
        end)
    end)

    describe("Adding routes", function()
        before_each(function()
            version = Routes.version(1)
        end)

        after_each(function()
            version = nil
        end)

        describe(".add", function()
            it("adds a simple route", function()
                version:add('GET', "/users", { controller = "users", action = "index" })

                assert.are.same({
                    [1] = {
                        [1] = {
                            pattern = "^/users/???$",
                            GET = { controller = "users_controller", action = "index", params = {} }
                        }
                    }
                }, Routes.dispatchers)
            end)

            it("adds a named parameter route", function()
                version:add('GET', "/users/:id", { controller = "users", action = "show" })

                assert.are.same({
                    [1] = {
                        [1] = {
                            pattern = "^/users/([A-Za-z0-9_]+)/???$",
                            GET = { controller = "users_controller", action = "show", params = { [1] = "id" } }
                        }
                    }
                }, Routes.dispatchers)
            end)

            it("adds routes with multiple named parameters", function()
                version:add('GET', "/users/:user_id/messages/:id", { controller = "messages", action = "show" })

                assert.are.same({
                    [1] = {
                        [1] = {
                            pattern = "^/users/([A-Za-z0-9_]+)/messages/([A-Za-z0-9_]+)/???$",
                            GET = { controller = "messages_controller", action = "show", params = { [1] = "user_id", [2] = "id" } }
                        }
                    }
                }, Routes.dispatchers)
            end)

            it("add multiple routes", function()
                version:add('GET', "/users", { controller = "users", action = "index" })
                version:add('POST', "/users", { controller = "users", action = "create" })

                assert.are.same({
                    [1] = {
                        [1] = {
                            pattern = "^/users/???$",
                            GET = { controller = "users_controller", action = "index", params = {} }
                        },
                        [2] = {
                            pattern = "^/users/???$",
                            POST = { controller = "users_controller", action = "create", params = {} }
                        }
                    }
                }, Routes.dispatchers)
            end)

            it("does not modify entered regexes", function()
                version:add('PUT', "/users/:(.*)", { controller = "messages", action = "show" })

                assert.are.same({
                    [1] = {
                        [1] = {
                            pattern = "^/users/:(.*)/???$",
                            PUT = { controller = "messages_controller", action = "show", params = {} }
                        }
                    }
                }, Routes.dispatchers)
            end)

            it("adds routes to the appropriate version", function()
                local version_2 = Routes.version(2)

                version:add('GET', "/users", { controller = "users", action = "index" })
                version_2:add('GET', "/messages", { controller = "messages", action = "index" })

                assert.are.same({
                    [1] = {
                        [1] = {
                            pattern = "^/users/???$",
                            GET = { controller = "users_controller", action = "index", params = {} }
                        }
                    },

                    [2] = {
                        [1] = {
                            pattern = "^/messages/???$",
                            GET = { controller = "messages_controller", action = "index", params = {} }
                        }
                    }
                }, Routes.dispatchers)
            end)
        end)
    end)

    describe("Version helpers", function()

        before_each(function()
            version = Routes.version(1)
            -- spy.on(version, 'add')
            t = { controller = "users", action = "index" }
        end)

        after_each(function()
            -- version.add:revert()
            version = nil
        end)

        local supported_http_methods = {
            GET = true,
            POST = true,
            HEAD = true,
            OPTIONS = true,
            PUT = true,
            PATCH = true,
            DELETE = true,
            TRACE = true,
            CONNECT = true
        }

        for http_method, _ in pairs(supported_http_methods) do
            describe("." .. http_method, function()
                it("calls the .add method with ".. http_method, function()
                    local self, method, pattern, route_info

                    version.add = function(...) self, method, pattern, route_info = ... end

                    version[http_method](version, "/users", t)

                    assert.are.same(version, self)
                    assert.are.same(http_method, method)
                    assert.are.same('/users', pattern)
                    assert.are.same(t, route_info)
                end)
            end)
        end
    end)
end)

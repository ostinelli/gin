require 'spec.spec_helper'

describe("Settings", function()

    before_each(function()
        settings = require('zebra.core.settings')
    end)

    after_each(function()
        package.loaded['config.settings'] = {}  -- reset to mock
        package.loaded['zebra.core.settings'] = nil
        settings = nil
        Zebra.env = 'test'
    end)

    describe(".for_current_environment", function()
        describe("the defaults", function()
            describe("when in development environment", function()
                before_each(function()
                    Zebra.env = 'development'
                end)

                it("returns the defaults", function()
                    local defaults = {
                        code_cache = false,
                        port = 7200,
                        expose_api_console = true
                    }

                    assert.are.same(defaults, settings.for_current_environment())
                end)
            end)

            describe("when in test environment", function()
                before_each(function()
                    Zebra.env = 'test'
                end)


                it("returns the defaults", function()
                    local defaults = {
                        code_cache = true,
                        port = 7201,
                        expose_api_console = false
                    }

                     package.loaded['config.settings'] = false
                     package.loaded['config.settings'] = {}
                    assert.are.same(defaults, settings.for_current_environment())
                end)
            end)

            describe("when in production environment", function()
                before_each(function()
                    Zebra.env = 'production'
                end)

                it("returns the defaults", function()
                    local defaults = {
                        code_cache = true,
                        port = 80,
                        expose_api_console = false
                    }

                    assert.are.same(defaults, settings.for_current_environment())
                end)
            end)

            describe("when in any other environments", function()
                before_each(function()
                    Zebra.env = 'something-else'
                end)

                it("returns the defaults", function()
                    local defaults = {
                        code_cache = true,
                        port = 80,
                        expose_api_console = false
                    }

                    assert.are.same(defaults, settings.for_current_environment())
                end)
            end)
        end)

        describe("merging values from the application settings", function()
            before_each(function()
                app_settings = {}
                app_settings.development = {
                    code_cache = true,
                    port = 7202,
                    custom_setting = 'my setting'
                }
                app_settings.production = {
                    code_cache = false
                }
                package.loaded['config.settings'] = app_settings

                Zebra.env = 'development'
            end)

            after_each(function()
                package.loaded['config.settings'] = nil
                app_settings = nil
            end)

            it("returns merged values", function()
                local s = settings.for_current_environment()

                assert.are.same(true, s.code_cache)
                assert.are.same(7202, s.port)
                assert.are.same('my setting', s.custom_setting)
            end)
        end)
    end)
end)

require 'spec.spec_helper'


describe("Launcher", function()
    before_each(function()
        package.loaded['gin.core.gin'] = {
            env = 'development',
            settings = {
                port = 12345
            }
        }

        package.loaded['gin.helpers.common'] = {
            read_file = function() return "" end
        }
    end)

    after_each(function()
        package.loaded['gin.core.gin'] = nil
        package.loaded['gin.helpers.common'] = nil
    end)

    describe(".nginx_conf_content", function()
        after_each(function()
            package.loaded['gin.cli.launcher'] = nil
        end)

        it("converts GIN_PORT", function()
            package.loaded['gin.helpers.common'] = {
                read_file = function()
                    return "{{GIN_PORT}} part1 {{GIN_PORT}} part3 {{GIN_PORT}}"
                end
            }

            local content = require('gin.cli.launcher').nginx_conf_content()
            assert.are.equal(true, string.find(content, "12345 part1 12345 part3 12345") ~= nil)
        end)

        it("converts GIN_ENV", function()
            package.loaded['gin.helpers.common'] = {
                read_file = function()
                    return "{{GIN_ENV}} part1 {{GIN_ENV}} part3 {{GIN_ENV}}"
                end
            }

            local content = require('gin.cli.launcher').nginx_conf_content()

            assert.are.equal(true, string.find(content, "development part1 development part3 development") ~= nil)
        end)

        describe("{{GIN_INIT}}", function()
            before_each(function()
                package.loaded['gin.helpers.common'] = {
                    read_file = function() return "{{GIN_INIT}}" end
                }
            end)

            describe("code cache", function()
                describe("when it is true", function()
                    before_each(function()
                        package.loaded['gin.core.gin'].settings.code_cache = true
                    end)

                    it("adds the code cache ON directive", function()
                        local content = require('gin.cli.launcher').nginx_conf_content()
                        assert.are.equal(true, string.find(content, "lua_code_cache on") ~= nil)
                    end)
                end)

                describe("when it is false", function()
                    before_each(function()
                        package.loaded['gin.core.gin'].settings.code_cache = false
                    end)

                    it("adds the code cache OFF directive", function()
                        local content = require('gin.cli.launcher').nginx_conf_content()
                        assert.are.equal(true, string.find(content, "lua_code_cache off") ~= nil)
                    end)
                end)
            end)
        end)

        describe("{{GIN_RUNTIME}}", function()
            before_each(function()
                package.loaded['gin.helpers.common'] = {
                    read_file = function() return "{{GIN_RUNTIME}}" end
                }
            end)

            describe("API console", function()
                describe("when it is true", function()
                    before_each(function()
                        package.loaded['gin.core.gin'].settings.expose_api_console = true
                    end)

                    it("adds the directive", function()
                        local content = require('gin.cli.launcher').nginx_conf_content()
                        assert.are.equal(true, string.find(content, "location /ginconsole") ~= nil)
                    end)
                end)

                describe("when it is false", function()
                    before_each(function()
                        package.loaded['gin.core.gin'].settings.expose_api_console = false
                    end)

                    it("does not add the directive", function()
                        local content = require('gin.cli.launcher').nginx_conf_content()
                        assert.are.equal(true, string.find(content, "location /ginconsole") == nil)
                    end)
                end)
            end)
        end)
    end)
end)

require 'spec.spec_helper'


describe("Gin", function()
    before_each(function()
        package.loaded['gin.core.gin'] = nil
    end)

    after_each(function()
        package.loaded['gin.core.gin'] = nil
    end)

    describe(".env", function()
        describe("when the GIN_ENV value is set", function()
            it("sets it to the GIN_ENV value", function()
                local original_getenv = os.getenv
                os.getenv = function(arg)
                    if arg == "GIN_ENV" then return 'myenv' end
                end

                local Gin = require 'gin.core.gin'

                assert.are.equal('myenv', Gin.env)

                os.getenv = original_getenv
            end)
        end)

        describe("when the GIN_ENV value is not set", function()
            it("sets it to development", function()
                local original_getenv = os.getenv
                os.getenv = function(arg)
                    return nil
                end

                local Gin = require 'gin.core.gin'

                assert.are.equal('development', Gin.env)

                os.getenv = original_getenv
            end)
        end)
    end)

    describe(".settings", function()
        it("sets them to the current environment settings", function()
            package.loaded['gin.core.settings'] = {
                for_environment = function() return { mysetting = 'my-setting' } end
            }

            local Gin = require 'gin.core.gin'

            assert.are.same('my-setting', Gin.settings.mysetting)

            package.loaded['gin.core.settings'] = nil
        end)
    end)
end)

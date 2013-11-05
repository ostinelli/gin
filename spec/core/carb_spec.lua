require 'spec.spec_helper'

describe("Carb", function()
    before_each(function()
        package.loaded['carb.core.carb'] = nil
    end)

    after_each(function()
        package.loaded['carb.core.carb'] = nil
    end)

    describe(".env", function()
        before_each(function()
            -- carb env gets set in tests, so reset it
            Carb.env = nil
        end)

        describe("when the CARB_ENV value is set", function()
            it("sets it to the CARB_ENV value", function()
                local original_getenv = os.getenv
                os.getenv = function(arg)
                    if arg == "CARB_ENV" then return 'myenv' end
                end

                require 'carb.core.carb'

                assert.are.equal('myenv', Carb.env)

                os.getenv = original_getenv
            end)
        end)

        describe("when the CARB_ENV value is not set", function()
            it("sets it to development", function()
                local original_getenv = os.getenv
                os.getenv = function(arg)
                    return nil
                end

                require 'carb.core.carb'

                assert.are.equal('development', Carb.env)

                os.getenv = original_getenv
            end)
        end)
    end)

    describe(".settings", function()
        it("sets them to the current environment settings", function()
            package.loaded['carb.core.settings'] = {
                for_current_environment = function() return { mysetting = 'my-setting' } end
            }

            require 'carb.core.carb'

            assert.are.same('my-setting', Carb.settings.mysetting)

            package.loaded['carb.core.settings'] = nil
        end)
    end)
end)

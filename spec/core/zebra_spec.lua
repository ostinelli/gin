require 'spec.spec_helper'

describe("Zebra", function()
    before_each(function()
        package.loaded['zebra.core.zebra'] = nil
    end)

    after_each(function()
        package.loaded['zebra.core.zebra'] = nil
        Zebra.env = 'test'
    end)

    describe(".env", function()
        before_each(function()
            -- zebra env gets set in tests, so reset it
            Zebra.env = nil
        end)

        describe("when the ZEBRA_ENV value is set", function()
            it("sets it to the ZEBRA_ENV value", function()
                local original_getenv = os.getenv
                os.getenv = function(arg)
                    if arg == "ZEBRA_ENV" then return 'myenv' end
                end

                require 'zebra.core.zebra'

                assert.are.equal('myenv', Zebra.env)

                os.getenv = original_getenv
            end)
        end)

        describe("when the ZEBRA_ENV value is not set", function()
            it("sets it to development", function()
                local original_getenv = os.getenv
                os.getenv = function(arg)
                    return nil
                end

                require 'zebra.core.zebra'

                assert.are.equal('development', Zebra.env)

                os.getenv = original_getenv
            end)
        end)
    end)

    describe(".settings", function()
        it("sets them to the current environment settings", function()
            package.loaded['zebra.core.settings'] = {
                for_current_environment = function() return { mysetting = 'my-setting' } end
            }

            require 'zebra.core.zebra'

            assert.are.same('my-setting', Zebra.settings.mysetting)

            package.loaded['zebra.core.settings'] = nil
        end)
    end)
end)

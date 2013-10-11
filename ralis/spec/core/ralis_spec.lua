require 'ralis.spec.spec_helper'


describe("Ralis", function()
    before_each(function()
        package.loaded['ralis.core.ralis'] = nil
    end)

    after_each(function()
        package.loaded['ralis.core.ralis'] = nil
    end)

    describe(".env", function()
        before_each(function()
            -- ralis env gets set in tests, so reset it
            Ralis.env = nil
        end)

        describe("when the RALIS_ENV value is set", function()
            it("sets it to the RALIS_ENV value", function()
                local original_getenv = os.getenv
                os.getenv = function(arg)
                    if arg == "RALIS_ENV" then return 'myenv' end
                end

                require 'ralis.core.ralis'

                assert.are.equal('myenv', Ralis.env)

                os.getenv = original_getenv
            end)
        end)

        describe("when the RALIS_ENV value is not set", function()
            it("sets it to development", function()
                local original_getenv = os.getenv
                os.getenv = function(arg)
                    return nil
                end

                require 'ralis.core.ralis'

                assert.are.equal('development', Ralis.env)

                os.getenv = original_getenv
            end)
        end)
    end)

    describe(".settings", function()
        it("sets them to the current environment settings", function()
            package.loaded['ralis.core.settings'] = {
                for_current_environment = function() return { mysetting = 'my-setting' } end
            }

            require 'ralis.core.ralis'

            assert.are.same('my-setting', Ralis.settings.mysetting)

            package.loaded['ralis.core.settings'] = nil
        end)
    end)
end)

require 'spec.spec_helper'

describe("Integration", function()
    before_each(function()
        IntegrationRunner = require 'carb.spec.runners.integration'
    end)

    after_each(function()
        package.loaded['carb.spec.runners.integration'] = nil
        IntegrationRunner = nil
    end)

    describe(".encode_table", function()
        it("encodes a table into form-urlencoded", function()
            args = {
                arg1 = 1.0,
                arg2 = { "two/string", "another/string" },
                ['arg~3'] = "a tag",
                [5] = "five"
            }

            local urlencoded = IntegrationRunner.encode_table(args)

            assert.are.same("arg~3=a%20tag&arg2=two%2fstring&arg2=another%2fstring&5=five&arg1=1", urlencoded)
        end)
    end)
end)

require 'ralis.spec.spec_helper'

describe("Error", function()
    describe("raise_error", function()
        it("raises an error with a code", function()
            ok, err = pcall(function() raise_error(1000) end)

            assert.are.equal(false, ok)
            assert.are.equal(1000, err.code)
        end)
    end)
end)

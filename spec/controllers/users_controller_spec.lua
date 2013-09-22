require 'spec/spec_helper'

describe("UsersController", function()

    describe("#show", function()
        it("does stuff", function()
            visit('GET', "/users", { page = 2 })
        end)
    end)
end)

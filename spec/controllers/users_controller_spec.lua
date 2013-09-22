require 'spec/spec_helper'

describe("UsersController", function()

    describe("#show", function()
        it("does stuff", function()
            local request = Request.new({
                method = 'GET',
                url = "/users",
                query = { page = 2 }
            })

            -- response = hit(request)
        end)
    end)
end)

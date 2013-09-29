require 'spec/spec_helper'

describe("UsersController", function()

    describe("#index", function()
        it("responds with a list of users", function()
            local body = CJSON.encode({ user = "roberto" })

            local response = hit({
                method = 'POST',
                url = "/pages/body_and_url",
                uri_params = { page = 2 },
                body = body
            })

            assert.are.same(200, response.status)
            assert.are.same({ page = "2", user = "roberto" }, CJSON.decode(response.body))
        end)
    end)
end)

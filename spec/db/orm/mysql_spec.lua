require 'spec.spec_helper'

describe("ORM", function()
    before_each(function()
        ngx = {
            quote_sql_str = function(str) return "'q-" .. str .. "'" end
        }
        db = {
            query = function(self, ...) query = ... end
        }
        orm = require 'ralis.db.orm.mysql'
        orm.define_model(db, 'User', 'users')
    end)

    after_each(function()
        ngx = nil
        orm = nil
        User = nil
        db = nil
        query = nil
    end)

    describe("model", function()
        it("defines the global model name", function()
            assert.are_not.equals(nil, User)
        end)

        describe("all", function()
            it("returns all the users", function()
                User.all()
                assert.are.equal(query, "SELECT * FROM users;")
            end)
        end)

        describe("create", function()
            it("creates a new user", function()
                User.create({ first_name = 'roberto', last_name = 'ralis', age = 3, seen_at = '2013-10-12T16:31:21 UTC'})
                assert.are.equal(query, "INSERT INTO users (seen_at,last_name,first_name,age) VALUES ('q-2013-10-12T16:31:21 UTC','q-ralis','q-roberto',3);")
            end)
        end)
    end)
end)

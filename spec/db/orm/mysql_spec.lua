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

        describe(".create", function()
            describe("when attrs are specified", function()
                it("creates a new entry", function()
                    User.create({ first_name = 'roberto', last_name = 'ralis', age = 3, seen_at = '2013-10-12T16:31:21 UTC'})
                    assert.are.equal(query, "INSERT INTO users (seen_at,last_name,first_name,age) VALUES ('q-2013-10-12T16:31:21 UTC','q-ralis','q-roberto',3);")
                end)
            end)

            describe("when no attrs are specified", function()
                it("raises an error", function()
                    ok, err = pcall(function() return User.create() end)

                    assert.are.equal(false, ok)
                    assert.are.equal(true, string.find(err, "no attributes were specified to create new model instance") > 0)
                end)
            end)
        end)

        describe(".where", function()
            describe("when attrs are specified", function()
                describe("when no option are specified", function()
                    it("returns models", function()
                        User.where({ first_name = 'roberto', last_name = 'ralis', age = 3, seen_at = '2013-10-12T16:31:21 UTC'})
                        assert.are.equal(query, "SELECT * FROM users WHERE (seen_at='q-2013-10-12T16:31:21 UTC',last_name='q-ralis',first_name='q-roberto',age=3);")
                    end)
                end)

                describe("when the limit option is specified", function()
                    it("finds models with limit", function()
                        User.where({ first_name = 'roberto'}, { limit = 12 })
                        assert.are.equal(query, "SELECT * FROM users WHERE (first_name='q-roberto') LIMIT 12;")
                    end)
                end)

                describe("when the offset option is specified", function()
                    it("finds models with offset", function()
                        User.where({ first_name = 'roberto'}, { offset = 10 })
                        assert.are.equal(query, "SELECT * FROM users WHERE (first_name='q-roberto') OFFSET 10;")
                    end)
                end)
            end)

            describe("when no attrs are specified", function()
                describe("when no option are specified", function()
                    it("returns models", function()
                        User.where()
                        assert.are.equal(query, "SELECT * FROM users;")
                    end)
                end)

                describe("when the limit option is specified", function()
                    it("finds models with limit", function()
                        User.where({ first_name = 'roberto'}, { limit = 12 })
                        assert.are.equal(query, "SELECT * FROM users WHERE (first_name='q-roberto') LIMIT 12;")
                    end)
                end)

                describe("when the offset option is specified", function()
                    it("finds models with offset", function()
                        User.where({ first_name = 'roberto'}, { offset = 10 })
                        assert.are.equal(query, "SELECT * FROM users WHERE (first_name='q-roberto') OFFSET 10;")
                    end)
                end)
            end)
        end)
    end)
end)

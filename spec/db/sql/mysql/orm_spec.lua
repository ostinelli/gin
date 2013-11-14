require 'spec.spec_helper'

describe("MySqlOrm", function()

    before_each(function()
        MySqlOrm = require 'gin.db.sql.mysql.orm'
        local quote_fun = function(str) return "'q-".. str .. "'" end
        orm = MySqlOrm.new('users', quote_fun)
    end)

    after_each(function()
        package.loaded['gin.db.sql.mysql.orm'] = nil
        MySqlOrm = nil
        orm = nil
    end)

    describe("#create", function()
        describe("when attrs are specified", function()
            it("creates a new entry", function()
                local sql = orm:create({ first_name = 'roberto', last_name = 'gin', age = 3, seen_at = '2013-10-12T16:31:21 UTC' })
                assert.are.equal("INSERT INTO users (seen_at,last_name,first_name,age) VALUES ('q-2013-10-12T16:31:21 UTC','q-gin','q-roberto',3);", sql)
            end)
        end)

        describe("when no attrs are specified", function()
            it("raises an error", function()
                ok, err = pcall(function() return orm:create() end)

                assert.are.equal(false, ok)
                assert.are.equal(true, string.find(err, "no attributes were specified to create new model instance") > 0)
            end)
        end)
    end)

    describe("#where", function()
        describe("when attrs are specified", function()
            describe("when no options are specified", function()
                it("finds and returns models without options", function()
                    local sql = orm:where({ first_name = 'roberto', last_name = 'gin', age = 3, seen_at = '2013-10-12T16:31:21 UTC' })
                    assert.are.equal("SELECT * FROM users WHERE (seen_at='q-2013-10-12T16:31:21 UTC' AND last_name='q-gin' AND first_name='q-roberto' AND age=3);", sql)
                end)
            end)

            describe("when the limit option is specified", function()
                it("finds models with limit", function()
                    local sql = orm:where({ first_name = 'roberto'}, { limit = 12 })
                    assert.are.equal("SELECT * FROM users WHERE (first_name='q-roberto') LIMIT 12;", sql)
                end)
            end)

            describe("when the offset option is specified", function()
                it("finds models with offset", function()
                    local sql = orm:where({ first_name = 'roberto'}, { offset = 10 })
                    assert.are.equal("SELECT * FROM users WHERE (first_name='q-roberto') OFFSET 10;", sql)
                end)
            end)

            describe("when the order option is specified", function()
                it("order model results", function()
                    local sql = orm:where({ first_name = 'roberto'}, { order = "first_name DESC" })
                    assert.are.equal("SELECT * FROM users WHERE (first_name='q-roberto') ORDER BY first_name DESC;", sql)
                end)
            end)

            describe("when the order, limit and offset options are specified", function()
                it("finds models with offset", function()
                    local sql = orm:where({ first_name = 'roberto'}, { order = "first_name DESC", limit = 12, offset = 10 })
                    assert.are.equal("SELECT * FROM users WHERE (first_name='q-roberto') ORDER BY first_name DESC LIMIT 12 OFFSET 10;", sql)
                end)
            end)
        end)

        describe("when no attrs are specified", function()
            describe("when no options are specified", function()
                it("finds all models", function()
                    local sql = orm:where()
                    assert.are.equal("SELECT * FROM users;", sql)
                end)
            end)

            describe("when the limit option is specified", function()
                it("finds models with limit", function()
                    local sql = orm:where({}, { limit = 12 })
                    assert.are.equal("SELECT * FROM users LIMIT 12;", sql)
                end)
            end)

            describe("when the offset option is specified", function()
                it("finds models with offset", function()
                    local sql = orm:where({}, { offset = 10 })
                    assert.are.equal("SELECT * FROM users OFFSET 10;", sql)
                end)
            end)

            describe("when the order option is specified", function()
                it("order model results", function()
                    local sql = orm:where({}, { order = "first_name DESC" })
                    assert.are.equal("SELECT * FROM users ORDER BY first_name DESC;", sql)
                end)
            end)

            describe("when the order, limit and offset options are specified", function()
                it("finds models with offset", function()
                    local sql = orm:where({ }, { order = "first_name DESC", limit = 12, offset = 10 })
                    assert.are.equal("SELECT * FROM users ORDER BY first_name DESC LIMIT 12 OFFSET 10;", sql)
                end)
            end)
        end)
    -- end)

    -- describe("#find_by", function()
    --     after_each(function()
    --         attrs_arg = nil
    --         options_arg = nil
    --     end)

    --     describe("when called without options", function()
    --         it("calls .where with limit 1", function()
    --             orm.where = function (...)
    --                 _, attrs_arg, options_arg = ...
    --                 return 'find-by-sql'
    --             end

    --             local sql = orm:find_by('attrs')

    --             assert.are.same('attrs', attrs_arg)
    --             assert.are.same({ limit = 1 }, options_arg)
    --             assert.are.same('find-by-sql', sql)
    --         end)
    --     end)

    --     describe("when called with options", function()
    --         it("calls .where with limit 1 keeping only the order option", function()
    --             orm.where = function (...)
    --                 _, attrs_arg, options_arg = ...
    --                 return 'find-by-sql'
    --             end

    --             local sql = orm:find_by('attrs', { limit = 10, offset = 5, order = "first_name DESC" })

    --             assert.are.same('attrs', attrs_arg)
    --             assert.are.same({ limit = 1, order = "first_name DESC" }, options_arg)
    --             assert.are.same('find-by-sql', sql)
    --         end)
    --     end)
    -- end)

    describe("#delete_where", function()
        describe("when attrs are specified", function()
            describe("when no options are specified", function()
                it("calls .delete_where", function()
                    local sql = orm:delete_where({ first_name = 'roberto', last_name = 'gin', age = 3, seen_at = '2013-10-12T16:31:21 UTC' })
                    assert.are.equal("DELETE FROM users WHERE (seen_at='q-2013-10-12T16:31:21 UTC' AND last_name='q-gin' AND first_name='q-roberto' AND age=3);", sql)
                end)
            end)

            describe("when the limit option is specified", function()
                it("calls .delete_where with limit", function()
                    local sql = orm:delete_where({ first_name = 'roberto'}, { limit = 12 })
                    assert.are.equal("DELETE FROM users WHERE (first_name='q-roberto') LIMIT 12;", sql)
                end)
            end)
        end)

        describe("when attrs are not specified", function()
            describe("when no options are specified", function()
                it("calls .delete_where", function()
                    local sql = orm:delete_where()
                    assert.are.equal("DELETE FROM users;", sql)
                end)
            end)

            describe("when the limit option is specified", function()
                it("calls .delete_where with limit", function()
                    local sql = orm:delete_where({}, { limit = 12 })
                    assert.are.equal("DELETE FROM users LIMIT 12;", sql)
                end)
            end)
        end)
    end)

    describe("#update_where", function()
        describe("when no attrs are specified", function()
            it("raises an error", function()
                ok, err = pcall(function() return orm:update_where() end)

                assert.are.equal(false, ok)
                assert.are.equal(true, string.find(err, "no attributes were specified to create new model instance") > 0)
            end)
        end)

        describe("when attrs are specified", function()
            describe("when no options are specified", function()
                it("calls .update_where", function()
                    local sql = orm:update_where({ first_name = 'roberto', last_name = 'gin', age = 3, seen_at = '2013-10-12T16:31:21 UTC' })
                    assert.are.equal("UPDATE users SET seen_at='q-2013-10-12T16:31:21 UTC',last_name='q-gin',first_name='q-roberto',age=3;", sql)
                end)
            end)

            describe("when options are specified", function()
                it("calls .update_where", function()
                    local sql = orm:update_where(
                        { first_name = 'roberto', last_name = 'gin', age = 3, seen_at = '2013-10-12T16:31:21 UTC' },
                        { id = 4, first_name = 'robbb' }
                    )
                    assert.are.equal("UPDATE users SET seen_at='q-2013-10-12T16:31:21 UTC',last_name='q-gin',first_name='q-roberto',age=3 WHERE (first_name='q-robbb' AND id=4);", sql)
                end)
            end)
        end)
    end)
end)
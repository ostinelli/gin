require 'spec.spec_helper'


describe("PostgreSqlOrm", function()

    before_each(function()
        PostgreSqlOrm = require 'gin.db.sql.postgresql.orm'
        local quote_fun = function(str) return "'q-".. str .. "'" end
        orm = PostgreSqlOrm.new('users', quote_fun)
    end)

    after_each(function()
        package.loaded['gin.db.sql.postgresql.orm'] = nil
        PostgreSqlOrm = nil
        orm = nil
    end)

    describe("#create", function()
        describe("when attrs are specified", function()
            it("creates a new entry", function()
                local sql = orm:create({ first_name = 'roberto', last_name = 'gin', age = 3, seen_at = '2013-10-12T16:31:21 UTC' })
                assert.are.equal(112, #sql)
                assert.are.equal("INSERT INTO users (", sql:sub(1, 19))
                assert.is.equal(52, (sql:find(") VALUES (", 20, true)))
                assert.are.equal(");", sql:sub(-2))
                assert.is_number(sql:find("seen_at", 20, true))
                assert.is_number(sql:find("last_name", 20, true))
                assert.is_number(sql:find("first_name", 20, true))
                assert.is_number(sql:find("age", 20, true))
                assert.is_number(sql:find("'q-2013-10-12T16:31:21 UTC'", 62, true))
                assert.is_number(sql:find("'q-gin'", 62, true))
                assert.is_number(sql:find("'q-roberto'", 62, true))
                assert.is_number(sql:find("3", 62, true))
            end)
        end)

        describe("when no attrs are specified", function()
            it("raises an error", function()
                local ok, err = pcall(orm.create, orm)

                assert.are.equal(false, ok)
                assert.are.equal(true, string.find(err, "no attributes were specified to create new model instance") > 0)
            end)
        end)
    end)

    describe("#where", function()
        describe("when attrs are specified", function()
            describe("when attrs are a table", function()
                describe("when no options are specified", function()
                    it("finds and returns models without options", function()
                        local sql = orm:where({ first_name = 'roberto', last_name = 'gin', age = 3, seen_at = '2013-10-12T16:31:21 UTC' })
                        assert.are.equal(123, #sql)
                        assert.are.equal("SELECT * FROM users WHERE (",sql:sub(1,27))
                        assert.are.equal(");",sql:sub(-2))

                        local andpos = sql:find(" AND ",28,true)
                        assert.is_number(andpos)
                        andpos = sql:find(" AND ",1+andpos,true)
                        assert.is_number(andpos)
                        andpos = sql:find(" AND ",1+andpos,true)
                        assert.is_number(andpos)
                        assert.is_nil(sql:find(" AND ",1+andpos,true))

                        assert.is_number(sql:find("seen_at='q-2013-10-12T16:31:21 UTC'",28,true))
                        assert.is_number(sql:find("last_name='q-gin'",28,true))
                        assert.is_number(sql:find("first_name='q-roberto'",28,true))
                        assert.is_number(sql:find("age=3",28,true))
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

            describe("when attrs are a table", function()
                describe("when no options are specified", function()
                    it("finds and returns models without options", function()
                        local sql = orm:where("age > 3")
                        assert.are.equal("SELECT * FROM users WHERE (age > 3);", sql)
                    end)
                end)

                describe("when the limit option is specified", function()
                    it("finds models with limit", function()
                        local sql = orm:where("age > 3", { limit = 12 })
                        assert.are.equal("SELECT * FROM users WHERE (age > 3) LIMIT 12;", sql)
                    end)
                end)

                describe("when the offset option is specified", function()
                    it("finds models with offset", function()
                        local sql = orm:where("age > 3", { offset = 10 })
                        assert.are.equal("SELECT * FROM users WHERE (age > 3) OFFSET 10;", sql)
                    end)
                end)

                describe("when the order option is specified", function()
                    it("order model results", function()
                        local sql = orm:where("age > 3", { order = "first_name DESC" })
                        assert.are.equal("SELECT * FROM users WHERE (age > 3) ORDER BY first_name DESC;", sql)
                    end)
                end)

                describe("when the order, limit and offset options are specified", function()
                    it("finds models with offset", function()
                        local sql = orm:where("age > 3", { order = "first_name DESC", limit = 12, offset = 10 })
                        assert.are.equal("SELECT * FROM users WHERE (age > 3) ORDER BY first_name DESC LIMIT 12 OFFSET 10;", sql)
                    end)
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
    end)

    describe("#delete_where", function()
        describe("when attrs are specified", function()
            describe("when attrs are a table", function()
                describe("when no options are specified", function()
                    it("calls .delete_where", function()
                        local sql = orm:delete_where({ first_name = 'roberto', last_name = 'gin', age = 3, seen_at = '2013-10-12T16:31:21 UTC' })
                        assert.are.equal(121, #sql)
                        assert.are.equal("DELETE FROM users WHERE (",sql:sub(1,25))
                        assert.are.equal(");",sql:sub(-2))

                        local andpos = sql:find(" AND ",26,true)
                        assert.is_number(andpos)
                        andpos = sql:find(" AND ",1+andpos,true)
                        assert.is_number(andpos)
                        andpos = sql:find(" AND ",1+andpos,true)
                        assert.is_number(andpos)
                        assert.is_nil(sql:find(" AND ",1+andpos,true))

                        assert.is_number(sql:find("seen_at='q-2013-10-12T16:31:21 UTC'",26,true))
                        assert.is_number(sql:find("last_name='q-gin'",26,true))
                        assert.is_number(sql:find("first_name='q-roberto'",26,true))
                        assert.is_number(sql:find("age=3",26,true))
                    end)
                end)

                describe("when the limit option is specified", function()
                    it("calls .delete_where with limit", function()
                        local sql = orm:delete_where({ first_name = 'roberto'}, { limit = 12 })
                        assert.are.equal("DELETE FROM users WHERE (first_name='q-roberto') LIMIT 12;", sql)
                    end)
                end)
            end)

            describe("when attrs are a string", function()
                describe("when no options are specified", function()
                    it("calls .delete_where", function()
                        local sql = orm:delete_where("age > 3")
                        assert.are.equal("DELETE FROM users WHERE (age > 3);", sql)
                    end)
                end)

                describe("when the limit option is specified", function()
                    it("calls .delete_where with limit", function()
                        local sql = orm:delete_where("age > 3", { limit = 12 })
                        assert.are.equal("DELETE FROM users WHERE (age > 3) LIMIT 12;", sql)
                    end)
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
                local ok, err = pcall(orm.update_where, orm)

                assert.are.equal(false, ok)
                assert.are.equal(true, string.find(err, "no attributes were specified to create new model instance") > 0)
            end)
        end)

        describe("when attrs are specified", function()
            describe("when no where is specified", function()
                it("calls .update_where", function()
                    local sql = orm:update_where({ first_name = 'roberto', last_name = 'gin', age = 3, seen_at = '2013-10-12T16:31:21 UTC' })
                    assert.are.equal(100, #sql)
                    assert.are.equal("UPDATE users SET ",sql:sub(1,17))
                    assert.are.equal(";",sql:sub(-1))
                    assert.is_number(sql:find("seen_at='q-2013-10-12T16:31:21 UTC'",18,true))
                    assert.is_number(sql:find("last_name='q-gin'",18,true))
                    assert.is_number(sql:find("first_name='q-roberto'",18,true))
                    assert.is_number(sql:find("age=3",18,true))
                end)
            end)

            describe("when where is specified", function()
                describe("and where is a table", function()
                    it("calls .update_where", function()
                        local sql = orm:update_where(
                            { first_name = 'roberto', last_name = 'gin', age = 3, seen_at = '2013-10-12T16:31:21 UTC' },
                            { id = 4, first_name = 'robbb' }
                        )
                        assert.are.equal(138, #sql)
                        assert.are.equal("UPDATE users SET ",sql:sub(1,17))
                        assert.are.equal(" WHERE (",sql:sub(-39,-32))
                        assert.are.equal(");",sql:sub(-2))
                        assert.is_number(sql:find(" AND ",-39,true))
                        assert.is_number(sql:find("first_name='q-robbb'",-39,true))
                        assert.is_number(sql:find("id=4",-39,true))
                        assert.is_number(sql:find("seen_at='q-2013-10-12T16:31:21 UTC'",18,true))
                        assert.is_number(sql:find("last_name='q-gin'",18,true))
                        assert.is_number(sql:find("first_name='q-roberto'",18,true))
                        assert.is_number(sql:find("age=3",18,true))
                    end)
                end)

                describe("and where is a string", function()
                    it("calls .update_where", function()
                        local sql = orm:update_where(
                            { first_name = 'roberto', last_name = 'gin', age = 3, seen_at = '2013-10-12T16:31:21 UTC' },
                            "age > 3"
                        )
                        assert.are.equal(116, #sql)
                        assert.are.equal("UPDATE users SET ",sql:sub(1,17))
                        assert.are.equal(" WHERE (age > 3);",sql:sub(-17))
                        assert.is_number(sql:find("seen_at='q-2013-10-12T16:31:21 UTC'",18,true))
                        assert.is_number(sql:find("last_name='q-gin'",18,true))
                        assert.is_number(sql:find("first_name='q-roberto'",18,true))
                        assert.is_number(sql:find("age=3",18,true))
                    end)
                end)
            end)
        end)
    end)
end)
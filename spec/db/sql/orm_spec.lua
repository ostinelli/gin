require 'spec.spec_helper'

describe("SqlOrm", function()

    before_each(function()
        SqlOrm = require 'gin.db.sql.orm'
        MySql = {
            options = {
                adapter = 'mysql'
            },
            adapter = {
                quote = function(str) return "q-" .. str end
            }
        }
    end)

    after_each(function()
        package.loaded['gin.db.sql.orm'] = nil
        SqlOrm = nil
        MySql = nil
        package.loaded['gin.db.sql.mysql.orm'] = nil
    end)

    describe("A model created with .define_model", function()

        after_each(function()
            Model = nil
            table_name_arg = nil
            quote_fun_arg = nil
        end)

        it("initializes the orm with the correct params", function()
            package.loaded['gin.db.sql.mysql.orm'] = {
                new = function(table_name, quote_fun)
                    table_name_arg, quote_fun_arg = table_name, quote_fun

                    return {
                        table_name = table_name,
                        quote = quote_fun
                    }
                end
            }

            SqlOrm.define_model(MySql, 'users')

            assert.are.same('users', table_name_arg)
            assert.are.same('q-roberto', quote_fun_arg('roberto'))
        end)

        describe(".new", function()
            before_each(function()
                Model = SqlOrm.define_model(MySql, 'users')
            end)

            it("returns a new instance of Model", function()
                local model = Model.new({ first_name = 'roberto', last_name = 'gin' })

                assert.are.equal('roberto', model.first_name)
                assert.are.equal('gin', model.last_name)
            end)
        end)

        describe(".create", function()
            before_each(function()
                MySql.execute = function(self, sql)
                    sql_arg = sql
                    return 1
                end

                MySql.adapter.get_last_id = function(...) return 10 end

                package.loaded['gin.db.sql.mysql.orm'] = {
                    new = function(table_name, quote_fun)
                        return {
                            table_name = table_name,
                            quote = quote_fun,
                            create = function(self, ...)
                                attrs_arg = ...
                                return "SQL CREATE"
                            end
                        }
                    end
                }
                Model = SqlOrm.define_model(MySql, 'users')
            end)

            after_each(function()
                attrs_arg = nil
                sql_arg = nil
            end)

            it("calls the orm with the correct params", function()
                Model.create({ first_name = 'roberto', last_name = 'gin' })
                assert.are.same('roberto', attrs_arg.first_name)
                assert.are.same('gin', attrs_arg.last_name)
            end)

            it("calls execute with the correct params", function()
                Model.create({ first_name = 'roberto', last_name = 'gin' })
                assert.are.same("SQL CREATE", sql_arg)
            end)

            it("returns a new model", function()
                local model = Model.create({ first_name = 'roberto', last_name = 'gin' })

                assert.are.equal(10, model.id)
                assert.are.equal('roberto', model.first_name)
                assert.are.equal('gin', model.last_name)
            end)
        end)

        describe(".where", function()
            before_each(function()
                MySql.execute = function(self, sql)
                    sql_arg = sql
                    return {
                        { first_name = 'roberto', last_name = 'gin' },
                        { first_name = 'hedy', last_name = 'tonic' }
                    }
                end

                package.loaded['gin.db.sql.mysql.orm'] = {
                    new = function(table_name, quote_fun)
                        return {
                            table_name = table_name,
                            quote = quote_fun,
                            where = function(self, ...)
                                attrs_arg, options_arg = ...
                                return "SQL WHERE"
                            end
                        }
                    end
                }
                Model = SqlOrm.define_model(MySql, 'users')
            end)

            after_each(function()
                attrs_arg = nil
                options_arg = nil
                sql_arg = nil
            end)

            it("calls the orm with the correct params and options", function()
                Model.where({ first_name = 'roberto', last_name = 'gin' }, "options")
                assert.are.same({ first_name = 'roberto', last_name = 'gin' }, attrs_arg)
                assert.are.same("options", options_arg)
            end)

            it("calls execute with the correct params", function()
                Model.where({ first_name = 'roberto', last_name = 'gin' })
                assert.are.same("SQL WHERE", sql_arg)
            end)

            it("returns the models", function()
                local models = Model.where() -- params are stubbed in the execute return

                assert.are.equal(2, #models)
                local roberto = models[1]
                assert.are.equal('roberto', roberto.first_name)
                assert.are.equal('gin', roberto.last_name)
                local hedy = models[2]
                assert.are.equal('hedy', hedy.first_name)
                assert.are.equal('tonic', hedy.last_name)
            end)
        end)

        describe(".all", function()
            before_each(function()
                Model = SqlOrm.define_model(MySql, 'users')
                Model.where = function(...)
                    attrs_arg, options_arg = ...
                    return 'all models'
                end
            end)

            after_each(function()
                attrs_arg = nil
                options_arg = nil
            end)

            it("calls where with the correct options", function()
                local models = Model.all("options")

                assert.are.same({}, attrs_arg)
                assert.are.same("options", options_arg)
                assert.are.same("all models", models)
            end)
        end)

        describe(".find_by", function()
            before_each(function()
                Model = SqlOrm.define_model(MySql, 'users')
                Model.where = function(...)
                    attrs_arg, options_arg = ...
                    return 'all models'
                end
            end)

            after_each(function()
                attrs_arg = nil
                options_arg = nil
            end)

            describe("when called without options", function()
                it("calls .where with limit 1", function()
                    local models = Model.find_by({ first_name = 'roberto' })

                    assert.are.same({ first_name = 'roberto' }, attrs_arg)
                    assert.are.same({ limit = 1 }, options_arg)
                    assert.are.same("all models", models)
                end)
            end)

            describe("when called with options", function()
                it("calls .where with limit 1 keeping only the order option", function()
                    local models = Model.find_by({ first_name = 'roberto' }, { limit = 10, offset = 5, order = "first_name DESC" })

                    assert.are.same({ first_name = 'roberto' }, attrs_arg)
                    assert.are.same({ limit = 1, order = "first_name DESC" }, options_arg)
                    assert.are.same("all models", models)
                end)
            end)
        end)

        describe(".delete_where", function()
            before_each(function()
                MySql.execute = function(self, sql)
                    sql_arg = sql
                    return 1
                end

                package.loaded['gin.db.sql.mysql.orm'] = {
                    new = function(table_name, quote_fun)
                        return {
                            table_name = table_name,
                            quote = quote_fun,
                            delete_where = function(self, ...)
                                attrs_arg, options_arg = ...
                                return "SQL DELETE WHERE"
                            end
                        }
                    end
                }
                Model = SqlOrm.define_model(MySql, 'users')
            end)

            after_each(function()
                attrs_arg = nil
                options_arg = nil
                sql_arg = nil
            end)

            it("calls the orm with the correct params and options", function()
                Model.delete_where({ first_name = 'roberto', last_name = 'gin' }, "options")
                assert.are.same({ first_name = 'roberto', last_name = 'gin' }, attrs_arg)
                assert.are.same("options", options_arg)
            end)

            it("calls execute with the correct params", function()
                Model.delete_where({ first_name = 'roberto', last_name = 'gin' })
                assert.are.same("SQL DELETE WHERE", sql_arg)
            end)

            it("returns the result", function()
                local result = Model.delete_where() -- params are stubbed in the execute return
                assert.are.equal(1, result)
            end)
        end)
    end)
end)

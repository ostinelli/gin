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
                    return { first_name = 'roberto', last_name = 'gin' }
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
                assert.are.same({ first_name = 'roberto', last_name = 'gin' }, attrs_arg)
            end)

            it("calls execute with the correct params", function()
                Model.create({ first_name = 'roberto', last_name = 'gin' })
                assert.are.same("SQL CREATE", sql_arg)
            end)

            it("returns a new model", function()
                local model = Model.create() -- params are stubbed in the execute return

                assert.are.equal(10, model.id)
                assert.are.equal('roberto', model.first_name)
                assert.are.equal('gin', model.last_name)
            end)
        end)
    end)
end)

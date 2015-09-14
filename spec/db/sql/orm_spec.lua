require 'spec.spec_helper'

-- gin
local helpers = require 'gin.helpers.common'


describe("SqlOrm", function()

    before_each(function()
        SqlOrm = require 'gin.db.sql.orm'
        MySql = {
            options = {
                adapter = 'mysql'
            },
            quote = function(self, str) return "q-" .. str end
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
                assert.are.same({ first_name = 'roberto', last_name = 'gin' }, model)
            end)
        end)

        describe(".create", function()
            before_each(function()
                MySql.execute_and_return_last_id = function(self, sql)
                    sql_arg = sql
                    return 10
                end

                package.loaded['gin.db.sql.mysql.orm'] = {
                    new = function(table_name, quote_fun)
                        return {
                            table_name = table_name,
                            quote = quote_fun,
                            create = function(self, attrs)
                                attrs_arg = helpers.shallowcopy(attrs)
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
                assert.are.same("id", Model.__id_col)
            end)

            it("may use table_name .. '_id' as primary key", function()
                Model = SqlOrm.define_model(MySql, 'users', true)
                assert.are.same("users_id", Model.__id_col)
            end)

            it("may use an arbitrary column as primary key", function()
                Model = SqlOrm.define_model(MySql, 'users', 'my_primary_column')
                assert.are.same("my_primary_column", Model.__id_col)
            end)

            it("calls execute_and_return_last_id with the correct params", function()
                Model.create({ first_name = 'roberto', last_name = 'gin' })
                assert.are.same("SQL CREATE", sql_arg)
            end)

            it("returns a new model", function()
                local model = Model.create({ first_name = 'roberto', last_name = 'gin' })
                assert.are.same({ id = 10, first_name = 'roberto', last_name = 'gin' }, model)
            end)

            it("returns a new model with table name based id", function()
                Model = SqlOrm.define_model(MySql, 'users', true)
                local model = Model.create({ first_name = 'roberto', last_name = 'gin' })
                assert.are.same({ users_id = 10, first_name = 'roberto', last_name = 'gin' }, model)
            end)

            it("returns a new model with arbitrary id", function()
                Model = SqlOrm.define_model(MySql, 'users', 'my_primary_column')
                local model = Model.create({ first_name = 'roberto', last_name = 'gin' })
                assert.are.same({ my_primary_column = 10, first_name = 'roberto', last_name = 'gin' }, model)
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
                assert.are.same({ first_name = 'roberto', last_name = 'gin' }, roberto)
                local hedy = models[2]
                assert.are.same({ first_name = 'hedy', last_name = 'tonic' }, hedy)
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
                    return { 'first model' }
                end
            end)

            after_each(function()
                attrs_arg = nil
                options_arg = nil
            end)

            describe("when called without options", function()
                it("calls .where with limit 1", function()
                    local model = Model.find_by({ first_name = 'roberto' })

                    assert.are.same({ first_name = 'roberto' }, attrs_arg)
                    assert.are.same({ limit = 1 }, options_arg)
                    assert.are.same("first model", model)
                end)
            end)

            describe("when called with options", function()
                it("calls .where with limit 1 keeping only the order option", function()
                    local model = Model.find_by({ first_name = 'roberto' }, { limit = 10, offset = 5, order = "first_name DESC" })

                    assert.are.same({ first_name = 'roberto' }, attrs_arg)
                    assert.are.same({ limit = 1, order = "first_name DESC" }, options_arg)
                    assert.are.same("first model", model)
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

        describe(".delete_all", function()
            before_each(function()
                Model = SqlOrm.define_model(MySql, 'users')
                Model.delete_where = function(...)
                    attrs_arg, options_arg = ...
                    return 10
                end
            end)

            after_each(function()
                attrs_arg = nil
                options_arg = nil
            end)

            it("calls where with the correct options", function()
                local result = Model.delete_all("options")

                assert.are.same({}, attrs_arg)
                assert.are.same("options", options_arg)
                assert.are.same(10, result)
            end)
        end)

        describe(".update_where", function()
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
                            update_where = function(self, ...)
                                attrs_arg, options_arg = ...
                                return "SQL UPDATE WHERE"
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
                Model.update_where({ first_name = 'roberto', last_name = 'gin' }, "options")
                assert.are.same({ first_name = 'roberto', last_name = 'gin' }, attrs_arg)
                assert.are.same("options", options_arg)
            end)

            it("calls execute with the correct params", function()
                Model.update_where({ first_name = 'roberto', last_name = 'gin' })
                assert.are.same("SQL UPDATE WHERE", sql_arg)
            end)

            it("returns the result", function()
                local result = Model.update_where() -- params are stubbed in the execute return
                assert.are.equal(1, result)
            end)
        end)

        describe("#save", function()
            before_each(function()
                Model = SqlOrm.define_model(MySql, 'users')
            end)

            after_each(function()
                attrs_arg = nil
                options_arg = nil
            end)

            describe("when the instance is already saved", function()
                before_each(function()
                    Model.update_where = function(attrs, options)
                        attrs_arg = helpers.shallowcopy(attrs)
                        options_arg = options
                        return 1
                    end
                    model = Model.new({ id = 4, first_name = 'roberto', last_name = 'gin' })
                end)

                after_each(function()
                    model = nil
                end)

                it("calls update_where with the the correct parameters", function()
                    local result = model:save()

                    assert.are.same({ first_name = 'roberto', last_name = 'gin' }, attrs_arg)
                    assert.are.same({ id = 4 }, options_arg)
                    assert.are.same(1, result)
                end)
            end)

            describe("when the instance has not been saved yet", function()
                before_each(function()
                    Model.create = function(attrs)
                        attrs_arg = helpers.shallowcopy(attrs)
                        attrs.id = 12
                        return attrs
                    end
                    model = Model.new({ first_name = 'roberto', last_name = 'gin' })
                end)

                after_each(function()
                    model = nil
                end)

                it("calls create with the the correct parameters", function()
                    model:save()

                    assert.are.same({ first_name = 'roberto', last_name = 'gin' }, attrs_arg)
                    assert.are.same(12, model.id)
                end)
            end)
        end)

        describe("#delete", function()
            before_each(function()
                Model = SqlOrm.define_model(MySql, 'users')
                Model.delete_where = function(attrs, options)
                    attrs_arg = helpers.shallowcopy(attrs)
                    options_arg = options
                    return 1
                end
            end)

            after_each(function()
                attrs_arg = nil
                options_arg = nil
            end)

            describe("when the instance is persisted", function()
                before_each(function()
                    model = Model.new({ id = 4, first_name = 'roberto', last_name = 'gin' })
                end)

                after_each(function()
                    model = nil
                end)

                it("calls delete_where with the the correct parameters", function()
                    local result = model:delete()

                    assert.are.same({ id = 4 }, attrs_arg)
                    assert.are.same(nil, options_arg)
                    assert.are.same(1, result)
                end)
            end)

            describe("when the instance is not persisted", function()
                before_each(function()
                    model = Model.new({ first_name = 'roberto', last_name = 'gin' })
                end)

                after_each(function()
                    model = nil
                end)

                it("returns an error", function()
                    local ok, err = pcall(function() return model:delete() end)

                    assert.are.equal(false, ok)
                    assert.are.equal(true, string.find(err, "cannot delete a model without an id") > 0)
                end)
            end)
        end)
    end)
end)

require 'spec.spec_helper'

describe("MySql ORM", function()
    before_each(function()
        db = {
            execute = function(self, sql)
                query = sql
                return { { first_name = 'zebra' } }
            end,
            get_last_id = function(...) return 10 end,
            quote = function(self, str) return "'q-" .. str .. "'" end,
            column_names = function(self, table_name)
                if table_name == 'users' then
                    return { 'id', 'first_name', 'last_name', 'seen_at', 'age' }
                end
            end
        }
        orm = require 'zebra.db.sql.mysql.orm'
        Model = orm.define(db, 'users')
    end)

    after_each(function()
        ngx = nil
        orm = nil
        User = nil
        db = nil
        query = nil
        Model = nil
    end)

    describe(".define", function()
        it("return the model", function()
            assert.are_not.equals(nil, Model)
        end)
    end)

    describe(".attributes", function()
        it("returns the models attributes", function()
            assert.are.same({ 'id', 'first_name', 'last_name', 'seen_at', 'age' }, Model.attributes())
        end)
    end)

    describe("#attributes", function()
        it("returns the models attributes", function()
            local model = Model.new()
            assert.are.same({ 'id', 'first_name', 'last_name', 'seen_at', 'age' }, model:attributes())
        end)
    end)

    describe(".create", function()
        describe("when attrs are specified", function()
            it("creates a new entry with only the db attributes", function()
                Model.create({ first_name = 'roberto', last_name = 'zebra', age = 3, seen_at = '2013-10-12T16:31:21 UTC', not_in_db = 35 })

                assert.are.equal("INSERT INTO users (first_name,last_name,seen_at,age) VALUES ('q-roberto','q-zebra','q-2013-10-12T16:31:21 UTC',3);", query)
            end)

            it("returns a new model", function()
                local model = Model.create({ first_name = 'roberto', last_name = 'zebra', age = 3, seen_at = '2013-10-12T16:31:21 UTC', not_in_db = 35 })

                assert.are.equal(10, model.id)
                assert.are.equal('roberto', model.first_name)
                assert.are.equal('zebra', model.last_name)
                assert.are.equal(3, model.age)
                assert.are.equal('2013-10-12T16:31:21 UTC', model.seen_at)
                assert.are.equal(35, model.not_in_db)
            end)
        end)

        describe("when no attrs are specified", function()
            it("raises an error", function()
                ok, err = pcall(function() return Model.create() end)

                assert.are.equal(false, ok)
                assert.are.equal(true, string.find(err, "no attributes were specified to create new model instance") > 0)
            end)
        end)
    end)

    describe(".where", function()
        it("return models objects", function()
            db.execute = function(...)
                return { { first_name = 'roberto' }, { first_name = 'hedy' } }
            end

            Model = orm.define(db, 'users')

            local models = Model.where({ seen_at = '2013-10-12T16:31:21 UTC' })
            local model_1 = models[1]
            local model_2 = models[2]

            assert.are.equal('roberto', model_1.first_name)
            assert.are.equal('hedy', model_2.first_name)
            assert.are.equal(Model, model_1.class())
            assert.are.equal(Model, model_2.class())
        end)

        describe("when attrs are specified", function()
            describe("when no options are specified", function()
                it("finds and returns models without options", function()
                    Model.where({ first_name = 'roberto', last_name = 'zebra', age = 3, seen_at = '2013-10-12T16:31:21 UTC' })
                    assert.are.equal("SELECT * FROM users WHERE (seen_at='q-2013-10-12T16:31:21 UTC',last_name='q-zebra',first_name='q-roberto',age=3);", query)
                end)
            end)

            describe("when the limit option is specified", function()
                it("finds models with limit", function()
                    Model.where({ first_name = 'roberto'}, { limit = 12 })
                    assert.are.equal("SELECT * FROM users WHERE (first_name='q-roberto') LIMIT 12;", query)
                end)
            end)

            describe("when the offset option is specified", function()
                it("finds models with offset", function()
                    Model.where({ first_name = 'roberto'}, { offset = 10 })
                    assert.are.equal("SELECT * FROM users WHERE (first_name='q-roberto') OFFSET 10;", query)
                end)
            end)

            describe("when the order option is specified", function()
                it("order model results", function()
                    Model.where({ first_name = 'roberto'}, { order = "first_name DESC" })
                    assert.are.equal("SELECT * FROM users WHERE (first_name='q-roberto') ORDER BY first_name DESC;", query)
                end)
            end)

            describe("when the order, limit and offset options are specified", function()
                it("finds models with offset", function()
                    Model.where({ first_name = 'roberto'}, { order = "first_name DESC", limit = 12, offset = 10 })
                    assert.are.equal("SELECT * FROM users WHERE (first_name='q-roberto') ORDER BY first_name DESC LIMIT 12 OFFSET 10;", query)
                end)
            end)
        end)

        describe("when no attrs are specified", function()
            describe("when no options are specified", function()
                it("finds all models", function()
                    Model.where()
                    assert.are.equal("SELECT * FROM users;", query)
                end)
            end)

            describe("when the limit option is specified", function()
                it("finds models with limit", function()
                    Model.where({}, { limit = 12 })
                    assert.are.equal("SELECT * FROM users LIMIT 12;", query)
                end)
            end)

            describe("when the offset option is specified", function()
                it("finds models with offset", function()
                    Model.where({}, { offset = 10 })
                    assert.are.equal("SELECT * FROM users OFFSET 10;", query)
                end)
            end)

            describe("when the order option is specified", function()
                it("order model results", function()
                    Model.where({}, { order = "first_name DESC" })
                    assert.are.equal("SELECT * FROM users ORDER BY first_name DESC;", query)
                end)
            end)

            describe("when the order, limit and offset options are specified", function()
                it("finds models with offset", function()
                    Model.where({ }, { order = "first_name DESC", limit = 12, offset = 10 })
                    assert.are.equal("SELECT * FROM users ORDER BY first_name DESC LIMIT 12 OFFSET 10;", query)
                end)
            end)
        end)
    end)

    describe(".delete_where", function()
        describe("when attrs are specified", function()
            describe("when no options are specified", function()
                it("deletes the models", function()
                    Model.delete_where({ first_name = 'roberto', last_name = 'zebra', age = 3, seen_at = '2013-10-12T16:31:21 UTC' })
                    assert.are.equal("DELETE FROM users WHERE (seen_at='q-2013-10-12T16:31:21 UTC',last_name='q-zebra',first_name='q-roberto',age=3);", query)
                end)
            end)

            describe("when the limit option is specified", function()
                it("delete models with limit", function()
                    Model.delete_where({ first_name = 'roberto'}, { limit = 12 })
                    assert.are.equal("DELETE FROM users WHERE (first_name='q-roberto') LIMIT 12;", query)
                end)
            end)
        end)

        describe("when attrs are not specified", function()
            describe("when no options are specified", function()
                it("deletes the models", function()
                    Model.delete_where()
                    assert.are.equal("DELETE FROM users;", query)
                end)
            end)

            describe("when the limit option is specified", function()
                it("delete models with limit", function()
                    Model.delete_where({}, { limit = 12 })
                    assert.are.equal("DELETE FROM users LIMIT 12;", query)
                end)
            end)
        end)
    end)

    describe(".all", function()
        it("returns the .where models", function()
            local options = { offset = 10 }
            db.execute = function(...)
                return { { first_name = 'roberto' }, { first_name = 'hedy' } }
            end

            Model = orm.define(db, 'users')

            spy.on(Model, 'where')

            local models = Model.all(options)
            assert.spy(Model.where).was_called_with({}, options)

            Model.where:revert()

            assert.are.equal('roberto', models[1].first_name)
            assert.are.equal('hedy', models[2].first_name)
            assert.are.equal(Model, models[1].class())
            assert.are.equal(Model, models[2].class())
        end)
    end)

    describe(".delete_all", function()
        it("deletes the .delete_where models", function()
            local options = { limit = 10 }
            spy.on(Model, 'delete_where')

            local models = Model.delete_all(options)
            assert.spy(Model.delete_where).was_called_with({}, options)

            Model.delete_where:revert()
        end)
    end)

    describe(".find_by", function()
        describe("when called without options", function()
            it("returns the .where first result model", function()
                db.execute = function(...)
                    return { { first_name = 'roberto' }, { first_name = 'hedy' } }
                end
                Model = orm.define(db, 'users')

                spy.on(Model, 'where')

                local model = Model.find_by({ id = 15 })
                assert.spy(Model.where).was_called_with({ id = 15 }, { limit = 1 })

                Model.where:revert()

                assert.are.equal('roberto', model.first_name)
                assert.are.equal(Model, model.class())
            end)
        end)

        describe("when called with options", function()
            it("returns the .where first result model keeping only the where option", function()
                local options = { limit = 10, offset = 5, order = "first_name DESC" }
                db.execute = function(...)
                    return { { first_name = 'roberto' }, { first_name = 'hedy' } }
                end
                Model = orm.define(db, 'users')

                spy.on(Model, 'where')

                local model = Model.find_by({ id = 15 }, options)
                assert.spy(Model.where).was_called_with({ id = 15 }, { limit = 1, order = "first_name DESC" })

                Model.where:revert()

                assert.are.equal('roberto', model.first_name)
                assert.are.equal(Model, model.class())
            end)
        end)
    end)

    describe(".new", function()
        it("returns a new instance of a model", function()
            local model = Model.new({ first_name = 'roberto', last_name = 'zebra' })

            assert.are.equal('roberto', model.first_name)
            assert.are.equal('zebra', model.last_name)
        end)
    end)

    describe("#save", function()
        describe("when an id is specified", function()
            it("saves the model with only the db attributes", function()
                local model = Model.new({ id = 1, first_name = 'roberto', last_name = 'zebra', not_in_db = 35 })
                model:save()

                assert.are.equal("UPDATE users SET last_name='q-zebra',first_name='q-roberto' WHERE id=1;", query)
            end)
        end)

        describe("when an id is not specified", function()
            it("creates a new model and sets the id", function()
                Model.create = function(...)
                    return 123
                end

                local model = Model.new({ first_name = 'roberto', last_name = 'zebra' })
                model:save()

                assert.are.same({ id = 123, first_name = 'roberto', last_name = 'zebra' }, model)
            end)
        end)
    end)

    describe("#delete", function()
        describe("when an id is specified", function()
            it("deletes the model", function()
                local model = Model.new({ id = 1, first_name = 'roberto', last_name = 'zebra' })
                model:delete()

                assert.are.equal("DELETE FROM users WHERE id=1;", query)
            end)
        end)

        describe("when an id is not specified", function()
            it("raises an error", function()
                local model = Model.new({ first_name = 'roberto', last_name = 'zebra' })
                ok, err = pcall(function() return model:delete() end)

                assert.are.equal(false, ok)
                assert.are.equal(true, string.find(err, "cannot delete a model without an id") > 0)
            end)
        end)
    end)
end)

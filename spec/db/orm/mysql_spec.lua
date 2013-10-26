require 'spec.spec_helper'

describe("MySql ORM", function()
    before_each(function()
        ngx = {
            quote_sql_str = function(str) return "'q-" .. str .. "'" end
        }
        db = {
            execute = function(self, sql)
                if sql == "SELECT LAST_INSERT_ID() AS id;" then return {{ id = "10" }} end
                query = sql
                return { { first_name = 'ralis' } }
            end
        }
        orm = require 'ralis.db.orm.mysql'
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

    describe(".execute", function()
        it("calls the database", function()
            Model.execute("SELECT 1;")
            assert.are.equal("SELECT 1;", query)
        end)
    end)

    describe(".create", function()
        describe("when attrs are specified", function()
            it("creates a new entry", function()
                Model.create({ first_name = 'roberto', last_name = 'ralis', age = 3, seen_at = '2013-10-12T16:31:21 UTC' })

                assert.are.equal("INSERT INTO users (seen_at,last_name,first_name,age) VALUES ('q-2013-10-12T16:31:21 UTC','q-ralis','q-roberto',3);", query)
            end)

            it("returns a new model", function()
                local model = Model.create({ first_name = 'roberto', last_name = 'ralis', age = 3, seen_at = '2013-10-12T16:31:21 UTC' })

                assert.are.equal(10, model.id)
                assert.are.equal('roberto', model.first_name)
                assert.are.equal('ralis', model.last_name)
                assert.are.equal(3, model.age)
                assert.are.equal('2013-10-12T16:31:21 UTC', model.seen_at)
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
            db = {
                execute = function(...)
                    return { { first_name = 'roberto' }, { first_name = 'hedy' } }
                end
            }
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
            describe("when no option are specified", function()
                it("finds and returns models without options", function()
                    Model.where({ first_name = 'roberto', last_name = 'ralis', age = 3, seen_at = '2013-10-12T16:31:21 UTC' })
                    assert.are.equal("SELECT * FROM users WHERE (seen_at='q-2013-10-12T16:31:21 UTC',last_name='q-ralis',first_name='q-roberto',age=3);", query)
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

            describe("when the limit and offset options are specified", function()
                it("finds models with offset", function()
                    Model.where({ first_name = 'roberto'}, { limit = 12, offset = 10 })
                    assert.are.equal("SELECT * FROM users WHERE (first_name='q-roberto') LIMIT 12 OFFSET 10;", query)
                end)
            end)
        end)

        describe("when no attrs are specified", function()
            describe("when no option are specified", function()
                it("finds all models", function()
                    Model.where()
                    assert.are.equal("SELECT * FROM users;", query)
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

            describe("when the limit and offset options are specified", function()
                it("finds models with offset", function()
                    Model.where({ first_name = 'roberto'}, { limit = 12, offset = 10 })
                    assert.are.equal("SELECT * FROM users WHERE (first_name='q-roberto') LIMIT 12 OFFSET 10;", query)
                end)
            end)
        end)
    end)

    describe(".all", function()
        it("returns the .where models", function()
            db = {
                execute = function(...)
                    return { { first_name = 'roberto' }, { first_name = 'hedy' } }
                end
            }
            Model = orm.define(db, 'users')

            spy.on(Model, 'where')

            local models = Model.all()
            assert.spy(Model.where).was_called_with()

            Model.where:revert()

            assert.are.equal('roberto', models[1].first_name)
            assert.are.equal('hedy', models[2].first_name)
            assert.are.equal(Model, models[1].class())
            assert.are.equal(Model, models[2].class())
        end)
    end)

    describe(".find_by", function()
        it("returns the .where first result model", function()
            db = {
                execute = function(...)
                    return { { first_name = 'roberto' }, { first_name = 'hedy' } }
                end
            }
            Model = orm.define(db, 'users')

            spy.on(Model, 'where')

            local model = Model.find_by({ id = 15 })
            assert.spy(Model.where).was_called_with({ id = 15 }, { limit = 1 })

            Model.where:revert()

            assert.are.equal('roberto', model.first_name)
            assert.are.equal(Model, model.class())
        end)
    end)

    describe(".new", function()
        it("returns a new instance of a model", function()
            local model = Model.new({ first_name = 'roberto', last_name = 'ralis' })

            assert.are.equal('roberto', model.first_name)
            assert.are.equal('ralis', model.last_name)
        end)
    end)

    describe("#save", function()
        describe("when an id is specified", function()
            it("saves the model", function()
                local model = Model.new({ id = 1, first_name = 'roberto', last_name = 'ralis' })
                model:save()

                assert.are.equal("UPDATE users SET last_name='q-ralis',first_name='q-roberto' WHERE id=1;", query)
            end)
        end)

        describe("when an id is not specified", function()
            it("creates a new model", function()
                local attrs
                Model.create = function(...)
                    attrs = ...
                end

                local model = Model.new({ first_name = 'roberto', last_name = 'ralis' })
                model:save()

                assert.are.same(attrs, { first_name = 'roberto', last_name = 'ralis' })
            end)
        end)
    end)
end)

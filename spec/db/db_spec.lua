require 'spec.spec_helper'

describe("Database", function()
    before_each(function()
        db = require 'ralis.db.db'
        options = {
            adapter = 'mysql',
            host = "127.0.0.1",
            port = 3306,
            database = "ralis_development",
            user = "root",
            password = "",
            pool = 5
        }
        package.loaded['ralis.db.adapters.mysql'] = {}
        package.loaded['ralis.db.orm.mysql'] = {}
    end)

    after_each(function()
        db = nil
        options = nil
        package.loaded['ralis.db.adapters.mysql'] = nil
        package.loaded['ralis.db.orm.mysql'] = nil
        package.loaded['ralis.db.db'] = nil
    end)

    describe(".new", function()
        before_each(function()
            package.loaded['ralis.db.adapters.mysql'] = { name = 'adapter' }
            package.loaded['ralis.db.orm.mysql'] = { name = 'orm' }
        end)

        describe("when all the required options are passed", function()
            it("initializes an instance", function()
                local DB = db.new(options)

                assert.are.equal(options, DB.options)
                assert.are.equal('adapter', DB.adapter.name)
                assert.are.equal('orm', DB.orm.name)
            end)
        end)

        describe("when not all the required options are passed", function()
            it("raises an error", function()
                options = {
                    adapter = 'mysql',
                    host = "127.0.0.1",
                    user = "root",
                    password = "",
                    pool = 5
                }

                ok, err = pcall(function() return db.new(options) end)
                assert.are.equal(false, ok)
                assert.are.not_equals(true, string.match(err, "missing required database options: database, port"))
            end)
        end)
    end)

    describe(".execute", function()
        before_each(function()
            arg1, arg2 = nil, nil
            package.loaded['ralis.db.adapters.mysql'] = {
                execute = function(...) arg1, arg2 = ... end
            }
            DB = db.new(options)
        end)

        after_each(function()
            arg1 = nil
            arg2 = nil
            DB = nil
        end)

        it("calls execute on the adapter", function()
            local sql = "SELECT 1"

            DB:execute(sql)

            assert.are.same(options, arg1)
            assert.are.same(sql, arg2)
        end)

    end)

    describe(".define", function()
        before_each(function()
            arg1, arg2, arg3 = nil, nil, nil
            package.loaded['ralis.db.orm.mysql'] = {
                define = function(...) arg1, arg2 = ... end
            }
            DB = db.new(options)
        end)

        after_each(function()
            arg1 = nil
            arg2 = nil
            arg3 = nil
            DB = nil
        end)

        it("calls execute on the adapter", function()
            DB:define('users')

            assert.are.same(DB, arg1)
            assert.are.same('users', arg2)
        end)
    end)
end)

require 'spec.spec_helper'

describe("Database SQL", function()
    before_each(function()
        db = require 'ralis.db.sql'
        options = {
            adapter = 'mysql',
            host = "127.0.0.1",
            port = 3306,
            database = "ralis_development",
            user = "root",
            password = "",
            pool = 5
        }
        package.loaded['ralis.db.sql.mysql.adapter'] = {}
        package.loaded['ralis.db.sql.mysql.orm'] = {}
    end)

    after_each(function()
        db = nil
        options = nil
        package.loaded['ralis.db.sql.mysql.adapter'] = nil
        package.loaded['ralis.db.sql.mysql.orm'] = nil
        package.loaded['ralis.db.sql'] = nil
    end)

    describe(".new", function()
        before_each(function()
            package.loaded['ralis.db.sql.mysql.adapter'] = { name = 'adapter' }
            package.loaded['ralis.db.sql.mysql.orm'] = { name = 'orm' }
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
            package.loaded['ralis.db.sql.mysql.adapter'] = {
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

    describe(".tables", function()
        before_each(function()
            arg1 = nil
            package.loaded['ralis.db.sql.mysql.adapter'] = {
                tables = function(...) arg1 = ... end
            }
            DB = db.new(options)
        end)

        after_each(function()
            arg1 = nil
            DB = nil
        end)

        it("calls tables on the adapter", function()
            DB:tables()
            assert.are.same(options, arg1)
        end)
    end)

    describe(".get_last_id", function()
        before_each(function()
            arg1 = nil
            package.loaded['ralis.db.sql.mysql.adapter'] = {
                get_last_id = function(...) arg1 = ... end
            }
            DB = db.new(options)
        end)

        after_each(function()
            arg1 = nil
            DB = nil
        end)

        it("calls get_last_id on the adapter", function()
            DB:get_last_id()
            assert.are.same(options, arg1)
        end)
    end)

    describe(".schema", function()
        before_each(function()
            arg1 = nil
            package.loaded['ralis.db.sql.mysql.adapter'] = {
                schema = function(...) arg1 = ... end
            }
            DB = db.new(options)
        end)

        after_each(function()
            arg1 = nil
            DB = nil
        end)

        it("calls get_last_id on the adapter", function()
            DB:schema()
            assert.are.same(options, arg1)
        end)
    end)

    describe(".define", function()
        before_each(function()
            arg1, arg2, arg3 = nil, nil, nil
            package.loaded['ralis.db.sql.mysql.orm'] = {
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

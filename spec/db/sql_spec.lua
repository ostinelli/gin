require 'spec.spec_helper'

describe("Database SQL", function()
    before_each(function()
        ngx = {
            req = {
                socket = function() return true end
            }
        }

        db = require 'zebra.db.sql'
        options = {
            adapter = 'mysql',
            host = "127.0.0.1",
            port = 3306,
            database = "zebra_development",
            user = "root",
            password = "",
            pool = 5
        }

        package.loaded['resty.mysql'] = {}
        package.loaded['DBI'] = {}

        package.loaded['zebra.db.sql.mysql.adapter_embedded'] = {}
        package.loaded['zebra.db.sql.mysql.adapter_detached'] = {}
        package.loaded['zebra.db.sql.mysql.orm'] = {}
    end)

    after_each(function()
        ngx = nil
        db = nil
        options = nil

        package.loaded['resty.mysql'] = nil
        package.loaded['DBI'] = nil

        package.loaded['zebra.db.sql.mysql.adapter_embedded'] = nil
        package.loaded['zebra.db.sql.mysql.adapter_detached'] = nil
        package.loaded['zebra.db.sql.mysql.orm'] = nil
        package.loaded['zebra.db.sql'] = nil
    end)

    describe(".new", function()
        before_each(function()
            package.loaded['zebra.db.sql.mysql.adapter_embedded'] = { name = 'adapter_embedded' }
            package.loaded['zebra.db.sql.mysql.adapter_detached'] = { name = 'adapter_detached' }
            package.loaded['zebra.db.sql.mysql.orm'] = { name = 'orm' }
        end)

        describe("when all the required options are passed", function()
            it("initializes an instance", function()
                local DB = db.new(options)

                assert.are.equal(options, DB.options)
                assert.are.equal('adapter_detached', DB.adapter_detached.name)
                assert.are.equal('adapter_embedded', DB.adapter_embedded.name)
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

    describe(".define", function()
        before_each(function()
            arg1, arg2, arg3 = nil, nil, nil
            package.loaded['zebra.db.sql.mysql.orm'] = {
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
            DB:define('model')

            assert.are.same('model', arg1)
        end)
    end)

    describe("#adapter", function()
        before_each(function()
            DB = db.new(options)
        end)

        after_each(function()
            DB = nil
        end)

        describe("when adapter_embedded, adapter_detached and cosocket are available", function()
            before_each(function()
                DB.adapter_embedded = 'adapter_embedded'
                DB.adapter_detached = 'adapter_detached'
                ngx.req.socket = function() return 1 end
            end)

            it("returns adapter_embedded", function()
                assert.are.same('adapter_embedded', DB:adapter())
            end)
        end)

        describe("when adapter_embedded, adapter_detached are available but cosocket isn't", function()
            before_each(function()
                DB.adapter_embedded = 'adapter_embedded'
                DB.adapter_detached = 'adapter_detached'
                ngx.req.socket = function() return nil end
            end)

            it("returns adapter_detached", function()
                assert.are.same('adapter_detached', DB:adapter())
            end)
        end)

        describe("when adapter_embedded is not available but adapter_detached is", function()
            before_each(function()
                DB.adapter_embedded = nil
                DB.adapter_detached = 'adapter_detached'
            end)

            it("returns adapter_detached", function()
                assert.are.same('adapter_detached', DB:adapter())
            end)
        end)

        describe("when no adapter is available", function()
            before_each(function()
                DB.adapter_embedded = nil
                DB.adapter_detached = nil
            end)

            it("raises an error", function()
                local ok, err = pcall(function() return DB:adapter() end)

                assert.are.same(false, ok)
                assert.are.equal(true, string.find(err, "Cannot run SQL operation as the") > 0)
            end)
        end)
    end)

    describe("#quote", function()
        before_each(function()
            arg1 = nil
            package.loaded['zebra.db.sql.mysql.adapter_embedded'] = {
                quote = function(...) arg1, arg2 = ... end
            }
            DB = db.new(options)
        end)

        after_each(function()
            arg1 = nil
            DB = nil
        end)

        it("calls quote on the adapter", function()
            DB:quote("zebra")

            assert.are.same(options, arg1)
            assert.are.same("zebra", arg2)
        end)
    end)

    describe("#tables", function()
        before_each(function()
            arg1 = nil
            package.loaded['zebra.db.sql.mysql.adapter_embedded'] = {
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

    describe("#column_names", function()
        before_each(function()
            arg1 = nil
            package.loaded['zebra.db.sql.mysql.adapter_embedded'] = {
                column_names = function(...) arg1 = ... end
            }
            DB = db.new(options)
        end)

        after_each(function()
            arg1 = nil
            DB = nil
        end)

        it("calls column_names on the adapter", function()
            DB:column_names()
            assert.are.same(options, arg1)
        end)
    end)

    describe("#schema", function()
        before_each(function()
            arg1 = nil
            package.loaded['zebra.db.sql.mysql.adapter_embedded'] = {
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

    describe("#get_last_id", function()
        before_each(function()
            arg1 = nil
            package.loaded['zebra.db.sql.mysql.adapter_embedded'] = {
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

    describe("#execute", function()
        before_each(function()
            arg1, arg2 = nil, nil
            package.loaded['zebra.db.sql.mysql.adapter_embedded'] = {
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
end)

require 'spec.spec_helper'


describe("Database SQL", function()
    before_each(function()
        SqlDatabase =  require 'gin.db.sql'

        options = {
            adapter = 'mysql',
            host = "127.0.0.1",
            port = 3306,
            database = "gin_development",
            user = "root",
            password = "",
            pool = 5
        }

        package.loaded['gin.db.sql.mysql.adapter'] = {
            name = 'adapter'
        }
    end)


    after_each(function()
        package.loaded['gin.db.sql'] = nil
        SqlDatabase = nil
        options = nil
        package.loaded['gin.db.sql.mysql.adapter'] = nil
    end)

    describe(".new", function()
        describe("when all the required options are passed", function()
            it("initializes an instance", function()
                local DB = SqlDatabase.new(options)
                assert.are.equal(options, DB.options)
                assert.are.equal('adapter', DB.adapter.name)
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

                local ok, err = pcall(function() return db.new(options) end)
                assert.are.equal(false, ok)
                assert.are.not_equals(true, string.match(err, "missing required database options: database, port"))
            end)
        end)
    end)

    describe("#execute", function()
        before_each(function()
            package.loaded['gin.db.sql.mysql.adapter'].execute = function(...)
                options_arg, sql_arg = ...
            end
        end)

        after_each(function()
            options_arg = nil
            sql_arg = nil
        end)

        it("calls execute on the adapter", function()
            local DB = SqlDatabase.new(options)

            DB:execute("SELECT 1;")

            assert.are.equal(options, options_arg)
            assert.are.equal("SELECT 1;", sql_arg)
        end)
    end)

    describe("#execute_and_return_last_id", function()
        before_each(function()
            package.loaded['gin.db.sql.mysql.adapter'].execute_and_return_last_id = function(...)
                options_arg = ...
            end
        end)

        after_each(function()
            options_arg = nil
        end)

        it("calls execute_and_return_last_id on the adapter", function()
            local DB = SqlDatabase.new(options)

            DB:execute_and_return_last_id()

            assert.are.equal(options, options_arg)
        end)
    end)

    describe("#quote", function()
        before_each(function()
            package.loaded['gin.db.sql.mysql.adapter'].quote = function(...)
                options_arg, str_arg = ...
            end
        end)

        after_each(function()
            options_arg = nil
            str_arg = nil
        end)

        it("calls quote on the adapter", function()
            local DB = SqlDatabase.new(options)

            DB:quote("string")

            assert.are.equal(options, options_arg)
            assert.are.equal("string", str_arg)
        end)
    end)

    describe("#tables", function()
        before_each(function()
            package.loaded['gin.db.sql.mysql.adapter'].tables = function(...)
                options_arg = ...
            end
        end)

        after_each(function()
            options_arg = nil
        end)

        it("calls tables on the adapter", function()
            local DB = SqlDatabase.new(options)

            DB:tables()

            assert.are.equal(options, options_arg)
        end)
    end)

    describe("#schema", function()
        before_each(function()
            package.loaded['gin.db.sql.mysql.adapter'].schema = function(...)
                options_arg = ...
            end
        end)

        after_each(function()
            options_arg = nil
        end)

        it("calls schema on the adapter", function()
            local DB = SqlDatabase.new(options)

            DB:schema()

            assert.are.equal(options, options_arg)
        end)
    end)
end)
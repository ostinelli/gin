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
            name = 'adapter',
            execute = function(...) options_arg, sql_arg = ... end,
            init = function() end
        }

        package.loaded['gin.db.model'] = {
            new = function(...)
                database_arg, table_name_arg = ...
                return 'new-model'
            end
        }
    end)


    after_each(function()
        package.loaded['gin.db.sql'] = nil
        SqlDatabase = nil
        options = nil
        package.loaded['gin.db.sql.mysql.adapter'] = nil
        options_arg = nil
        sql_arg = nil
        database_arg = nil
        table_name_arg = nil
        package.loaded['gin.db.model'] = nil
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

                ok, err = pcall(function() return db.new(options) end)
                assert.are.equal(false, ok)
                assert.are.not_equals(true, string.match(err, "missing required database options: database, port"))
            end)
        end)
    end)

    describe("#execute", function()
        it("calls the execute on the adapter", function()
            local DB = SqlDatabase.new(options)

            DB:execute("SELECT 1;")

            assert.are.equal(options, options_arg)
            assert.are.equal("SELECT 1;", sql_arg)
        end)
    end)
end)
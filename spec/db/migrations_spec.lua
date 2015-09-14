require 'spec.spec_helper'


local create_schema_migrations_sql = [[
CREATE TABLE schema_migrations (
    version varchar(14) NOT NULL,
    PRIMARY KEY (version)
);
]]


describe("Migrations", function()
    before_each(function()
        helper_common = require 'gin.helpers.common'

        helper_common.module_names_in_path = function(path)
            return { 'migration/1', 'migration/2' }
        end

        migrations = require 'gin.db.migrations'

        stub(_G, "pp_to_file")

        queries_1 = {}
        queries_2 = {}

        db_1 = {
            options = {
                adapter = 'mysql',
                database = 'mydb'
            },
            tables = function(...) return {} end,
            schema = function(...) return "" end,
            execute = function(self, q)
                table.insert(queries_1, q)
                return {}
            end
        }

        db_2 = {
            options = {
                adapter = 'mysql',
                database = 'mydb'
            },
            tables = function(...) return { 'schema_migrations' } end,
            schema = function(...) return "" end,
            execute = function(self, q)
                table.insert(queries_2, q)
                return {}
            end
        }

        migration_1 = {
            db = db_1,
            up = function(...)
                db_1:execute("MIGRATION 1 SQL;")
            end
        }

        migration_2 = {
            db = db_2,
            up = function(...)
                db_2:execute("MIGRATION 2 SQL;")
            end,
            down = function(...)
                db_2:execute("ROLLBACK 2 SQL;")
            end
        }

        package.loaded['migration/1'] = migration_1
        package.loaded['migration/2'] = migration_2
    end)

    after_each(function()
        migrations = nil
        helper_common = nil
        package.loaded['gin.db.migrations'] = nil
        package.loaded['migration/1'] = nil
        package.loaded['migration/2'] = nil
        queries_1 = nil
        queries_2 = nil
        db_1 = nil
        db_2 = nil
        migration_1 = nil
        migration_2 = nil
        _G.pp_to_file:revert()
    end)

    describe("up", function()
        describe("when both migrations are run successfully", function()
            it("runs them, creating the database and the schema_migration if necessary", function()
                migrations.up()

                assert.are.same(create_schema_migrations_sql, queries_1[1])
                assert.are.same("SELECT version FROM schema_migrations WHERE version = '1';", queries_1[2])
                assert.are.same("MIGRATION 1 SQL;", queries_1[3])
                assert.are.same("INSERT INTO schema_migrations (version) VALUES ('1');", queries_1[4])

                assert.are.same("SELECT version FROM schema_migrations WHERE version = '2';", queries_2[1])
                assert.are.same("MIGRATION 2 SQL;", queries_2[2])
                assert.are.same("INSERT INTO schema_migrations (version) VALUES ('2');", queries_2[3])
            end)

            it("returns the results", function()
                local ok, response = migrations.up()

                assert.are.equal(true, ok)
                assert.are.same({
                    [1] = { version = '1' },
                    [2] = { version = '2' },
                }, response)
            end)
        end)

        describe("when one version has already been run", function()
            before_each(function()
                migrations.version_already_run = function(_, version)
                    return version == '1'
                end
            end)

            it("skips it", function()
                migrations.up()

                assert.are.same({ create_schema_migrations_sql }, queries_1)

                assert.are.same("MIGRATION 2 SQL;", queries_2[1])
                assert.are.same("INSERT INTO schema_migrations (version) VALUES ('2');", queries_2[2])
            end)

            it("returns the results", function()
                local ok, response = migrations.up()

                assert.are.equal(true, ok)
                assert.are.same({
                    [1] = { version = '2' },
                }, response)
            end)
        end)

        describe("when the database does not exist", function()
            local called_one
            before_each(function()
                called_one = false
                package.loaded['migration/1'].db.tables = function(...)
                    if called_one == false then
                        called_one = true
                        error("Failed to connect to database: Unknown database 'nonexistent-database'")
                    end
                    return {}
                end

                package.loaded['migration/1'].db.adapter = {
                    default_database = 'mysql',
                    db = {
                        close = function() end
                    }
                }
            end)

            after_each(function()
                called_one = nil
            end)

            it("creates it", function()
                migrations.up()

                assert.are.same("CREATE DATABASE mydb;", queries_1[1])
            end)
        end)

        describe("when running a migration with an unsupported adapter", function()
            before_each(function()
                migration_1.db.options.adapter = 'unsupported-adapter'
            end)

            it("stops from migrating subsequent migrations", function()
                migrations.up()

                assert.are.same({}, queries_1)
                assert.are.same({}, queries_2)
            end)

            it("returns an error", function()
                local ok, response = migrations.up()

                err_message = "Cannot run migrations for the adapter 'unsupported-adapter'. Supported adapters are: 'mysql', 'postgresql'."

                assert.are.equal(false, ok)
                assert.are.same({
                    [1] = { version = '1', error = err_message }
                }, response)
            end)
        end)

        describe("when an error occurs in the migration", function()
            before_each(function()
                migration_1.db.execute = function(self, sql)
                    if sql == "MIGRATION 1 SQL;" then error("migration error") end
                    return {}
                end
            end)

            it("returns an error", function()
                local ok, response = migrations.up()

                assert.are.equal(false, ok)

                assert.are.equal(1, #response)
                assert.are.equal('1', response[1].version)
                assert.are.equal(true, string.find(response[1].error, "migration error") > 0)
            end)
        end)
    end)

    describe("down", function()
        describe("when the most recent migration has not been rolled back", function()
            before_each(function()
                migrations.version_already_run = function(_, version)
                    return true
                end
            end)

            describe("and the migration rolls back succesfully", function()
                it("rolls back only the most recent one", function()
                    migrations.down()

                    assert.are.same("ROLLBACK 2 SQL;", queries_2[1])
                    assert.are.same("DELETE FROM schema_migrations WHERE version = '2';", queries_2[2])

                    assert.are.same({}, queries_1)
                end)

                it("returns the results", function()
                    local ok, response = migrations.down()

                    assert.are.equal(true, ok)
                    assert.are.same({
                        [1] = { version = '2' }
                    }, response)
                end)
            end)

            describe("when the database does not exist", function()
                before_each(function()
                    migrations.version_already_run = function(...)
                        error("no database")
                    end
                end)

                it("blows up", function()
                    local ok, err = pcall(function() return migrations.down() end)

                    assert.are.equal(false, ok)
                    assert.are.equal(true, string.find(err, "no database") > 0)
                end)
            end)

            describe("when running a migration with an unsupported adapter", function()
                before_each(function()
                    migration_2.db.options.adapter = 'unsupported-adapter'
                end)

                it("stops the migration", function()
                    migrations.down()

                    assert.are.same({}, queries_1)
                    assert.are.same({}, queries_2)
                end)

                it("returns the results", function()
                    local ok, response = migrations.down()

                    err_message = "Cannot run migrations for the adapter 'unsupported-adapter'. Supported adapters are: 'mysql', 'postgresql'."

                    assert.are.equal(false, ok)
                    assert.are.same({
                        [1] = { version = '2', error = err_message }
                    }, response)
                end)
            end)

            describe("when an error occurs in the migration", function()
                before_each(function()
                    migration_2.db.execute = function() error("migration error") end
                end)

                it("returns an error", function()
                    local ok, response = migrations.down()

                    assert.are.equal(false, ok)

                    assert.are.equal(1, #response)
                    assert.are.equal('2', response[1].version)
                    assert.are.equal(true, string.find(response[1].error, "migration error") > 0)
                end)
            end)
        end)
    end)
end)

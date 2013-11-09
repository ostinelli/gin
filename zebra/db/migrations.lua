-- init with detached adapters
require 'zebra.core.detached'
require 'zebra.core.init'

-- settings
local accepted_adapters = { "mysql" }


local Migrations = {}
Migrations.migrations_table_name = 'schema_migrations'

local create_schema_migrations_sql = [[
CREATE TABLE ]] .. Migrations.migrations_table_name .. [[ (
    version varchar(14) NOT NULL,
    PRIMARY KEY (version)
);
]]

local function ensure_schema_migrations_exists(db)
    local tables = db:tables()
    -- chech if exists
    for _, table_name in pairs(tables) do
        if table_name == Migrations.migrations_table_name then
            -- table found, exit
            return
        end
    end
    -- table does not exist, create
    db:execute(create_schema_migrations_sql)
end

function Migrations.version_already_run(db, version)
    local res = db:execute("SELECT version FROM " .. Migrations.migrations_table_name .. " WHERE version = '" .. version .. "';")
    return #res > 0
end

local function add_version(db, version)
    db:execute("INSERT INTO " .. Migrations.migrations_table_name .. " (version) VALUES ('" .. version .. "');")
end

local function remove_version(db, version)
    db:execute("DELETE FROM " .. Migrations.migrations_table_name .. " WHERE version = '" .. version .. "';")
end

local function version_from(module_name)
    return string.match(module_name, ".*/(.*)")
end

local function dump_schema_for(db)
    local schema_dump_file_path = Zebra.app_dirs.schemas .. '/' .. db.options.adapter .. '-' .. db.options.database .. '.lua'
    local schema = db:schema()
    -- write to file
    pp_to_file(schema, schema_dump_file_path)
end

-- get migration modules
function Migrations.migration_modules()
    local modules = {}

    local path = Zebra.app_dirs.migrations
    if folder_exists(path) then
        for file_name in lfs.dir(path) do
            if file_name ~= "." and file_name ~= ".." then
                local file_path = path .. '/' .. file_name
                local attr = lfs.attributes(file_path)
                assert(type(attr) == "table")
                if attr.mode ~= "directory" then
                    local module_name = get_lua_module_name(file_path)
                    if module_name ~= nil then
                        -- add migration module
                        table.insert(modules, module_name)
                    end
                end
            end
        end
    end

    return modules
end

function Migrations.migration_modules_reverse()
    return table.reverse(Migrations.migration_modules())
end

local function run_migration(direction, module_name)
    local migration_module = require(module_name)
    local db = migration_module.db
    local version = version_from(module_name)

    -- check adapter is supported
    if included(accepted_adapters, db.options.adapter) == false then
        err_message = "Cannot run migrations for the adapter '" .. db.options.adapter .. "'. Supported adapters are: '" .. table.concat(accepted_adapters, "', '") .. "'."
        return false, version, err_message
    end

    ensure_schema_migrations_exists(db)

    -- exit if version already run
    local should_run = direction == "up"
    if Migrations.version_already_run(db, version) == should_run then return end

    -- run migration
    local ok, err = pcall(function() return migration_module[direction]() end)

    if ok == true then
        -- track version
        if direction == "up" then
            add_version(db, version)
        else
            remove_version(db, version)
        end

        -- dump schema
        dump_schema_for(db)
    end

    -- return result
    return ok, version, err
end

local function migrate(direction)
    local response = {}

    -- get modules
    local modules

    if direction == "up" then
        modules = Migrations.migration_modules()
    else
        modules = Migrations.migration_modules_reverse()
    end

    -- loop migration modules & build response
    for _, module_name in ipairs(modules) do
        local ok, version, err = run_migration(direction, module_name)

        if version ~= nil then
            table.insert(response, { version = version, error = err })
        end

        if ok == false then
            -- an error occurred
            return false, response
        end

        if direction == "down" and version ~= nil then break end
    end

    -- return response
    return true, response
end

function Migrations.up()
    return migrate("up")
end

function Migrations.down()
    return migrate("down")
end

return Migrations

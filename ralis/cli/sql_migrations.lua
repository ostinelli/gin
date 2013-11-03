-- settings
local migrations_port = 42579
local nginx_conf_file_path = Ralis.app_dirs.tmp .. '/nginx.conf'
local error_log_file_path = Ralis.app_dirs.logs .. '/ralis-migrations-error.log'

-- dependencies
local http = require 'socket.http'
local url = require 'socket.url'
local lfs = require 'lfs'
local ansicolors = require 'ansicolors'

-- ralis
require 'ralis.core.ralis'
require 'ralis.core.helpers'

local BaseLauncher = require 'ralis.cli.base_launcher'


local migrations_new = [====[
local SqlMigration = {}

-- specify the database used in this migration (needed by the Ralis migration engine)
SqlMigration.db = DB

function SqlMigration.up()
    -- Run your migration, for instance:
    -- SqlMigration.db:execute([[
    --     CREATE TABLE users (
    --         id int NOT NULL AUTO_INCREMENT,
    --         first_name varchar(255) NOT NULL,
    --         last_name varchar(255),
    --         PRIMARY KEY (id)
    --     );
    -- ]])
end

function SqlMigration.down()
    -- Run your rollback, for instance:
    -- SqlMigration.db:execute([[
    --     DROP TABLE users;
    -- ]])
end

return SqlMigration
]====]


local migrations_nginx_conf_template = [[
worker_processes 1;
pid ]] .. Ralis.app_dirs.tmp .. [[/ralis-migrations-nginx.pid;

events {
    worker_connections 1024;
}

http {
    lua_package_path "./?.lua;$prefix/lib/?.lua;#{= LUA_PACKAGE_PATH };;";

    server {
        access_log logs/ralis-migrations-access.log;
        error_log ]] .. error_log_file_path .. [[;

        listen ]] .. migrations_port .. [[;

        location / {
            content_by_lua 'require(\"ralis.db.sql.migration\").run(ngx, "{{DIRECTION}}", "{{MODULE_NAME}}")';
        }
    }
}
]]


-- prepare nginx file contents
local function nginx_conf_content(direction, module_name)
    -- inject params in content
    local nginx_content = migrations_nginx_conf_template
    nginx_content = string.gsub(nginx_content, "{{MODULE_NAME}}", module_name)
    nginx_content = string.gsub(nginx_content, "{{DIRECTION}}", direction)

    return nginx_content
end

-- get migration modules
local function migration_modules()
    local modules = {}

    local path = Ralis.app_dirs.migrations
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

local function migration_modules_reverse()
    return table.reverse(migration_modules())
end

-- remove error log file
local function remove_error_log_file()
    os.remove(error_log_file_path)
end

-- read from error log file
local function read_error_log_file()
    return read_file(error_log_file_path)
end

-- hit server to run migration
local function hit_migration_server(direction, module_name)
    -- init base_launcher
    local base_launcher = BaseLauncher.new(nginx_conf_content(direction, module_name), nginx_conf_file_path)

    -- remove log file
    remove_error_log_file()

    -- start nginx
    base_launcher:start()

    -- call nginx
    local full_url = url.build({
        scheme = 'http',
        host = '127.0.0.1',
        port = migrations_port,
        path = '/'
    })
    local ok, response_status, response_headers = http.request({
        method = 'GET',
        url = full_url,
        redirect = false
    })

    -- stop nginx
    base_launcher:stop()

    return ok, response_status, read_error_log_file()
end

function run_migration(direction, module_name)
    -- run migration for module
    local ok, response_status, error_log = hit_migration_server(direction, module_name)
    if ok == nil then error("An error occurred while connecting to the migration server while running module: " .. module_name) end

    if error_log:len() > 0 then
        -- an error happened
        print(ansicolors("%{red}ERROR:%{reset} An error occurred while running the migration module: " .. module_name))
        print(error_log)
        error()
    end

    -- print success
    local applied = false
    if response_status == 201 then
        applied = true
        print(ansicolors("==> %{green}Applied migration:%{reset} " .. module_name))
    elseif response_status == 200 then
        applied = true
        print(ansicolors("==> %{green}Rollback migration:%{reset} " .. module_name))
    end

    return applied
end


local SqlMigrations = {}

function SqlMigrations.new(name)
    -- define file path
    local timestamp = os.date("%Y%m%d%H%M%S")
    local full_file_path = Ralis.app_dirs.migrations .. '/' .. timestamp .. '.lua'

    -- create file
    local fw = io.open(full_file_path, "w")
    fw:write(migrations_new)
    fw:close()

    -- output message
    print(ansicolors("%{green}Created new migration file%{reset}"))
    print("  " .. full_file_path)
end

function SqlMigrations.migrate()
    -- get list of all migration modules
    local modules = migration_modules()

    for _, module_name in ipairs(modules) do
        run_migration("up", module_name)
    end
end

function SqlMigrations.rollback()
    -- get list of all migration modules
    local modules = migration_modules_reverse()

    for _, module_name in ipairs(modules) do
        local applied = run_migration("down", module_name)
        -- stop rolling back asa one rollback has been applied
        if applied == true then return end
    end
end


return SqlMigrations

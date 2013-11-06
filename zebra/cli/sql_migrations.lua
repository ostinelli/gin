-- settings
local migrations_port = 42579
local nginx_conf_file_path = Zebra.app_dirs.tmp .. '/nginx.conf'
local error_log_file_path = Zebra.app_dirs.logs .. '/zebra-migrations-error.log'

-- dependencies
local http = require 'socket.http'
local url = require 'socket.url'
local lfs = require 'lfs'
local ansicolors = require 'ansicolors'

-- zebra
require 'zebra.core.zebra'
require 'zebra.core.helpers'

local BaseLauncher = require 'zebra.cli.base_launcher'


local migrations_new = [====[
local SqlMigration = {}

-- specify the database used in this migration (needed by the Zebra migration engine)
SqlMigration.db = MYSQLDB

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
pid ]] .. Zebra.app_dirs.tmp .. [[/zebra-migrations-nginx.pid;

events {
    worker_connections 1024;
}

http {
    lua_package_path "./?.lua;$prefix/lib/?.lua;#{= LUA_PACKAGE_PATH };;";

    server {
        access_log logs/zebra-migrations-access.log;
        error_log ]] .. error_log_file_path .. [[;

        listen ]] .. migrations_port .. [[;

        location / {
            content_by_lua 'require(\"zebra.db.sql.migrations\").run(ngx, "{{DIRECTION}}")';
        }
    }
}
]]


-- prepare nginx file contents
local function nginx_conf_content(direction)
    -- inject params in content
    local nginx_content = migrations_nginx_conf_template
    nginx_content = string.gsub(nginx_content, "{{DIRECTION}}", direction)

    return nginx_content
end

-- hit server to run migration
local function hit_migration_server(direction)
    -- init base_launcher
    local base_launcher = BaseLauncher.new(nginx_conf_content(direction), nginx_conf_file_path)

    -- start nginx
    base_launcher:start()

    -- call nginx
    local full_url = url.build({
        scheme = 'http',
        host = '127.0.0.1',
        port = migrations_port,
        path = '/'
    })

    local response_body_raw = {}
    local ok = http.request({
        method = 'GET',
        url = full_url,
        sink = ltn12.sink.table(response_body_raw),
        redirect = false
    })
    response_body_raw = table.concat(response_body_raw, "")
    local response_body = JSON.decode(response_body_raw)

    -- stop nginx
    base_launcher:stop()

    return ok, response_body
end

local function display_result(direction, response_body)
    local error_head, error_message, success_message, symbol

    if direction == "up" then
        error_head = "An error occurred while running the migration:"
        error_message = "More recent migrations have been canceled. Please review the error:"
        success_message = "Successfully applied migration:"
        symbol = "==>"
    else
        error_head = "An error occurred while rolling back the migration:"
        error_message = "Please review the error:"
        success_message = "Successfully rolled back migration:"
        symbol = "<=="
    end

    if #response_body > 0 then
        for k, version_info in ipairs(response_body) do
            if version_info.error ~= nil then
                print(ansicolors("%{red}ERROR:%{reset} " .. error_head .. " %{cyan}" .. version_info.version .. "%{reset}"))
                print(error_message)
                print("-------------------------------------------------------------------")
                print(version_info.error)
                print("-------------------------------------------------------------------")
            else
                print(ansicolors(symbol .. " %{green}" .. success_message .. "%{reset} " .. version_info.version))
            end
        end
    end
end

function migration_do(direction)
    local ok, response_body = hit_migration_server(direction)
    display_result(direction, response_body)
end


local SqlMigrations = {}

function SqlMigrations.new(name)
    -- define file path
    local timestamp = os.date("%Y%m%d%H%M%S")
    local full_file_path = Zebra.app_dirs.migrations .. '/' .. timestamp .. '.lua'

    -- create file
    local fw = io.open(full_file_path, "w")
    fw:write(migrations_new)
    fw:close()

    -- output message
    print(ansicolors("%{green}Created new migration file%{reset}"))
    print("  " .. full_file_path)
end

function SqlMigrations.migrate()
    migration_do("up")
end

function SqlMigrations.rollback()
    migration_do("down")
end

return SqlMigrations

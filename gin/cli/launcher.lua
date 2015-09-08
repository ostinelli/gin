-- dep
local ansicolors = require 'ansicolors'

-- gin
local Gin = require 'gin.core.gin'
local BaseLauncher = require 'gin.cli.base_launcher'
local helpers = require 'gin.helpers.common'

-- settings
local nginx_conf_source = 'config/nginx.conf'


local GinLauncher = {}

-- convert true|false to on|off
local function convert_boolean_to_onoff(value)
    if value == true then value = 'on' else value = 'off' end
    return value
end

-- get application database modules
local function database_modules()
    return helpers.module_names_in_path(Gin.app_dirs.db)
end

-- add upstream for databases
local function gin_init_databases(gin_init)
    local modules = database_modules()

    for _, module_name in ipairs(modules) do
        local db = require(module_name)

        if type(db) == "table" and db.options.adapter == 'postgresql' then
            local name = db.adapter.location_for(db.options)
            gin_init = gin_init .. [[
    upstream ]] .. name .. [[ {
        postgres_server ]] .. db.options.host .. [[:]] .. db.options.port .. [[ dbname=]] .. db.options.database .. [[ user=]] .. db.options.user .. [[ password=]] .. db.options.password .. [[;
    }
]]
        end
    end

    return gin_init
end

-- gin init
local function gin_init(nginx_content)
    -- gin init
    local gin_init = [[
lua_code_cache ]] .. convert_boolean_to_onoff(Gin.settings.code_cache) .. [[;
    lua_package_path "./?.lua;$prefix/lib/?.lua;${LUA_PACKAGE_PATH};;";
]]

    -- add db upstreams
    gin_init = gin_init_databases(gin_init)

    return string.gsub(nginx_content, "{{GIN_INIT}}", gin_init)
end

-- add locations for databases
local function gin_runtime_databases(gin_runtime)
    local modules = database_modules()
    local postgresql_adapter = require 'gin.db.sql.postgresql.adapter'

    for _, module_name in ipairs(modules) do
        local db = require(module_name)

        if type(db) == "table" and db.options.adapter == 'postgresql' then
            local location = postgresql_adapter.location_for(db.options)
            local execute_location = postgresql_adapter.execute_location_for(db.options)

            gin_runtime = gin_runtime .. [[
        location = /]] .. execute_location .. [[ {
            internal;
            postgres_pass   ]] .. location .. [[;
            postgres_query  $echo_request_body;
        }
]]
        end
    end

    return gin_runtime
end

-- gin runtime
local function gin_runtime(nginx_content)
    local gin_runtime = [[
location / {
            content_by_lua 'require(\"gin.core.router\").handler(ngx)';
        }
]]
    if Gin.settings.expose_api_console == true then
        gin_runtime = gin_runtime .. [[
        location /ginconsole {
            content_by_lua 'require(\"gin.cli.api_console\").handler(ngx)';
        }
]]
    end

    -- add db locations
    gin_runtime = gin_runtime_databases(gin_runtime)

    return string.gsub(nginx_content, "{{GIN_RUNTIME}}", gin_runtime)
end


function GinLauncher.nginx_conf_content()
    -- read nginx.conf file
    local nginx_conf_template = helpers.read_file(nginx_conf_source)

    -- append notice
    nginx_conf_template = [[
# ===================================================================== #
# THIS FILE IS AUTO GENERATED. DO NOT MODIFY.                           #
# IF YOU CAN SEE IT, THERE PROBABLY IS A RUNNING SERVER REFERENCING IT. #
# ===================================================================== #

]] .. nginx_conf_template

    -- inject params in content
    local nginx_content = nginx_conf_template
    nginx_content = string.gsub(nginx_content, "{{GIN_PORT}}", Gin.settings.port)
    nginx_content = string.gsub(nginx_content, "{{GIN_ENV}}", Gin.env)

    -- gin imit & runtime
    nginx_content = gin_init(nginx_content)
    nginx_content = gin_runtime(nginx_content)

    -- return
    return nginx_content
end

function nginx_conf_file_path()
    return Gin.app_dirs.tmp .. "/" .. Gin.env .. "-nginx.conf"
end

function base_launcher()
    return BaseLauncher.new(GinLauncher.nginx_conf_content(), nginx_conf_file_path())
end


function GinLauncher.start(env)
    -- init base_launcher
    local ok, base_launcher = pcall(function() return base_launcher() end)

    if ok == false then
        print(ansicolors("%{red}ERROR:%{reset} Cannot initialize launcher: " .. base_launcher))
        return
    end

    result = base_launcher:start(env)

    if result == 0 then
        if Gin.env ~= 'test' then
            print(ansicolors("Gin app in %{cyan}" .. Gin.env .. "%{reset} was succesfully started on port " .. Gin.settings.port .. "."))
        end
    else
        print(ansicolors("%{red}ERROR:%{reset} Could not start Gin app on port " .. Gin.settings.port .. " (is it running already?)."))
    end
end

function GinLauncher.stop(env)
    -- init base_launcher
    local base_launcher = base_launcher()

    result = base_launcher:stop(env)

    if Gin.env ~= 'test' then
        if result == 0 then
            print(ansicolors("Gin app in %{cyan}" .. Gin.env .. "%{reset} was succesfully stopped."))
        else
            print(ansicolors("%{red}ERROR:%{reset} Could not stop Gin app (are you sure it is running?)."))
        end
    end
end

return GinLauncher

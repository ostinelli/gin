-- dep
local ansicolors = require 'ansicolors'

-- gin
local Gin = require 'gin.core.gin'
local BaseLauncher = require 'gin.cli.base_launcher'
local helpers = require 'gin.helpers.common'

-- settings
local nginx_conf_source = 'config/nginx.conf'


local GinLauncher = {}


local function convert_boolean_to_onoff(value)
    if value == true then value = 'on' else value = 'off' end
    return value
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

    -- gin init
    local gin_init = [[
lua_code_cache ]] .. convert_boolean_to_onoff(Gin.settings.code_cache) .. [[;
    lua_package_path "./?.lua;$prefix/lib/?.lua;#{= LUA_PACKAGE_PATH };;";
]]
    nginx_content = string.gsub(nginx_content, "{{GIN_INIT}}", gin_init)

    -- gin runtime
    local gin_runtime = [[
location / {
            content_by_lua 'require(\"gin.core.router\").handler(ngx)';
        }
]]
    if Gin.settings.expose_api_console == true then
        gin_runtime = gin_runtime .. [[
        # Gin console
        location /ginconsole {
            content_by_lua 'require(\"gin.cli.api_console\").handler(ngx)';
        }
]]
    end
    nginx_content = string.gsub(nginx_content, "{{GIN_RUNTIME}}", gin_runtime)

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
        print(ansicolors("%{red}ERROR:%{reset} Cannot initialize launcher (is this a Gin project directory?)."))
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

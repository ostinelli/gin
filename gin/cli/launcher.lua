-- dependencies
local ansicolors = require 'ansicolors'

local Gin = require 'gin.core.gin'
local BaseLauncher = require 'gin.cli.base_launcher'
local Helpers = require 'gin.core.helpers'

-- settings
local nginx_conf_source = 'config/nginx.conf'


local function convert_boolean_to_onoff(value)
    if value == true then value = 'on' else value = 'off' end
    return value
end

local function nginx_conf_content()
    -- read nginx.conf file
    local nginx_conf_template = Helpers.read_file(nginx_conf_source)

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
    nginx_content = string.gsub(nginx_content, "{{GIN_CODE_CACHE}}", convert_boolean_to_onoff(Gin.settings.code_cache))
    -- api console
    local api_console_code = [[content_by_lua 'require(\"gin.cli.api_console\").handler(ngx)';]]

    if Gin.settings.expose_api_console == true then
        nginx_content = string.gsub(nginx_content, "{{GIN_API_CONSOLE}}", api_console_code)
    else
        nginx_content = string.gsub(nginx_content, "{{GIN_API_CONSOLE}}", "")
    end

    return nginx_content
end

function nginx_conf_file_path()
    return Gin.app_dirs.tmp .. "/" .. Gin.env .. "-nginx.conf"
end

function base_launcher()
    return BaseLauncher.new(nginx_conf_content(), nginx_conf_file_path())
end


local GinLauncher = {}

function GinLauncher.start(env)
    -- init base_launcher
    local base_launcher = base_launcher()

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

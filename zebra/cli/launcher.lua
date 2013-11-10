-- dependencies
local ansicolors = require 'ansicolors'

require 'zebra.core.zebra'
local BaseLauncher = require 'zebra.cli.base_launcher'

-- settings
local nginx_conf_source = 'config/nginx.conf'


local function convert_boolean_to_onoff(value)
    if value == true then value = 'on' else value = 'off' end
    return value
end

local function nginx_conf_content()
    -- read nginx.conf file
    local nginx_conf_template = read_file(nginx_conf_source)

    -- append notice
    nginx_conf_template = [[
# ===================================================================== #
# THIS FILE IS AUTO GENERATED. DO NOT MODIFY.                           #
# IF YOU CAN SEE IT, THERE PROBABLY IS A RUNNING SERVER REFERENCING IT. #
# ===================================================================== #

]] .. nginx_conf_template

    -- inject params in content
    local nginx_content = nginx_conf_template
    nginx_content = string.gsub(nginx_content, "{{ZEBRA_PORT}}", Zebra.settings.port)
    nginx_content = string.gsub(nginx_content, "{{ZEBRA_ENV}}", Zebra.env)
    nginx_content = string.gsub(nginx_content, "{{ZEBRA_CODE_CACHE}}", convert_boolean_to_onoff(Zebra.settings.code_cache))
    -- api console
    local api_console_code = [[content_by_lua 'require(\"zebra.cli.api_console\").handler(ngx)';]]

    if Zebra.settings.expose_api_console == true then
        nginx_content = string.gsub(nginx_content, "{{ZEBRA_API_CONSOLE}}", api_console_code)
    else
        nginx_content = string.gsub(nginx_content, "{{ZEBRA_API_CONSOLE}}", "")
    end

    return nginx_content
end

function nginx_conf_file_path()
    return Zebra.app_dirs.tmp .. "/" .. Zebra.env .. "-nginx.conf"
end

function base_launcher()
    return BaseLauncher.new(nginx_conf_content(), nginx_conf_file_path())
end


local ZebraLauncher = {}

function ZebraLauncher.start(env)
    -- init base_launcher
    local base_launcher = base_launcher()

    result = base_launcher:start(env)

    if result == 0 then
        if Zebra.env ~= 'test' then
            print(ansicolors("Zebra app in %{cyan}" .. Zebra.env .. "%{reset} was succesfully started on port " .. Zebra.settings.port .. "."))
        end
    else
        print(ansicolors("%{red}ERROR:%{reset} Could not start Zebra app on port " .. Zebra.settings.port .. " (is it running already?)."))
    end
end

function ZebraLauncher.stop(env)
    -- init base_launcher
    local base_launcher = base_launcher()

    result = base_launcher:stop(env)

    if Zebra.env ~= 'test' then
        if result == 0 then
            print(ansicolors("Zebra app in %{cyan}" .. Zebra.env .. "%{reset} was succesfully stopped."))
        else
            print(ansicolors("%{red}ERROR:%{reset} Could not stop Zebra app (are you sure it is running?)."))
        end
    end
end

return ZebraLauncher

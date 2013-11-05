-- dependencies
local ansicolors = require 'ansicolors'

require 'carb.core.carb'
local BaseLauncher = require 'carb.cli.base_launcher'

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
    nginx_content = string.gsub(nginx_content, "{{CARB_PORT}}", Carb.settings.port)
    nginx_content = string.gsub(nginx_content, "{{CARB_ENV}}", Carb.env)
    nginx_content = string.gsub(nginx_content, "{{CARB_CODE_CACHE}}", convert_boolean_to_onoff(Carb.settings.code_cache))
    -- api console
    local api_console_code = [[content_by_lua 'require(\"carb.cli.api_console\").handler(ngx)';]]

    if Carb.env == 'development' then
        nginx_content = string.gsub(nginx_content, "{{CARB_API_CONSOLE}}", api_console_code)
    else
        nginx_content = string.gsub(nginx_content, "{{CARB_API_CONSOLE}}", "")
    end

    return nginx_content
end

function nginx_conf_file_path()
    return Carb.app_dirs.tmp .. "/" .. Carb.env .. "-nginx.conf"
end

function base_launcher()
    return BaseLauncher.new(nginx_conf_content(), nginx_conf_file_path())
end


local CarbLauncher = {}

function CarbLauncher.start()
    -- init base_launcher
    local base_launcher = base_launcher()

    result = base_launcher:start()

    if result == 0 then
        if Carb.env ~= 'test' then
            print(ansicolors("Carb app in %{cyan}" .. Carb.env .. "%{reset} was succesfully started on port " .. Carb.settings.port .. "."))
        end
    else
        print(ansicolors("%{red}ERROR:%{reset} Could not start Carb app on port " .. Carb.settings.port .. " (is it running already?)."))
    end
end

function CarbLauncher.stop()
    -- init base_launcher
    local base_launcher = base_launcher()

    result = base_launcher:stop()

    if Carb.env ~= 'test' then
        if result == 0 then
            print(ansicolors("Carb app in %{cyan}" .. Carb.env .. "%{reset} was succesfully stopped."))
        else
            print(ansicolors("%{red}ERROR:%{reset} Could not stop Carb app (are you sure it is running?)."))
        end
    end
end

return CarbLauncher

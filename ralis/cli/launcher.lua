require 'ralis.core.ralis'
local bashcolors = require 'ralis.core.bashcolors'

local RalisLauncher = {}
RalisLauncher.nginx_conf_source = 'config/nginx.conf'
RalisLauncher.nginx_conf_tmp_dir = 'tmp'
RalisLauncher.dirs = {
    'logs',
    'tmp'
}

local function convert_boolean_to_onoff(value)
    if value == true then value = 'on' else value = 'off' end
    return value
end

function RalisLauncher.start()
    RalisLauncher.create_dirs()
    RalisLauncher.create_nginx_conf()

    result = RalisLauncher.start_nginx()

    if result == 0 then
        if Ralis.env ~= 'test' then
            print("Ralis app was succesfully started on port " .. Ralis.settings.port .. ' (' .. bashcolors.cyan .. Ralis.env .. bashcolors.reset .. ').')
        end
    else
        print(bashcolors.red .. "ERROR:" .. bashcolors.reset .. " Could not start Ralis app on port " .. Ralis.settings.port .. " (is it running already?).")
    end
end

function RalisLauncher.stop()
    result = RalisLauncher.stop_nginx()

    if Ralis.env ~= 'test' then
        if result == 0 then
            print("Ralis app was succesfully stopped.")
        else
            print(bashcolors.red .. "ERROR:" .. bashcolors.reset .. " Could not stop Ralis app (are you sure it is running?).")
        end
    end
    RalisLauncher.remove_nginx_conf()
end

function RalisLauncher.start_nginx()
    return RalisLauncher.nginx_command('')
end

function RalisLauncher.stop_nginx()
    return RalisLauncher.nginx_command('-s stop')
end

function RalisLauncher.nginx_command(nginx_signal)
    return os.execute("nginx " .. nginx_signal .. " -p `pwd`/ -c " .. RalisLauncher.nginx_conf_file_path() .. " 2>/dev/null")
end

function RalisLauncher.create_dirs()
    for _, dir in pairs(RalisLauncher.dirs) do
        lfs.mkdir(dir)
    end
end

function RalisLauncher.create_nginx_conf()
    -- read nginx.conf file
    local f = io.open(RalisLauncher.nginx_conf_source, "rb")
    local nginx_conf_template = f:read("*all")
    f:close()

    -- append notice
    nginx_conf_template = [[
# ===================================================================== #
# THIS FILE IS AUTO GENERATED. DO NOT MODIFY.                           #
# IF YOU CAN SEE IT, THERE PROBABLY IS A RUNNING SERVER REFERENCING IT. #
# ===================================================================== #

]] .. nginx_conf_template

    -- inject params in content
    local nginx_content = nginx_conf_template
    nginx_content = string.gsub(nginx_content, "{{RALIS_PORT}}", Ralis.settings.port)
    nginx_content = string.gsub(nginx_content, "{{RALIS_ENV}}", Ralis.env)
    nginx_content = string.gsub(nginx_content, "{{RALIS_CODE_CACHE}}", convert_boolean_to_onoff(Ralis.settings.code_cache))

    -- write conf file
    local fw = io.open(RalisLauncher.nginx_conf_file_path(), "w")
    fw:write(nginx_content)
    fw:close()
end

function RalisLauncher.remove_nginx_conf()
    os.remove(RalisLauncher.nginx_conf_file_path())
end

function RalisLauncher.nginx_conf_file_path()
    return RalisLauncher.nginx_conf_tmp_dir .. "/" .. Ralis.env .. "-nginx.conf"
end

return RalisLauncher

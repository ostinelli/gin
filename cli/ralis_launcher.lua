local lfs = require 'lfs'

local RalisLauncher = {}
RalisLauncher.nginx_conf_file_path = "tmp/ralis-nginx.conf"
RalisLauncher.nginx_conf = [[
# ==============================================================
# THIS FILE IS AUTO GENERATED. DO NOT MODIFY.
# IF YOU CAN SEE IT, THERE PROBABLY IS A SERVER REFERENCING IT.
# ==============================================================

worker_processes 1;
error_log logs/error.log;

events {
    worker_connections 16384;
}

http {

    lua_package_path './?.lua;';

    server {
        access_log off;
        listen {{ RALIS_PORT }};

        location / {
            content_by_lua 'require(\"core/router\").handler(ngx)';
        }
    }
}
]]

function RalisLauncher.start()
    RalisLauncher.create_nginx_conf()
    result = os.execute("nginx -p `pwd`/ -c " .. RalisLauncher.nginx_conf_file_path)
    if result == 0 then print("Ralis app was succesfully started.") end
end

function RalisLauncher.stop()
    result = os.execute("nginx -s stop -p `pwd`/ -c " .. RalisLauncher.nginx_conf_file_path)
    if result == 0 then
        print("Ralis app was succesfully stopped.")
    else
        print("ERROR: Could not stop Ralis app (maybe not started?)")
    end
    RalisLauncher.remove_nginx_conf()
end

function RalisLauncher.create_nginx_conf()
    local nginx_dir = RalisLauncher.get_path(RalisLauncher.nginx_conf_file_path)
    lfs.mkdir(nginx_dir)

    local ralis_env = os.getenv("RALIS_ENV")
    local ralis_port = 7200
    if ralis_env == 'test' then ralis_port = 89567 end

    local conf_content = string.gsub(RalisLauncher.nginx_conf, "{{ RALIS_PORT }}", ralis_port)
    local f = io.open(RalisLauncher.nginx_conf_file_path, "w")
    f:write(conf_content)
    f:close()
end

function RalisLauncher.remove_nginx_conf()
    os.remove(RalisLauncher.nginx_conf_file_path)
end

function RalisLauncher.get_path(str)
    return str:match("(.*)/")
end

return RalisLauncher

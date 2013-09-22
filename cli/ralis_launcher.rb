require 'fileutils'

module Ralis

    NGINX_CONF = "
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
"
    class Launcher
        NGINX_CONF_FILE_PATH = "./tmp/ralis-nginx.conf"

        def self.start
            create_nginx_conf
            `nginx -p \`pwd\`/ -c #{NGINX_CONF_FILE_PATH}`
            puts "Ralis app was succesfully started." if $? == 0
        end

        def self.stop
            `nginx -s stop -p \`pwd\`/ -c #{NGINX_CONF_FILE_PATH}`
            if $? == 0
                puts "App was succesfully stopped."
            else
                puts "ERROR: Could not stop Ralis app (maybe not started?)"
            end
            remove_nginx_conf
        end

        private

        def self.create_nginx_conf
            port = case ENV['RALIS_ENV']
                when 'test' then 89567
                else 7200
            end
            conf_content = NGINX_CONF.gsub("{{ RALIS_PORT }}", port.to_s)

            dir = File.dirname(NGINX_CONF_FILE_PATH)
            FileUtils.mkdir_p(dir) unless File.directory?(dir)

            File.open(NGINX_CONF_FILE_PATH, 'w') { |f| f.write(conf_content) }
        end

        def self.remove_nginx_conf
            File.delete(NGINX_CONF_FILE_PATH) if File.exists?(NGINX_CONF_FILE_PATH)
        end
    end
end

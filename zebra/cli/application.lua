local ansicolors = require 'ansicolors'


local pages_controller = [[
local PagesController = {}

function PagesController:root()
    return 200, { message = "Hello world from Zebra!" }
end

return PagesController
]]


local errors = [[
-------------------------------------------------------------------------------------------------------------------
-- Define all of your application errors in here. They should have the format:
--
-- Errors = {
--     [1000] = { status = 400, message = "My Application error.", headers = { ["X-Header"] = "header" } },
-- }
--
-- where:
--     '1000'                is the error number that can be raised from controllers with `self:raise_error(1000)
--     'status'  (required)  is the http status code
--     'message' (required)  is the error description
--     'headers' (optional)  are the headers to be returned in the response
-------------------------------------------------------------------------------------------------------------------

Errors = {}
]]


local application = [[
Application = {
    name = "{{APP_NAME}}",
    version = '0.0.1'
}
]]


db = [[
local sqldb = require 'zebra.db.sql'

-- Here you can setup your databases that will be accessible throughout your application.
-- First, specify the settings (you may add multiple databases with this pattern), for instance:
-- local DbSettings = {
--
--     development = {
--         adapter = 'mysql',
--         host = "127.0.0.1",
--         port = 3306,
--         database = "{{APP_NAME}}_development",
--         user = "root",
--         password = "",
--         pool = 5
--     },
--
--     test = {
--         adapter = 'mysql',
--         host = "127.0.0.1",
--         port = 3306,
--         database = "{{APP_NAME}}_test",
--         user = "root",
--         password = "",
--         pool = 5
--     },
--
--     production = {
--         adapter = 'mysql',
--         host = "127.0.0.1",
--         port = 3306,
--         database = "{{APP_NAME}}_production",
--         user = "root",
--         password = "",
--         pool = 5
--     }
-- }
--
-- Then initialize your database(s), for instance:
-- MYSQLDB = sqldb.new(DbSettings[Zebra.env])
]]


local nginx_config = [[
worker_processes 1;
pid ]] .. Zebra.app_dirs.tmp .. [[/{{ZEBRA_ENV}}-nginx.pid;

events {
    worker_connections 1024;
}

http {
    sendfile on;

    lua_code_cache {{ZEBRA_CODE_CACHE}};
    lua_package_path "./?.lua;$prefix/lib/?.lua;#{= LUA_PACKAGE_PATH };;";

    server {
        access_log ]] .. Zebra.app_dirs.logs .. [[/{{ZEBRA_ENV}}-access.log;
        error_log ]] .. Zebra.app_dirs.logs .. [[/{{ZEBRA_ENV}}-error.log;

        listen {{ZEBRA_PORT}};

        location / {
            content_by_lua 'require(\"zebra.core.router\").handler(ngx)';
        }

        location /zebraconsole {
            {{ZEBRA_API_CONSOLE}}
        }
    }
}
]]


local routes = [[
-- define version
local v1 = Routes.version(1)

-- define routes
v1:GET("/", { controller = "pages", action = "root" })
]]


local settings = [[
--------------------------------------------------------------------------------
-- Settings defined here are environment dependent. Inside of your application,
-- `Zebra.settings` will return the ones that correspond to the environment
-- you are running the server in.
--------------------------------------------------------------------------------

local Settings = {}

Settings.development = {
    code_cache = false,
    port = 7200,
    expose_api_console = true
}

Settings.test = {
    code_cache = true,
    port = 7201,
    expose_api_console = false
}

Settings.production = {
    code_cache = true,
    port = 80,
    expose_api_console = false
}

return Settings
]]


local pages_controller_spec = [[
require 'spec.spec_helper'

describe("PagesController", function()

    describe("#root", function()
        it("responds with a welcome message", function()
            local response = hit({
                method = 'GET',
                path = "/"
            })

            assert.are.same(200, response.status)
            assert.are.same({ message = "Hello world from Zebra!" }, response.body)
        end)
    end)
end)
]]


local spec_helper = [[
require 'zebra.spec.runner'
]]


local ZebraApplication = {}

ZebraApplication.files = {
    ['app/controllers/1/pages_controller.lua'] = pages_controller,
    ['app/models/.gitkeep'] = "",
    ['config/initializers/errors.lua'] = errors,
    ['config/application.lua'] = "",
    ['config/nginx.conf'] = nginx_config,
    ['config/routes.lua'] = routes,
    ['config/settings.lua'] = settings,
    ['db/migrations/.gitkeep'] = "",
    ['db/schemas/.gitkeep'] = "",
    ['db/db.lua'] = "",
    ['lib/.gitkeep'] = "",
    ['spec/controllers/1/pages_controller_spec.lua'] = pages_controller_spec,
    ['spec/models/.gitkeep'] = "",
    ['spec/spec_helper.lua'] = spec_helper
}

function ZebraApplication.new(name)
    print(ansicolors("Creating app %{cyan}" .. name .. "%{reset}..."))

    ZebraApplication.files['config/application.lua'] = string.gsub(application, "{{APP_NAME}}", name)
    ZebraApplication.files['db/db.lua'] = string.gsub(db, "{{APP_NAME}}", name)
    ZebraApplication.create_files(name)
end

function ZebraApplication.create_files(parent)
    for file_path, file_content in pairs(ZebraApplication.files) do
        -- ensure containing directory exists
        local full_file_path = parent .. "/" .. file_path
        mkdirs(full_file_path)

        -- create file
        local fw = io.open(full_file_path, "w")
        fw:write(file_content)
        fw:close()

        print(ansicolors("  %{green}created file%{reset} " .. full_file_path))
    end
end

return ZebraApplication

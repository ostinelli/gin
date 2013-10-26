local lfs = require 'lfs'
local ansicolors = require 'ansicolors'


local pages_controller = [[
local PagesController = {}

function PagesController:root()
    return 200, { message = "Hello world from Ralis!" }
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
    name = "{{APP_NAME}}"
}
]]


database = [[
local db = require 'ralis.db.db'

-- Here you can setup your databases that will be accessible throughout your application.
-- First, specify the settings (you may add multiple databases with this pattern):
local DbSettings = {

    development = {
        adapter = 'mysql',
        host = "127.0.0.1",
        port = 3306,
        database = "ralis_development",
        user = "root",
        password = "",
        pool = 5
    },

    test = {
        adapter = 'mysql',
        host = "127.0.0.1",
        port = 3306,
        database = "ralis_test",
        user = "root",
        password = "",
        pool = 5
    },

    production = {
        adapter = 'mysql',
        host = "127.0.0.1",
        port = 3306,
        database = "ralis_production",
        user = "root",
        password = "",
        pool = 5
    }
}

-- Then initialize your database(s) like this:
DB = db.new(DbSettings[Ralis.env])
]]


local nginx_config = [[
worker_processes 1;
pid tmp/{{RALIS_ENV}}-nginx.pid;

events {
    worker_connections 1024;
}

http {
    sendfile on;

    lua_package_path "./?.lua;$prefix/lib/?.lua;#{= LUA_PACKAGE_PATH };;";

    server {
        ssl on;
        ssl_certificate ../priv/{{RALIS_ENV}}-server.crt;
        ssl_certificate_key ../priv/{{RALIS_ENV}}-server.key;

        access_log logs/{{RALIS_ENV}}-access.log;
        error_log logs/{{RALIS_ENV}}-error.log;

        listen {{RALIS_PORT}};

        location / {
            lua_code_cache {{RALIS_CODE_CACHE}};
            content_by_lua 'require(\"ralis.core.router\").handler(ngx)';
        }

        location /ralisconsole {
            {{RALIS_API_CONSOLE}}
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
-- `Ralis.settings` will return the ones that correspond to the environment
-- you are running the server in.
--------------------------------------------------------------------------------
`
local Settings = {}

Settings.development = {
    code_cache = false,
    port = 7200
}

Settings.test = {
    code_cache = false,
    port = 7201
}

Settings.production = {
    code_cache = true,
    port = 80
}

return Settings
]]


local server_crt = [[
-----BEGIN CERTIFICATE-----
MIICazCCAdQCCQC0AgpnF9XZXjANBgkqhkiG9w0BAQUFADB6MQswCQYDVQQGEwJJ
VDELMAkGA1UECBMCQ08xEjAQBgNVBAcTCUNlcm5vYmJpbzEOMAwGA1UEChMFUmFs
aXMxDDAKBgNVBAsTA0RFVjEOMAwGA1UEAxMFUmFsaXMxHDAaBgkqhkiG9w0BCQEW
DWluZm9AcmFsaXMuaW8wHhcNMTMxMDExMjMwMDU5WhcNMjMxMDA5MjMwMDU5WjB6
MQswCQYDVQQGEwJJVDELMAkGA1UECBMCQ08xEjAQBgNVBAcTCUNlcm5vYmJpbzEO
MAwGA1UEChMFUmFsaXMxDDAKBgNVBAsTA0RFVjEOMAwGA1UEAxMFUmFsaXMxHDAa
BgkqhkiG9w0BCQEWDWluZm9AcmFsaXMuaW8wgZ8wDQYJKoZIhvcNAQEBBQADgY0A
MIGJAoGBAM8UIiiAok5ECb/9qyfQkDit5bdai5erXXqhwaV+uT8fI7FqLbh0yEAP
KPaTnxWiy+yD+qVr4hZtZrsB1HwUDhEbXsTrSwSlkXbvKvDV4uL8D8zfRiPwgpfx
qlonRs4x8n353cgap1BQtOMwGHZLqvl77FQSWJVtJYF8azCdNHX7AgMBAAEwDQYJ
KoZIhvcNAQEFBQADgYEAof72u5mtYPlBKXPdOXSxLwQyaKeUI0UHIyNiPVgn4djb
ncgpKSGnXzoIrEMaO0F6JCWo2O/IMJqaXqjXXtJIpMjg222yYIaCln6vkrbnq2XZ
9j1xBxZ2ACjGNXCAGZZoTlKAz+7T/v4h4hzKmE9fejjKfEZeIqadJ4bieMKBIrU=
-----END CERTIFICATE-----
]]

local server_key = [[
-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQDPFCIogKJORAm//asn0JA4reW3WouXq116ocGlfrk/HyOxai24
dMhADyj2k58Vosvsg/qla+IWbWa7AdR8FA4RG17E60sEpZF27yrw1eLi/A/M30Yj
8IKX8apaJ0bOMfJ9+d3IGqdQULTjMBh2S6r5e+xUEliVbSWBfGswnTR1+wIDAQAB
AoGBAJZYicxaSH0GjQWlyQRpOqzMJQKQbNU7h+0nUA82CI05sJJ5AqTvtQw9dYJA
/7mXrvMTh4Fe6JFb8MBJvdowPV0Dq3dH121D/JalYoHuaV9/xRPlLj8n+JtdbQZW
CqavggkHtWir5KNptPLcN4BS25A8AyUItSxY58XLGbytvvehAkEA70SkfFXtEaFn
KZdfNFg+OYLMYM4UNk1iMSOkCuYgNv/17xtY75ll9NUqO2yLeupNP5ATaFwp6fF1
CusXMWOhWQJBAN2PPMptcN7frlCzq7WPQqFG0FcIDg7vsNb7I86eLpZdxvLTegS1
Rnc/ESx70MM8+0MhyS5/tlx54TFWvNS4c3MCQQCaQOu2SQM0iZTjqHY1XeqH0z6F
7nXzaEI0oeChMil0q+HWzA+zMHcdt8upUdo+XQ1+PBl2/2v6KbOmXVevfKbJAkA4
QgO8ntd3MDLx+P1Tx8Gyc+m4/6maL1Cm9fQcpdvMgJlg1UP5aBIxe0kgE3xp5tUi
MbUE4pbqmmQNBCpElWVzAkBlw6A3hBiGcM2dz6xe5+iFTqe90Cd7l+Ctott8LYam
aq9W3caZkcCxSb72283sMwVnDNb93Z0q1qv6LNuXtftu
-----END RSA PRIVATE KEY-----
]]


local pages_controller_spec = [[
require 'spec.spec_helper'

describe("PagesController", function()

    describe("#root", function()
        it("responds with a welcome message", function()
            local response = hit({
                method = 'GET',
                url = "/"
            })

            assert.are.same(200, response.status)
            assert.are.same({ message = "Hello world from Ralis!" }, response.body)
        end)
    end)
end)
]]


local spec_helper = [[
require 'ralis.spec.runner'
]]


local RalisApplication = {}

RalisApplication.files = {
    ['app/controllers/1/pages_controller.lua'] = pages_controller,
    ['app/models/.gitkeep'] = "",
    ['config/initializers/errors.lua'] = errors,
    ['config/application.lua'] = "",
    ['config/database.lua'] = database,
    ['config/nginx.conf'] = nginx_config,
    ['config/routes.lua'] = routes,
    ['config/settings.lua'] = settings,
    ['lib/.gitkeep'] = "",
    ['priv/development-server.crt'] = server_crt,
    ['priv/development-server.key'] = server_key,
    ['priv/test-server.crt'] = server_crt,
    ['priv/test-server.key'] = server_key,
    ['spec/controllers/1/pages_controller_spec.lua'] = pages_controller_spec,
    ['spec/models/.gitkeep'] = "",
    ['spec/spec_helper.lua'] = spec_helper
}

function RalisApplication.new(name)
    print(ansicolors("Creating app %{cyan}" .. name .. "%{reset}..."))

    RalisApplication.files['config/application.lua'] = string.gsub(application, "{{APP_NAME}}", name)
    RalisApplication.create_files(name)
end

function RalisApplication.create_files(parent)
    for file_path, file_content in pairs(RalisApplication.files) do
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

return RalisApplication

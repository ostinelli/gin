local lfs = require 'lfs'
local bashcolors = require 'ralis.core.bashcolors'

local settings = [[
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


local nginx_config = [[
worker_processes 1;
pid tmp/{{RALIS_ENV}}-nginx.pid;

events {
    worker_connections 1024;
}

http {
    lua_package_path "./?.lua;$prefix/lib/?.lua;#{= LUA_PACKAGE_PATH };;";

    server {
        access_log logs/{{RALIS_ENV}}-access.log;
        error_log logs/{{RALIS_ENV}}-error.log;

        listen {{RALIS_PORT}};

        location / {
            lua_code_cache {{RALIS_CODE_CACHE}};
            content_by_lua 'require(\"ralis.core.router\").handler(ngx)';
        }
    }
}
]]


local routes = [[
local routes = require 'ralis.core.routes'

-- define routes
routes.GET("/", { controller = "pages", action = "root" })

return routes
]]


local pages_controller = [[
local PagesController = {}

function PagesController:root()
    return 200, { message = "Hello world from Ralis!" }
end

return PagesController
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
            assert.are.same({ message = "Hello world from Ralis!" }, JSON.decode(response.body))
        end)
    end)
end)
]]


local spec_helper = [[
require 'ralis.spec.runner'
]]


local RalisApplication = {}

RalisApplication.files = {
    ['config/settings.lua'] = settings,
    ['config/nginx.conf'] = nginx_config,
    ['config/routes.lua'] = routes,
    ['config/initializers/.gitkeep'] = "",
    ['lib/.gitkeep'] = "",
    ['app/controllers/pages_controller.lua'] = pages_controller,
    ['spec/controllers/pages_controller_spec.lua'] = pages_controller_spec,
    ['spec/spec_helper.lua'] = spec_helper
}

function RalisApplication.new(name)
    RalisApplication.create_files(name)
end

function RalisApplication.create_files(parent)
    for file_path, file_content in pairs(RalisApplication.files) do
        -- ensure containing directory exists
        local full_file_path = parent .. "/" .. file_path
        mkdirs(full_file_path)
        -- create file
        print(bashcolors.green .. "  creating file " .. bashcolors.reset .. full_file_path)

        local fw = io.open(full_file_path, "w")
        fw:write(file_content)
        fw:close()
    end
end

return RalisApplication

local lfs = require 'lfs'

local app_config = [[
local AppConfig = {}

AppConfig.development = {
    code_cache = false,
    port = 7200
}

AppConfig.test = {
    code_cache = false,
    port = 7201
}

AppConfig.production = {
    code_cache = true,
    port = 80
}

return AppConfig
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
    return { message = "Hello world from Ralis!" }
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
            assert.are.same({ message = "Hello world from Ralis!" }, CJSON.decode(response.body))
        end)
    end)
end)
]]


local spec_helper = [[
require 'ralis.spec.runner'
]]


local RalisApplication = {}
RalisApplication.dirs = {
    'config',
    'app',
    'app/controllers',
    'spec',
    'spec/controllers',
}

RalisApplication.files = {
    ['config/app_config.lua'] = app_config,
    ['config/nginx.conf'] = nginx_config,
    ['config/routes.lua'] = routes,
    ['app/controllers/pages_controller.lua'] = pages_controller,
    ['spec/controllers/pages_controller_spec.lua'] = pages_controller_spec,
    ['spec/spec_helper.lua'] = spec_helper
}

function RalisApplication.new(name)
    RalisApplication.create_dirs(name)
    RalisApplication.create_files(name)
end

function RalisApplication.create_dirs(parent)
    print("  creating directory " .. parent)
    lfs.mkdir(parent)

    for _, dir in pairs(RalisApplication.dirs) do
        local full_dir = parent .. "/" .. dir
        print("  creating directory " .. full_dir)
        lfs.mkdir(full_dir)
    end
end

function RalisApplication.create_files(parent)
    for file_path, file_content in pairs(RalisApplication.files) do
        local full_file_path = parent .. "/" .. file_path
        print("  creating file " .. full_file_path)

        local fw = io.open(full_file_path, "w")
        fw:write(file_content)
        fw:close()
    end
end

return RalisApplication

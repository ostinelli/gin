-- dependencies
local lfs = require 'lfs'

require 'ralis.core.ralis'


local function create_dirs(necessary_dirs)
    for _, dir in pairs(necessary_dirs) do
        lfs.mkdir(dir)
    end
end

local function create_nginx_conf(nginx_conf_file_path, nginx_conf_content)
    local fw = io.open(nginx_conf_file_path, "w")
    fw:write(nginx_conf_content)
    fw:close()
end

local function remove_nginx_conf(nginx_conf_file_path)
    os.remove(nginx_conf_file_path)
end

local function nginx_command(nginx_conf_file_path, nginx_signal)
    return os.execute("nginx " .. nginx_signal .. " -p `pwd`/ -c " .. nginx_conf_file_path .. " 2>/dev/null")
end

local function start_nginx(nginx_conf_file_path)
    return nginx_command(nginx_conf_file_path, '')
end

local function stop_nginx(nginx_conf_file_path)
    return nginx_command(nginx_conf_file_path, '-s stop')
end


local BaseLauncher = {}
BaseLauncher.__index = BaseLauncher

function BaseLauncher.new(nginx_conf_content, nginx_conf_file_path)
    local necessary_dirs = Ralis.app_dirs

    local instance = {
        nginx_conf_content = nginx_conf_content,
        nginx_conf_file_path = nginx_conf_file_path,
        necessary_dirs = necessary_dirs
    }
    setmetatable(instance, BaseLauncher)
    return instance
end

function BaseLauncher:start()
    create_dirs(self.necessary_dirs)
    create_nginx_conf(self.nginx_conf_file_path, self.nginx_conf_content)

    return start_nginx(self.nginx_conf_file_path)
end

function BaseLauncher:stop()
    result = stop_nginx(self.nginx_conf_file_path)
    remove_nginx_conf(self.nginx_conf_file_path)

    return result
end


return BaseLauncher

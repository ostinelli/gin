-- dependencies
local lfs = require 'lfs'

require 'ralis.core.ralis'

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
    self:create_dirs()
    self:create_nginx_conf()

    return self:start_nginx()
end

function BaseLauncher:stop()
    result = self:stop_nginx()
    self:remove_nginx_conf()

    return result
end

function BaseLauncher:start_nginx()
    return self:nginx_command('')
end

function BaseLauncher:stop_nginx()
    return self:nginx_command('-s stop')
end

function BaseLauncher:nginx_command(nginx_signal)
    return os.execute("nginx " .. nginx_signal .. " -p `pwd`/ -c " .. self.nginx_conf_file_path .. " 2>/dev/null")
end

function BaseLauncher:create_dirs()
    for _, dir in pairs(self.necessary_dirs) do
        lfs.mkdir(dir)
    end
end

function BaseLauncher:create_nginx_conf()
    local fw = io.open(self.nginx_conf_file_path, "w")
    fw:write(self.nginx_conf_content)
    fw:close()
end

function BaseLauncher:remove_nginx_conf()
    os.remove(self.nginx_conf_file_path)
end

return BaseLauncher

require 'core/request'
CJSON = require 'cjson'

Ralis = {}

-- version
Ralis.version = '0.1'

-- environment
Ralis.env = os.getenv("RALIS_ENV") or 'development'

-- get config params
Ralis.default_app_config = {
    test = {
        worker_processes = 1,
        worker_connections = 1024,
        port = 7201
    },

    production = {
        worker_processes = 4,
        worker_connections = 16384,
        port = 80
    },

    other = {
        worker_processes = 1,
        worker_connections = 1024,
        port = 7200
    }
}

function Ralis.default_conf_param(name, app_config)
    local value = nil
    if app_config[Ralis.env] then value = app_config[Ralis.env][name] end
    if value == nil and Ralis.default_app_config[Ralis.env] then value = Ralis.default_app_config[Ralis.env][name] end
    if value == nil then value = Ralis.default_app_config.other[name] end
    return value
end

function Ralis.conf_params()
    -- read config file
    local app_config = require 'config/app_config'

    -- build params and set defaults
    return {
        port = Ralis.default_conf_param('port', app_config),
        worker_processes = Ralis.default_conf_param('worker_processes', app_config),
        worker_connections = Ralis.default_conf_param('worker_connections', app_config),
    }
end

return Ralis

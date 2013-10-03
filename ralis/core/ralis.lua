require 'ralis.core.request'
CJSON = require 'cjson'

Ralis = {}

-- version
Ralis.version = '0.1'

-- environment
Ralis.env = os.getenv("RALIS_ENV") or 'development'

-- get config params
Ralis.default_app_config = {
    test = {
        code_cache = false,
        port = 7201
    },

    production = {
        code_cache = true,
        port = 80
    },

    other = {
        code_cache = false,
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
    local app_config = require 'config.app_config'

    -- build params and set defaults
    return {
        port = Ralis.default_conf_param('port', app_config),
        code_cache = Ralis.default_conf_param('code_cache', app_config)
    }
end

return Ralis

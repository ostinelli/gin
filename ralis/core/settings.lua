-- perf
local pairs = pairs
local pcall = pcall
local require = require


local RalisSettings = {}

RalisSettings.defaults = {
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

function RalisSettings.for_current_environment()
    -- load defaults
    local settings = RalisSettings.defaults[Ralis.env]
    if settings == nil then settings = RalisSettings.defaults.other end

    -- override defaults from app settings
    local app_settings = RalisSettings.app_settings()

    if app_settings ~= nil then
        local app_settings_env = app_settings[Ralis.env]
        if app_settings_env ~= nil then
            for k, v in pairs(app_settings_env) do
                settings[k] = v
            end
        end
    end

    return settings
end

function RalisSettings.app_settings()
    local ok, appsettings = pcall(function() return require('config.settings') end)
    return appsettings
end

return RalisSettings

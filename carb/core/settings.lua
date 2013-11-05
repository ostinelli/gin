-- perf
local pairs = pairs
local pcall = pcall
local require = require


local CarbSettings = {}

CarbSettings.defaults = {
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

local function require_app_settings()
    local ok, settings = pcall(function() return require('config.settings') end)
    if ok == true then
        return settings
    end
end

function CarbSettings.for_current_environment()
    -- load defaults
    local settings = CarbSettings.defaults[Carb.env]
    if settings == nil then settings = CarbSettings.defaults.other end

    -- override defaults from app settings
    local app_settings = require_app_settings()

    if app_settings ~= nil then
        local app_settings_env = app_settings[Carb.env]
        if app_settings_env ~= nil then
            for k, v in pairs(app_settings_env) do
                settings[k] = v
            end
        end
    end

    return settings
end

return CarbSettings

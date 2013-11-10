-- preload all models
ZebraModels = require_recursive("app/models")


local InitModels = {}

-- init models
function InitModels.init()
    for _, module_name in ipairs(ZebraModels) do
        local m = require(module_name)
        m.db:define(m)
    end
end

return InitModels

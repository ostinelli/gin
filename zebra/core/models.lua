local Models = {}

function Models.load(module_name)
    local m = require(module_name)
    m.db:define(m)
    return m
end

return Models

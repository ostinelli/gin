local Models = {}

function Models.load(module_name)
    local m = require(module_name)
    m.db:define(m)
end

return Models

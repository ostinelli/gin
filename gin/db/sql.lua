
local required_options = {
    adapter = true,
    host = true,
    port = true,
    database = true,
    user = true,
    password = true,
    pool = true
}

local SqlDatabase = {}
SqlDatabase.__index = SqlDatabase


function SqlDatabase.new(options)
    -- check for required params
    local remaining_options = required_options
    for k, _ in pairs(options) do remaining_options[k] = nil end
    local missing_options = {}
    for k, _ in pairs(remaining_options) do tinsert(missing_options, k) end

    if #missing_options > 0 then error("missing required database options: " .. tconcat(missing_options, ', ')) end

    -- init adapter
    local adapter = require 'gin.db.sql.mysql.adapter'
    adapter.init(options)

    -- init instance
    local instance = {
        options = options,
        adapter = adapter
    }
    setmetatable(instance, SqlDatabase)

    return instance
end

function SqlDatabase:execute(sql)
    return self.adapter.execute(self.options, sql)
end

return SqlDatabase
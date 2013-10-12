local Database = {}
Database.__index = Database

local required_options = {
    adapter = true,
    host = true,
    port = true,
    database = true,
    user = true,
    password = true,
    pool = true
}

function Database.new(options)
    -- check for required params
    local remaining_options = required_options
    for k, _ in pairs(options) do remaining_options[k] = nil end
    local missing_options = {}
    for k, _ in pairs(remaining_options) do table.insert(missing_options, k) end

    if #missing_options > 0 then error("missing required database options: " .. table.concat(missing_options, ', ')) end

    -- init instance
    local adapter = require('ralis.db.adapters.' .. options.adapter)
    local orm = require('ralis.db.orm.' .. options.adapter)

    local instance = {
        options = options,
        adapter = adapter,
        orm = orm
    }
    setmetatable(instance, Database)
    return instance
end

function Database:query(sql)
    return self.adapter.query(self.options, sql)
end

function Database:define_model(name, table)
    self.orm.define_model(self, name, table)
end

return Database

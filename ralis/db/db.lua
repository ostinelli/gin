-- perf
local pairs = pairs
local require = require
local setmetatable = setmetatable
local tconcat = table.concat
local tinsert = table.insert


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
    for k, _ in pairs(remaining_options) do tinsert(missing_options, k) end

    if #missing_options > 0 then error("missing required database options: " .. tconcat(missing_options, ', ')) end

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

function Database:define_model(table_name)
    return self.orm.define_model(self, table_name)
end

return Database

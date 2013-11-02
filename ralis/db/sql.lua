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
    local adapter = require('ralis.db.sql.' .. options.adapter .. '.adapter')
    local orm = require('ralis.db.sql.' .. options.adapter .. '.orm')

    local instance = {
        options = options,
        adapter = adapter,
        orm = orm
    }
    setmetatable(instance, Database)
    return instance
end

-- execute db query
function Database:execute(sql)
    return self.adapter.execute(self.options, sql)
end

-- function to get tables' list
function Database:tables()
    return self.adapter.tables(self.options)
end

-- function to get last id
function Database:get_last_id()
    return self.adapter.get_last_id(self.options)
end

-- define models
function Database:define(table_name)
    return self.orm.define(self, table_name)
end

return Database

-- perf
local pairs = pairs
local require = require
local setmetatable = setmetatable
local tconcat = table.concat
local tinsert = table.insert

-- reference to all the sql DB in the application
ZEBRA_APP_SQLDB = {}


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

    -- init orm
    local orm = require('zebra.db.sql.' .. options.adapter .. '.orm')

    -- init instance
    local instance = {
        options = options,
        orm = orm
    }
    setmetatable(instance, Database)

    -- add to reference
    tinsert(ZEBRA_APP_SQLDB, instance)

    return instance
end


-- define models
function Database:define(table_name)
    local adapter = require('zebra.db.sql.' .. self.options.adapter .. '.adapter')
    return self.orm.define(self, table_name)
end


-- quote
function Database:quote(str)
    local adapter = require('zebra.db.sql.' .. self.options.adapter .. '.adapter')
    return adapter.quote(self.options, str)
end

-- get tables' list
function Database:tables()
    local adapter = require('zebra.db.sql.' .. self.options.adapter .. '.adapter')
    return adapter.tables(self.options)
end

-- get tables' list
function Database:column_names(table_name)
    local adapter = require('zebra.db.sql.' .. self.options.adapter .. '.adapter')
    return adapter.column_names(self.options, table_name)
end

-- schema dump table
function Database:schema()
    local adapter = require('zebra.db.sql.' .. self.options.adapter .. '.adapter')
    return adapter.schema(self.options)
end

-- get last id
function Database:get_last_id()
    local adapter = require('zebra.db.sql.' .. self.options.adapter .. '.adapter')
    return adapter.get_last_id(self.options)
end

-- execute db query
function Database:execute(sql)
    local adapter = require('zebra.db.sql.' .. self.options.adapter .. '.adapter')
    return adapter.execute(self.options, sql)
end


return Database

-- perf
local error = error
local pairs = pairs
local require = require
local setmetatable = setmetatable
local tconcat = table.concat
local function tappend(t, v) t[#t+1] = v end

local SqlDatabase = {}
SqlDatabase.__index = SqlDatabase


function SqlDatabase.new(options)
    -- check for required params
    local required_options = {
        adapter = true,
        host = true,
        port = true,
        database = true,
        user = true,
        password = true,
        pool = true
    }
    for k, _ in pairs(options) do required_options[k] = nil end
    local missing_options = {}
    for k, _ in pairs(required_options) do tappend(missing_options, k) end

    if #missing_options > 0 then error("missing required database options: " .. tconcat(missing_options, ', ')) end

    -- init adapter
    local adapter = require('gin.db.sql.' .. options.adapter .. '.adapter')

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

function SqlDatabase:execute_and_return_last_id(sql)
    return self.adapter.execute_and_return_last_id(self.options, sql)
end


function SqlDatabase:quote(str)
    return self.adapter.quote(self.options, str)
end

function SqlDatabase:tables()
    return self.adapter.tables(self.options)
end

function SqlDatabase:schema()
    return self.adapter.schema(self.options)
end

return SqlDatabase

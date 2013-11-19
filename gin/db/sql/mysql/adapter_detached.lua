-- dep
local dbi = require 'DBI'

-- gin
local Gin = require 'gin.core.gin'

-- perf
local assert = assert
local ipairs = ipairs
local pairs = pairs
local pcall = pcall
local setmetatable = setmetatable
local smatch = string.match
local tinsert = table.insert
local tonumber = tonumber


-- deepcopy of a table
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


local MySql = {}
MySql.default_database = 'mysql'

local function mysql_connect(options)
    local db = assert(dbi.Connect("MySQL", options.database, options.user, options.password, options.host, options.port))
    db:autocommit(true)

    return db
end

local function mysql_close(db)
    db:close()
end

-- quote
function MySql.quote(options, str)
    local db = mysql_connect(options)
    local quoted_str = "'" .. db:quote(str) .. "'"
    mysql_close(db)
    return quoted_str
end

-- return list of tables
function MySql.tables(options)
    local res = MySql.execute(options, "SHOW TABLES IN " .. options.database .. ";")

    local tables = {}

    for _, v in pairs(res) do
        for _, table_name in pairs(v) do
            tinsert(tables, table_name)
        end
    end

    return tables
end

-- return schema as a table
function MySql.schema(options)
    local Migration = require 'gin.db.migrations'
    local schema = {}

    local tables = MySql.tables(options)
    for _, table_name in ipairs(tables) do
        if table_name ~= Migration.migrations_table_name then
            local table_info = MySql.execute(options, "SHOW COLUMNS IN " .. table_name .. ";")
            tinsert(schema, { [table_name] = table_info })
        end
    end

    return schema
end

-- execute query on db
local function db_execute(db, sql)
    -- execute
    local sth = assert(db:prepare(sql))
    local ok, err = sth:execute()
    if ok == false then error(err) end
    -- get first returned row (if any)
    local ok, row = pcall(function() return sth:fetch(true) end)
    if ok == false then row = nil end
    return sth, row
end

-- execute a query
function MySql.execute(options, sql)
    -- connect
    local db = mysql_connect(options)
    -- execute
    local sth, row = db_execute(db, sql)
    if row == nil then return end
    -- build res
    local res = {}
    while row do
        local irow = deepcopy(row)
        tinsert(res, irow)
        row = sth:fetch(true)
    end
    -- close
    sth:close()
    mysql_close(db)
    -- return
    return res
end

-- execute a query and return the last ID
function MySql.execute_and_return_last_id(options, sql)
    -- connect
    local db = mysql_connect(options)
    -- execute sql
    local sth, row = db_execute(db, sql)
    sth:close()
    -- get last id
    local sth, row = db_execute(db, "SELECT BINARY LAST_INSERT_ID() as id;")
    local id = row.id
    -- close
    sth:close()
    mysql_close(db)
    -- return
    return tonumber(id)
end

return MySql

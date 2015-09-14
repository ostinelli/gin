-- dep
local dbi = require 'DBI'

-- gin
local Gin = require 'gin.core.gin'
local helpers = require 'gin.helpers.common'
local postgresql_helpers = require 'gin.db.sql.postgresql.helpers'

-- perf
local assert = assert
local ipairs = ipairs
local pairs = pairs
local pcall = pcall
local setmetatable = setmetatable
local smatch = string.match
local tonumber = tonumber
local function tappend(t, v) t[#t+1] = v end


local PostgreSql = {}
PostgreSql.default_database = 'postgres'


-- locations
function PostgreSql.location_for(options)
    return postgresql_helpers.location_for(options)
end

function PostgreSql.execute_location_for(options)
    return postgresql_helpers.execute_location_for(options)
end

local function postgresql_connect(options)
    local db = assert(dbi.Connect("PostgreSQL", options.database, options.user, options.password, options.host, options.port))
    db:autocommit(true)

    return db
end

local function postgresql_close(db)
    db:close()
end

-- quote
function PostgreSql.quote(options, str)
    local db = postgresql_connect(options)
    local quoted_str = "'" .. db:quote(str) .. "'"
    postgresql_close(db)
    return quoted_str
end

-- return list of tables
function PostgreSql.tables(options)
    local sql = "SELECT table_name FROM information_schema.tables WHERE table_catalog='" .. options.database .. "' AND table_schema = 'public';"
    local res = PostgreSql.execute(options, sql)

    local tables = {}

    for _, v in pairs(res) do
        for _, table_name in pairs(v) do
            tappend(tables, table_name)
        end
    end

    return tables
end

-- return schema as a table
function PostgreSql.schema(options)
    local Migration = require 'gin.db.migrations'
    local schema = {}

    local tables = PostgreSql.tables(options)
    for _, table_name in ipairs(tables) do
        if table_name ~= Migration.migrations_table_name then
            local sql = "SELECT column_name, column_default, is_nullable, data_type, character_maximum_length, numeric_precision, datetime_precision FROM information_schema.columns WHERE table_name ='" .. table_name .. "';"
            local table_info = PostgreSql.execute(options, sql)
            tappend(schema, { [table_name] = table_info })
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
function PostgreSql.execute(options, sql)
    -- connect
    local db = postgresql_connect(options)
    -- execute
    local sth, row = db_execute(db, sql)
    if row == nil then return {} end
    -- build res
    local res = {}
    while row do
        local irow = helpers.shallowcopy(row)
        tappend(res, irow)
        row = sth:fetch(true)
    end
    -- close
    sth:close()
    postgresql_close(db)
    -- return
    return res
end

local function append_to_sql(sql, append_sql)
    local sql_without_last_semicolon = smatch(sql, "(.*);")
    if sql_without_last_semicolon ~= nil then
        sql = sql_without_last_semicolon
    end
    return sql_without_last_semicolon .. append_sql
end

-- execute a query and return the last ID
function PostgreSql.execute_and_return_last_id(options, sql, id_col)
    -- connect
    local db = postgresql_connect(options)
    -- execute sql and get last id
    sql = append_to_sql(sql, " RETURNING " .. id_col .. ";")
    -- get last id
    local sth, row = db_execute(db, sql)
    local id = row[id_col]
    -- close
    sth:close()
    postgresql_close(db)
    -- return
    return tonumber(id)
end

return PostgreSql

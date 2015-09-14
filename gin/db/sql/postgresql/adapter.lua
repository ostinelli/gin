-- gin
local postgresql_helpers = require 'gin.db.sql.postgresql.helpers'

-- perf
local error = error
local require = require
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

-- quote
function PostgreSql.quote(options, str)
    return ndk.set_var.set_quote_pgsql_str(str)
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
    local Migration = require 'gin.db.sql.migrations'
    local schema = {}

    local tables = PostgreSql.tables(options)
    for i, table_name in ipairs(tables) do
        if table_name ~= Migration.migrations_table_name then
            local sql = "SELECT column_name, column_default, is_nullable, data_type, character_maximum_length, numeric_precision, datetime_precision FROM information_schema.columns WHERE table_name ='" .. table_name .. "';"
            local columns_info = PostgreSql.execute(options, "SHOW COLUMNS IN " .. sql .. ";")
            tappend(schema, { [table_name] = columns_info })
        end
    end

    return schema
end

-- execute query on db
local function db_execute(options, db, sql)
    local location = PostgreSql.execute_location_for(options)

    -- execute query
    local resp = ngx.location.capture("/" .. location, {
       method = ngx.HTTP_POST, body = sql
    })
    if resp.status ~= ngx.HTTP_OK or not resp.body then error("failed to query postgresql") end

    -- parse response
    local parser = require "rds.parser"
    local parsed_res, err = parser.parse(resp.body)
    if parsed_res == nil then error("failed to parse RDS: " .. err) end

    local rows = parsed_res.resultset
    if not rows or #rows == 0 then
        -- empty resultset
        return {}
    else
        return rows
    end
end

-- execute a query
function PostgreSql.execute(options, sql)
    return db_execute(options, db, sql)
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
    -- execute query and get last id
    sql = append_to_sql(sql, " RETURNING " .. id_col .. ";")
    local res = db_execute(options, db, sql)
    return tonumber(res[1][id_col])
end

return PostgreSql

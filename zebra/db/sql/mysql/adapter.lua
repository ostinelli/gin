-- dependencies
local mysql = require "resty.mysql"

-- perf
local error = error
local ipairs = ipairs
local require = require
local tinsert = table.insert

-- settings
local timeout_subsequent_ops = 1000 -- 1 sec
local max_idle_timeout = 10000 -- 10 sec
local max_packet_size = 1024 * 1024 -- 1MB


local MySql = {}

local function mysql_connect(options)
    -- create sql object
    local db, err = mysql:new()
    if not db then error("failed to instantiate mysql: " .. err) end
    -- set 1 second timeout for suqsequent operations
    db:set_timeout(timeout_subsequent_ops)
    -- connect to db
    local db_options = {
        host = options.host,
        port = options.port,
        database = options.database,
        user = options.user,
        password = options.password,
        max_packet_size = max_packet_size
    }
    local ok, err, errno, sqlstate = db:connect(db_options)
    if not ok then error("failed to connect to mysql: " .. err .. ": " .. errno .. " " .. sqlstate) end
    -- return
    return db
end

local function mysql_keepalive(db, options)
    -- put it into the connection pool
    local ok, err = db:set_keepalive(max_idle_timeout, options.pool)
    if not ok then error("failed to set mysql keepalive: ", err) end
end

-- quote
function MySql.quote(options, str)
    return ngx.quote_sql_str(str)
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

-- return last inserted if
function MySql.get_last_id(options)
    local res = MySql.execute(options, "SELECT LAST_INSERT_ID() AS id;")
    return tonumber(res[1].id)
end

-- return schema as a table
function MySql.schema(options)
    local Migration = require 'zebra.db.sql.migrations'
    local schema = {}

    local tables = MySql.tables(options)
    for i, table_name in ipairs(tables) do
        if table_name ~= Migration.migrations_table_name then
            local table_info = MySql.execute(options, "SHOW COLUMNS IN " .. table_name .. ";")
            tinsert(schema, { [table_name] = table_info })
        end
    end

    return schema
end

-- execute a query
function MySql.execute(options, sql)
    -- get db object
    local db_conn = mysql_connect(options)
    -- execute query
    local res, err, errno, sqlstate = db_conn:query(sql)
    if not res then error("bad mysql result: " .. err .. ": " .. errno .. " " .. sqlstate) end
    -- keepalive
    mysql_keepalive(db_conn, options)
    -- return
    return res
end

return MySql

local ansicolors = require 'ansicolors'
local dbi = require 'DBI'

-- perf
local assert = assert
local ipairs = ipairs
local pcall = pcall
local smatch = string.match
local tinsert = table.insert

-- settings
local mysql_default_database = 'mysql'


local MySql = {
    db = nil
}

-- the creation of the database should only be allowed in detached adapters.
local function create_db(options)
    local db, err = assert(dbi.Connect("MySQL", mysql_default_database, options.user, options.password, options.host, options.port))
    dbi.Do(db, "CREATE DATABASE ".. options.database .. ";")
    print(ansicolors("Database '" .. options.database .. "' does not exist, %{green}created%{reset}."))
    db:close()
end

local function mysql_connect(options)
    return assert(dbi.Connect("MySQL", options.database, options.user, options.password, options.host, options.port))
end


local function mysql_ensure_db_and_connection(options)
    local ok, db_or_err = pcall(function() return mysql_connect(options) end)

    if ok == true then
        -- connection successful
        return db_or_err
    end

    if smatch(db_or_err, "Unknown database") ~= nil then
        -- database does not exist, create
        create_db(options)
        -- connect to newly created database
        db = mysql_connect(options)
        return db
    else
        -- connection error
        error(db_or_err)
    end
end

local function mysql_ensure_connection(options)
    if MySql.db == nil then
        MySql.db = mysql_ensure_db_and_connection(options)
        MySql.db:autocommit(true)
    end
end

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

-- quote
function MySql.quote(options, str)
    mysql_ensure_connection(options)
    return "'" .. MySql.db:quote(str) .. "'"
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
    local res = MySql.execute(options, "SELECT BINARY LAST_INSERT_ID() as id;")
    return tonumber(res[1].id)
end

-- return schema as a table
function MySql.schema(options)
    local Migration = require 'zebra.db.migrations'
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

-- execute a query
function MySql.execute(options, sql)
    -- connect
    mysql_ensure_connection(options)

    -- build res
    local res = {}

    local sth = assert(MySql.db:prepare(sql))

    local ok, err = sth:execute()
    if ok == false then error(err) end

    -- loop over the returned data (if any)
    local ok, row = pcall(function() return sth:fetch(true) end)
    if ok == false then return end

    while row do
        local irow = deepcopy(row)
        tinsert(res, irow)
        row = sth:fetch(true)
    end

    return res
end

return MySql

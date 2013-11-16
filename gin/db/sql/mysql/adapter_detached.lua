-- dep
local ansicolors = require 'ansicolors'
local dbi = require 'DBI'

-- gin
local Gin = require 'gin.core.gin'

-- perf
local assert = assert
local ipairs = ipairs
local pcall = pcall
local smatch = string.match
local tinsert = table.insert

-- settings
local mysql_default_database = 'mysql'

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
    if MySql.db == nil then
        MySql.db = assert(dbi.Connect("MySQL", options.database, options.user, options.password, options.host, options.port))
        MySql.db:autocommit(true)
    end
end

-- quote
function MySql.quote(options, str)
    mysql_connect(options)
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

-- return last inserted if
function MySql.get_last_id(options)
    local res = MySql.execute(options, "SELECT BINARY LAST_INSERT_ID() as id;")
    return tonumber(res[1].id)
end

-- execute a query
function MySql.execute(options, sql)
    if Gin.env ~= 'test' then
        print(ansicolors("%{magenta}==> " .. sql .. "%{reset}"))
    end
    -- connect
    mysql_connect(options)

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

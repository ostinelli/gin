-- dependencies
local ansicolors = require 'ansicolors'

-- perf
local assert = assert
local ipairs = ipairs
local tinsert = table.insert

local luasql = require 'luasql.mysql'


local MySql = {
    env = nil,
    db = nil
}

local function mysql_ensure_connection(options)
    if MySql.env == nil then
        MySql.env = assert(luasql.mysql())
    end
    if MySql.db == nil then
        MySql.db = assert(MySql.env:connect(options.database, options.user, options.password))
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
    return "'" .. MySql.db:escape(str) .. "'"
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
    local res = MySql.execute(options, "SELECT LAST_INSERT_ID();")
    return tonumber(res[1][1])
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
    -- print statement
    print(ansicolors("%{cyan}SQL =>%{reset} " .. sql))

    -- connect
    mysql_ensure_connection(options)

    -- build res
    local res = {}
    local cursor_or_number = assert(MySql.db:execute(sql))

    if type(cursor_or_number) ~= 'number' then
        local row = cursor_or_number:fetch({}, "a")
        while row do
            local irow = deepcopy(row)
            tinsert(res, irow)
            row = cursor_or_number:fetch(row, "a")
        end
    end

    return res
end

return MySql

-- perf
local error = error
local next = next
local pairs = pairs
local table_concat = table.concat
local table_insert = table.insert
local type = type


local function quote(str)
    return ngx.quote_sql_str(str)
end

local function create(db, table_name, attrs)
    -- health check
    if attrs == nil or next(attrs) == nil then
        error("no attributes were specified to create new model instance")
    end
    -- init sql
    local sql = {}
    -- build fields
    local fields = {}
    local values = {}
    for k, v in pairs(attrs) do
        table_insert(fields, k)
        if type(v) ~= 'number' then v = quote(v) end
        table_insert(values, v)
    end
    -- build sql
    table_insert(sql, "INSERT INTO ")
    table_insert(sql, table_name)
    table_insert(sql, " (")
    table_insert(sql, table_concat(fields, ','))
    table_insert(sql, ") VALUES (")
    table_insert(sql, table_concat(values, ','))
    table_insert(sql, ");")

    return db:query(table_concat(sql))
end

local function where(db, table_name, attrs, options)
    -- init sql
    local sql = {}
    -- start select
    table_insert(sql, "SELECT * FROM ")
    table_insert(sql, table_name)
    -- where
    if attrs ~= nil and next(attrs) ~= nil then
        table_insert(sql, " WHERE (")
        local where = {}
        for k, v in pairs(attrs) do
            local key_pair = {}
            table_insert(key_pair, k)
            if type(v) ~= 'number' then v = quote(v) end
            table_insert(key_pair, "=")
            table_insert(key_pair, v)

            table_insert(where, table_concat(key_pair))
        end
        table_insert(sql, table_concat(where, ','))
        table_insert(sql, ")")
    end
    -- options
    if options then
        -- limit
        if options.limit ~= nil then
            table_insert(sql, " LIMIT ")
            table_insert(sql, options.limit)
        end
        -- offset
        if options.offset ~= nil then
            table_insert(sql, " OFFSET ")
            table_insert(sql, options.offset)
        end
    end
    -- close
    table_insert(sql, ";")
    -- execute
    return db:query(table_concat(sql))
end

local MySqlOrm = {}

function MySqlOrm.define_model(db, table_name)
    -- init object
    local model = {}
    -- add functions
    model.create = function(attrs) return create(db, table_name, attrs) end
    model.where = function(attrs, options) return where(db, table_name, attrs, options) end
    -- return
    return model
end

return MySqlOrm

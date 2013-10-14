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
        table.insert(fields, k)
        if type(v) ~= 'number' then v = quote(v) end
        table.insert(values, v)
    end
    -- build sql
    table.insert(sql, "INSERT INTO ")
    table.insert(sql, table_name)
    table.insert(sql, " (")
    table.insert(sql, table.concat(fields, ','))
    table.insert(sql, ") VALUES (")
    table.insert(sql, table.concat(values, ','))
    table.insert(sql, ");")

    return db:query(table.concat(sql))
end

local function where(db, table_name, attrs, options)
    -- init sql
    local sql = {}
    -- start select
    table.insert(sql, "SELECT * FROM ")
    table.insert(sql, table_name)
    -- where
    if attrs ~= nil and next(attrs) ~= nil then
        table.insert(sql, " WHERE (")
        local where = {}
        for k, v in pairs(attrs) do
            local key_pair = {}
            table.insert(key_pair, k)
            if type(v) ~= 'number' then v = quote(v) end
            table.insert(key_pair, "=")
            table.insert(key_pair, v)

            table.insert(where, table.concat(key_pair))
        end
        table.insert(sql, table.concat(where, ','))
        table.insert(sql, ")")
    end
    -- options
    if options then
        -- limit
        if options.limit ~= nil then
            table.insert(sql, " LIMIT ")
            table.insert(sql, options.limit)
        end
        -- offset
        if options.offset ~= nil then
            table.insert(sql, " OFFSET ")
            table.insert(sql, options.offset)
        end
    end
    -- close
    table.insert(sql, ";")
    -- execute
    return db:query(table.concat(sql))
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

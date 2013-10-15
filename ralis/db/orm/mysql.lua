-- perf
local error = error
local next = next
local pairs = pairs
local tconcat = table.concat
local tinsert = table.insert
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
        tinsert(fields, k)
        if type(v) ~= 'number' then v = quote(v) end
        tinsert(values, v)
    end
    -- build sql
    tinsert(sql, "INSERT INTO ")
    tinsert(sql, table_name)
    tinsert(sql, " (")
    tinsert(sql, tconcat(fields, ','))
    tinsert(sql, ") VALUES (")
    tinsert(sql, tconcat(values, ','))
    tinsert(sql, ");")

    return db:query(tconcat(sql))
end

local function where(db, table_name, attrs, options)
    -- init sql
    local sql = {}
    -- start select
    tinsert(sql, "SELECT * FROM ")
    tinsert(sql, table_name)
    -- where
    if attrs ~= nil and next(attrs) ~= nil then
        tinsert(sql, " WHERE (")
        local where = {}
        for k, v in pairs(attrs) do
            local key_pair = {}
            tinsert(key_pair, k)
            if type(v) ~= 'number' then v = quote(v) end
            tinsert(key_pair, "=")
            tinsert(key_pair, v)

            tinsert(where, tconcat(key_pair))
        end
        tinsert(sql, tconcat(where, ','))
        tinsert(sql, ")")
    end
    -- options
    if options then
        -- limit
        if options.limit ~= nil then
            tinsert(sql, " LIMIT ")
            tinsert(sql, options.limit)
        end
        -- offset
        if options.offset ~= nil then
            tinsert(sql, " OFFSET ")
            tinsert(sql, options.offset)
        end
    end
    -- close
    tinsert(sql, ";")
    -- execute
    return db:query(tconcat(sql))
end

local MySqlOrm = {}

function MySqlOrm.define_model(db, table_name)
    -- init object
    local RalisBaseModel = {}
    RalisBaseModel.__index = RalisBaseModel

    function RalisBaseModel.create(attrs)
        return create(db, table_name, attrs)
    end

    function RalisBaseModel.where(attrs, options)
        return where(db, table_name, attrs, options)
    end

    function RalisBaseModel.new(attrs)
        local instance = attrs
        setmetatable(instance, RalisBaseModel)
        return instance
    end

    -- function RalisBaseModel:save()
    --     return save(db, table_name, self.attrs)
    -- end

    -- return
    return RalisBaseModel
end

return MySqlOrm

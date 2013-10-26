-- perf
local error = error
local ipairs = ipairs
local next = next
local pairs = pairs
local tconcat = table.concat
local tinsert = table.insert
local type = type
local tonumber = tonumber


local function quote(str)
    return ngx.quote_sql_str(str)
end

local function get_last_id(db)
    local res = db:execute("SELECT LAST_INSERT_ID() AS id;")
    return tonumber(res[1].id)
end

local function field_and_values_for(attrs)
    local fav = {}
    for k, v in pairs(attrs) do
        local key_pair = {}
        tinsert(key_pair, k)
        if type(v) ~= 'number' then v = quote(v) end
        tinsert(key_pair, "=")
        tinsert(key_pair, v)

        tinsert(fav, tconcat(key_pair))
    end
    return tconcat(fav, ',')
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
    -- hit server
    db:execute(tconcat(sql))
    -- get last id
    return get_last_id(db);
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
        tinsert(sql, field_and_values_for(attrs))
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
    return db:execute(tconcat(sql))
end

local function save(db, table_name, attrs)
    -- init sql
    local sql = {}
    -- build sql
    tinsert(sql, "UPDATE ")
    tinsert(sql, table_name)
    tinsert(sql, " SET ")
    -- remove id
    local id = attrs.id
    attrs.id = nil
    -- fields
    tinsert(sql, field_and_values_for(attrs))
    -- where
    tinsert(sql, " WHERE id=")
    tinsert(sql, id)
    -- close
    tinsert(sql, ";")
    -- execute
    return db:execute(tconcat(sql))
end


local MySqlOrm = {}

function MySqlOrm.define(db, table_name)
    -- init object
    local RalisBaseModel = {}
    RalisBaseModel.__index = RalisBaseModel

    function RalisBaseModel.execute(sql)
        return db:execute(sql)
    end

    function RalisBaseModel.create(attrs)
        local model = RalisBaseModel.new(attrs)

        local id = create(db, table_name, attrs)
        model.id = id

        return model
    end

    function RalisBaseModel.where(attrs, options)
        local results = where(db, table_name, attrs, options)

        local models = {}
        for _, v in ipairs(results) do
            tinsert(models, RalisBaseModel.new(v))
        end
        return models
    end

    function RalisBaseModel.all()
        return RalisBaseModel.where()
    end

    function RalisBaseModel.find_by(attrs)
        local models = RalisBaseModel.where(attrs, { limit = 1 })
        return models[1]
    end

    function RalisBaseModel.new(attrs)
        local instance = attrs or {}
        setmetatable(instance, RalisBaseModel)
        return instance
    end

    function RalisBaseModel:class()
        return RalisBaseModel
    end

    function RalisBaseModel:save()
        if self.id ~= nil then
            save(db, table_name, self)
        else
            local id = RalisBaseModel.create(self)
            self.id = id
        end
    end

    -- return
    return RalisBaseModel
end

return MySqlOrm

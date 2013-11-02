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
    return db:get_last_id();
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
        -- order
        if options.order ~= nil then
            tinsert(sql, " ORDER BY ")
            tinsert(sql, options.order)
        end
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

local function delete_where(db, table_name, attrs, options)
    -- init sql
    local sql = {}
    -- start select
    tinsert(sql, "DELETE FROM ")
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

local function delete(db, table_name, attrs)
    -- init sql
    local sql = {}
    -- build sql
    tinsert(sql, "DELETE FROM ")
    tinsert(sql, table_name)
    -- where
    tinsert(sql, " WHERE id=")
    tinsert(sql, attrs.id)
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

    function RalisBaseModel.delete_where(attrs, options)
        delete_where(db, table_name, attrs, options)
    end

    function RalisBaseModel.all(options)
        return RalisBaseModel.where({}, options)
    end

    function RalisBaseModel.delete_all(options)
        RalisBaseModel.delete_where({}, options)
    end

    function RalisBaseModel.find_by(attrs, options)
        local merged_options = { limit = 1 }
        if options and options.order then
            merged_options.order = options.order
        end
        local models = RalisBaseModel.where(attrs, merged_options)
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

    function RalisBaseModel:delete()
        if self.id ~= nil then
            delete(db, table_name, self)
        else
            error("cannot delete a model without an id")
        end
    end

    -- return
    return RalisBaseModel
end

return MySqlOrm

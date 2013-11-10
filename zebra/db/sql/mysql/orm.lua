-- perf
local error = error
local ipairs = ipairs
local next = next
local pairs = pairs
local tconcat = table.concat
local tinsert = table.insert
local type = type
local tonumber = tonumber


local function field_and_values(db, attrs, db_attributes)
    local fav = {}
    for field, value in pairs(attrs) do
        if db_attributes == nil or (db_attributes ~= nil and included(db_attributes, field)) then
            local key_pair = {}
            tinsert(key_pair, field)
            if type(value) ~= 'number' then value = db:quote(value) end
            tinsert(key_pair, "=")
            tinsert(key_pair, value)

            tinsert(fav, tconcat(key_pair))
        end
    end
    return tconcat(fav, ',')
end

local function db_attributes(db, table_name)
    return db:column_names(table_name)
end

local function create(db, table_name, attrs, db_attributes)
    -- health check
    if attrs == nil or next(attrs) == nil then
        error("no attributes were specified to create new model instance")
    end
    -- init sql
    local sql = {}
    -- build fields
    local fields = {}
    local values = {}
    for field, value in pairs(attrs) do
        if included(db_attributes, field) then
            tinsert(fields, field)
            if type(value) ~= 'number' then value = db:quote(value) end
            tinsert(values, value)
        end
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
        tinsert(sql, field_and_values(db, attrs))
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
        tinsert(sql, field_and_values(db, attrs))
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

local function save(db, table_name, attrs, db_attributes)
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
    tinsert(sql, field_and_values(db, attrs, db_attributes))
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

function MySqlOrm.define(ZebraModel)
    -- init index
    ZebraModel.__index = ZebraModel

    -- get attributes
    local db_attrs = db_attributes(ZebraModel.db, ZebraModel.table_name)

    function ZebraModel.create(attrs)
        local model = ZebraModel.new(attrs)

        local id = create(ZebraModel.db, ZebraModel.table_name, attrs, db_attrs)
        model.id = id

        return model
    end

    function ZebraModel.where(attrs, options)
        local results = where(ZebraModel.db, ZebraModel.table_name, attrs, options)

        local models = {}
        for _, v in ipairs(results) do
            tinsert(models, ZebraModel.new(v))
        end
        return models
    end

    function ZebraModel.delete_where(attrs, options)
        delete_where(ZebraModel.db, ZebraModel.table_name, attrs, options)
    end

    function ZebraModel.all(options)
        return ZebraModel.where({}, options)
    end

    function ZebraModel.delete_all(options)
        ZebraModel.delete_where({}, options)
    end

    function ZebraModel.find_by(attrs, options)
        local merged_options = { limit = 1 }
        if options and options.order then
            merged_options.order = options.order
        end
        local models = ZebraModel.where(attrs, merged_options)
        return models[1]
    end

    function ZebraModel.new(attrs)
        local instance = attrs or {}
        setmetatable(instance, ZebraModel)
        return instance
    end

    function ZebraModel:class()
        return ZebraModel
    end

    function ZebraModel:save()
        if self.id ~= nil then
            save(ZebraModel.db, ZebraModel.table_name, self, db_attrs)
        else
            local id = ZebraModel.create(self)
            self.id = id
        end
    end

    function ZebraModel:delete()
        if self.id ~= nil then
            delete(ZebraModel.db, ZebraModel.table_name, self)
        else
            error("cannot delete a model without an id")
        end
    end
end

return MySqlOrm

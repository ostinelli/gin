-- perf
local require = require
local function tappend(t, v) t[#t+1] = v end


local SqlOrm = {}

--- Define a model.
-- The default primary key is set to 'id'
-- @param sql_database the sql database instance
-- @param table_name the name of the table to create a lightweight orm mapping for
-- @param id_col set to true to use table_name .. '_id' as primary key,
-- set to arbitrary string to use any other column as primary key
function SqlOrm.define_model(sql_database, table_name, id_col)
    local GinModel = {}
    GinModel.__index = GinModel
    if true == id_col then
        id_col = table_name .. '_id'
    elseif id_col then
        id_col = tostring(id_col)
    else
        id_col = 'id' -- backward compatible default
    end
    GinModel.__id_col = id_col

    -- init
    local function quote(str)
        return sql_database:quote(str)
    end
    local orm = require('gin.db.sql.' .. sql_database.options.adapter .. '.orm').new(table_name, quote)

    function GinModel.new(attrs)
        local instance = attrs or {}
        setmetatable(instance, GinModel)
        return instance
    end

    function GinModel.create(attrs)
        local sql = orm:create(attrs)
        local id_col = GinModel.__id_col
        local id = sql_database:execute_and_return_last_id(sql, id_col)

        local model = GinModel.new(attrs)
        model[id_col] = id

        return model
    end

    function GinModel.where(attrs, options)
        local sql = orm:where(attrs, options)
        local results = sql_database:execute(sql)

        local models = {}
        for i = 1, #results do
            tappend(models, GinModel.new(results[i]))
        end
        return models
    end

    function GinModel.all(options)
        return GinModel.where({}, options)
    end

    function GinModel.find_by(attrs, options)
        local merged_options = { limit = 1 }
        if options and options.order then
            merged_options.order = options.order
        end

        return GinModel.where(attrs, merged_options)[1]
    end

    function GinModel.delete_where(attrs, options)
        local sql = orm:delete_where(attrs, options)
        return sql_database:execute(sql)
    end

    function GinModel.delete_all(options)
        return GinModel.delete_where({}, options)
    end

    function GinModel.update_where(attrs, options)
        local sql = orm:update_where(attrs, options)
        return sql_database:execute(sql)
    end

    function GinModel:save()
        local id_col = GinModel.__id_col
        local id = self[id_col]
        if id ~= nil then
            self[id_col] = nil
            local result = GinModel.update_where(self, { [id_col] = id })
            self[id_col] = id
            return result
        else
            return GinModel.create(self)
        end
    end

    function GinModel:delete()
        local id_col = GinModel.__id_col
        local id = self[id_col]
        if id ~= nil then
            return GinModel.delete_where({ [id_col] = id })
        else
            error("cannot delete a model without an id")
        end
    end

    return GinModel
end


return SqlOrm

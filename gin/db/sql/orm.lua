-- perf
local ipairs = ipairs
local require = require
local tinsert = table.insert


local SqlOrm = {}

function SqlOrm.define_model(sql_database, table_name)
    local GinModel = {}
    GinModel.__index = GinModel

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
        local id = sql_database:execute_and_return_last_id(sql)

        local model = GinModel.new(attrs)
        model.id = id

        return model
    end

    function GinModel.where(attrs, options)
        local sql = orm:where(attrs, options)
        local results = sql_database:execute(sql)

        local models = {}
        for _, v in ipairs(results) do
            tinsert(models, GinModel.new(v))
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
        if self.id ~= nil then
            local id = self.id
            self.id = nil
            local result = GinModel.update_where(self, { id = id })
            self.id = id
            return result
        else
            return GinModel.create(self)
        end
    end

    function GinModel:delete()
        if self.id ~= nil then
            return GinModel.delete_where({ id = self.id })
        else
            error("cannot delete a model without an id")
        end
    end

    return GinModel
end


return SqlOrm

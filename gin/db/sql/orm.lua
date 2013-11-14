-- perf
local ipairs = ipairs
local require = require
local tinsert = table.insert


local SqlOrm = {}

function SqlOrm.define_model(database, table_name)
    local GinModel = {}
    GinModel.__index = GinModel

    -- init
    local adapter = database.adapter
    local quote_fun = adapter.quote
    local orm = require('gin.db.sql.' .. database.options.adapter .. '.orm').new(table_name, quote_fun)

    function GinModel.new(attrs)
        local instance = attrs or {}
        setmetatable(instance, GinModel)
        return instance
    end

    function GinModel.create(attrs)
        local sql = orm:create(attrs)
        local result = database:execute(sql)

        local model = GinModel.new(attrs)
        model.id = adapter.get_last_id()

        return model
    end

    function GinModel.where(attrs, options)
        local sql = orm:where(attrs, options)
        local results = database:execute(sql)

        local models = {}
        for _, v in ipairs(results) do
            tinsert(models, GinModel.new(v))
        end
        return models
    end

    return GinModel
end


return SqlOrm

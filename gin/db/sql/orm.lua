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
        local model = database:execute(sql)

        model.id = adapter.get_last_id()

        return model
    end

    return GinModel
end


return SqlOrm

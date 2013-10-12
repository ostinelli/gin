local Database = {}
Database.__index = Database

function Database.new(options)
    local adapter = require('ralis.db.adapters.' .. options.adapter)
    local orm = require('ralis.db.orm.' .. options.adapter)

    local instance = {
        options = options,
        adapter = adapter,
        orm = orm
    }
    setmetatable(instance, Database)
    return instance
end

function Database:query(sql)
    return self.adapter.query(self.options, sql)
end

function Database:define_model(name, table)
    self.orm.define_model(self, name, table)
end

return Database

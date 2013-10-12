local Database = {}
Database.__index = Database

function Database.new(options)
    local adapter = require('ralis.db.adapters.' .. options.adapter)

    local instance = {
        options = options,
        adapter = adapter
    }
    setmetatable(instance, Database)
    return instance
end

function Database:query(sql)
    return self.adapter.query(sql, self.options)
end

return Database

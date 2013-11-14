-- gin
local Helpers = require 'gin.core.helpers'


-- perf
local tinsert = table.insert
local tconcat = table.concat


local function field_and_values(quote, attrs, concat)
    local fav = {}
    for field, value in pairs(attrs) do
        local key_pair = {}
        tinsert(key_pair, field)
        if type(value) ~= 'number' then value = quote(value) end
        tinsert(key_pair, "=")
        tinsert(key_pair, value)

        tinsert(fav, tconcat(key_pair))
    end
    return tconcat(fav, concat)
end


local MySqlOrm = {}
MySqlOrm.__index = MySqlOrm

function MySqlOrm.new(table_name, quote_fun)
    -- init instance
    local instance = {
        table_name = table_name,
        quote = quote_fun
    }
    setmetatable(instance, MySqlOrm)

    return instance
end


function MySqlOrm:create(attrs)
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
        tinsert(fields, field)
        if type(value) ~= 'number' then value = self.quote(value) end
        tinsert(values, value)
    end
    -- build sql
    tinsert(sql, "INSERT INTO ")
    tinsert(sql, self.table_name)
    tinsert(sql, " (")
    tinsert(sql, tconcat(fields, ','))
    tinsert(sql, ") VALUES (")
    tinsert(sql, tconcat(values, ','))
    tinsert(sql, ");")
    -- hit server
    return tconcat(sql)
end

function MySqlOrm:where(attrs, options)
    -- init sql
    local sql = {}
    -- start
    tinsert(sql, "SELECT * FROM ")
    tinsert(sql, self.table_name)
    -- where
    if attrs ~= nil and next(attrs) ~= nil then
        tinsert(sql, " WHERE (")
        tinsert(sql, field_and_values(self.quote, attrs, ' AND '))
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
    return tconcat(sql)
end

function MySqlOrm:all(options)
    return self:where({}, options)
end

function MySqlOrm:find_by(attrs, options)
    local merged_options = { limit = 1 }
    if options and options.order then
        merged_options.order = options.order
    end

    return self:where(attrs, merged_options)
end

function MySqlOrm:delete_where(attrs, options)
    -- init sql
    local sql = {}
    -- start
    tinsert(sql, "DELETE FROM ")
    tinsert(sql, self.table_name)
    -- where
    if attrs ~= nil and next(attrs) ~= nil then
        tinsert(sql, " WHERE (")
        tinsert(sql, field_and_values(self.quote, attrs, ' AND '))
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
    return tconcat(sql)
end

function MySqlOrm:update_where(attrs, where_attrs)
    -- health check
    if attrs == nil or next(attrs) == nil then
        error("no attributes were specified to create new model instance")
    end
    -- init sql
    local sql = {}
    -- start
    tinsert(sql, "UPDATE ")
    tinsert(sql, self.table_name)
    tinsert(sql, " SET ")
    -- updates
    tinsert(sql, field_and_values(self.quote, attrs, ','))
    -- where
    if where_attrs ~= nil and next(where_attrs) ~= nil then
        tinsert(sql, " WHERE (")
        tinsert(sql, field_and_values(self.quote, where_attrs, ' AND '))
        tinsert(sql, ")")
    end
    -- close
    tinsert(sql, ";")
    -- execute
    return tconcat(sql)
end

return MySqlOrm

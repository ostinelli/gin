-- perf
local next = next
local pairs = pairs
local setmetatable = setmetatable
local tconcat = table.concat
local tinsert = table.insert
local type = type

-- field and values helper
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

-- where
local function build_where(self, sql, attrs)
    if attrs ~= nil then
        if type(attrs) == 'table' then
            if next(attrs) ~= nil then
                tinsert(sql, " WHERE (")
                tinsert(sql, field_and_values(self.quote, attrs, ' AND '))
                tinsert(sql, ")")
            end
        else
            tinsert(sql, " WHERE (")
            tinsert(sql, attrs)
            tinsert(sql, ")")
        end
    end
end


local PostgreSqlOrm = {}
PostgreSqlOrm.__index = PostgreSqlOrm

function PostgreSqlOrm.new(table_name, quote_fun)
    -- init instance
    local instance = {
        table_name = table_name,
        quote = quote_fun
    }
    setmetatable(instance, PostgreSqlOrm)

    return instance
end


function PostgreSqlOrm:create(attrs)
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

function PostgreSqlOrm:where(attrs, options)
    -- init sql
    local sql = {}
    -- start
    tinsert(sql, "SELECT * FROM ")
    tinsert(sql, self.table_name)
    -- where
    build_where(self, sql, attrs)
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

function PostgreSqlOrm:delete_where(attrs, options)
    -- init sql
    local sql = {}
    -- start
    tinsert(sql, "DELETE FROM ")
    tinsert(sql, self.table_name)
    -- where
    build_where(self, sql, attrs)
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

function PostgreSqlOrm:update_where(attrs, where_attrs)
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
    build_where(self, sql, where_attrs)
    -- close
    tinsert(sql, ";")
    -- execute
    return tconcat(sql)
end

return PostgreSqlOrm

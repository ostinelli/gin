-- perf
local next = next
local pairs = pairs
local setmetatable = setmetatable
local tconcat = table.concat
local type = type
local function tappend(t, v) t[#t+1] = v end

-- field and values helper
local function field_and_values(quote, attrs, concat)
    local fav = {}
    for field, value in pairs(attrs) do
        local key_pair = {}
        tappend(key_pair, field)
        if type(value) ~= 'number' then value = quote(value) end
        tappend(key_pair, "=")
        tappend(key_pair, value)

        tappend(fav, tconcat(key_pair))
    end
    return tconcat(fav, concat)
end

-- where
local function build_where(self, sql, attrs)
    if attrs ~= nil then
        if type(attrs) == 'table' then
            if next(attrs) ~= nil then
                tappend(sql, " WHERE (")
                tappend(sql, field_and_values(self.quote, attrs, ' AND '))
                tappend(sql, ")")
            end
        else
            tappend(sql, " WHERE (")
            tappend(sql, attrs)
            tappend(sql, ")")
        end
    end
end


local SqlCommonOrm = {}
SqlCommonOrm.__index = SqlCommonOrm

function SqlCommonOrm.new(table_name, quote_fun)
    -- init instance
    local instance = {
        table_name = table_name,
        quote = quote_fun
    }
    setmetatable(instance, SqlCommonOrm)

    return instance
end


function SqlCommonOrm:create(attrs)
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
        tappend(fields, field)
        if type(value) ~= 'number' then value = self.quote(value) end
        tappend(values, value)
    end
    -- build sql
    tappend(sql, "INSERT INTO ")
    tappend(sql, self.table_name)
    tappend(sql, " (")
    tappend(sql, tconcat(fields, ','))
    tappend(sql, ") VALUES (")
    tappend(sql, tconcat(values, ','))
    tappend(sql, ");")
    -- hit server
    return tconcat(sql)
end

function SqlCommonOrm:where(attrs, options)
    -- init sql
    local sql = {}
    -- start
    tappend(sql, "SELECT * FROM ")
    tappend(sql, self.table_name)
    -- where
    build_where(self, sql, attrs)
    -- options
    if options then
        -- order
        if options.order ~= nil then
            tappend(sql, " ORDER BY ")
            tappend(sql, options.order)
        end
        -- limit
        if options.limit ~= nil then
            tappend(sql, " LIMIT ")
            tappend(sql, options.limit)
        end
        -- offset
        if options.offset ~= nil then
            tappend(sql, " OFFSET ")
            tappend(sql, options.offset)
        end
    end
    -- close
    tappend(sql, ";")
    -- execute
    return tconcat(sql)
end

function SqlCommonOrm:delete_where(attrs, options)
    -- init sql
    local sql = {}
    -- start
    tappend(sql, "DELETE FROM ")
    tappend(sql, self.table_name)
    -- where
    build_where(self, sql, attrs)
    -- options
    if options then
        -- limit
        if options.limit ~= nil then
            tappend(sql, " LIMIT ")
            tappend(sql, options.limit)
        end
    end
    -- close
    tappend(sql, ";")
    -- execute
    return tconcat(sql)
end

function SqlCommonOrm:update_where(attrs, where_attrs)
    -- health check
    if attrs == nil or next(attrs) == nil then
        error("no attributes were specified to create new model instance")
    end
    -- init sql
    local sql = {}
    -- start
    tappend(sql, "UPDATE ")
    tappend(sql, self.table_name)
    tappend(sql, " SET ")
    -- updates
    tappend(sql, field_and_values(self.quote, attrs, ','))
    -- where
    build_where(self, sql, where_attrs)
    -- close
    tappend(sql, ";")
    -- execute
    return tconcat(sql)
end

return SqlCommonOrm

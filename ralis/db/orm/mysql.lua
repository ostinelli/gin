local function quote(str)
    return ngx.quote_sql_str(str)
end

local function all(db, table_name)
    return db:query("SELECT * FROM " .. table_name .. ";")
end

local function create(db, table_name, attrs)
    local fields = {}
    local values = {}
    for k, v in pairs(attrs) do
        table.insert(fields, k)
        if type(v) ~= 'number' then v = quote(v) end
        table.insert(values, v)
    end
    local sql = "INSERT INTO " .. table_name .. " (" .. table.concat(fields, ',') .. ") " ..
        "VALUES (" .. table.concat(values, ',') .. ");"

    return db:query(sql)
end

local MySqlOrm = {}

function MySqlOrm.define_model(db, name, table_name)
    -- init object
    _G[name] = {}
    local klass = _G[name]
    -- add functions
    klass.all = function() return all(db, table_name) end
    klass.create = function(attrs) return create(db, table_name, attrs) end
end

return MySqlOrm

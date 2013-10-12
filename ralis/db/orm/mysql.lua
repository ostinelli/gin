local function quote(str)
    return ngx.quote_sql_str(str)
end

local function all(db)
    return db:query("SELECT * FROM users;")
end

local function create(db, attrs)
    local fields = {}
    local values = {}
    for k, v in pairs(attrs) do
        table.insert(fields, k)
        if type(v) ~= 'number' then v = quote(v) end
        table.insert(values, v)
    end
    local sql = "INSERT INTO users (" .. table.concat(fields, ',') .. ") " ..
        "VALUES (" .. table.concat(values, ',') .. ");"

    return db:query(sql)
end

local MySqlOrm = {}

function MySqlOrm.define_model(db, name, table)
    -- init object
    _G[name] = { __table = table:lower() }
    local klass = _G[name]
    -- add functions
    klass.all = function() return all(db) end
    klass.create = function(attrs) return create(db, attrs) end
end

return MySqlOrm

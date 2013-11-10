
local AdapterSql = {}


local function raise_adapter_error(options)
    error("Cannot run SQL operation as the '" .. options.adapter .. "' adapter is not installed.")
end

-- quote
function AdapterSql.quote(options, str)
    raise_adapter_error(options)
end

-- return list of tables
function AdapterSql.tables(options)
    raise_adapter_error(options)
end

-- return list of column names
function AdapterSql.column_names(options)
    raise_adapter_error(options)
end

-- return schema as a table
function AdapterSql.schema(options)
    raise_adapter_error(options)
end

-- return last inserted if
function AdapterSql.get_last_id(options)
    raise_adapter_error(options)
end

-- execute a query
function AdapterSql.execute(options, sql)
    raise_adapter_error(options)
end

return AdapterSql

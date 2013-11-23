-- perf
local tconcat = table.concat


local PostgreSql = {}
PostgreSql.default_database = 'postgres'


-- build location execute name
function PostgreSql.location_for(options)
    name = {
        'gin',
        options.adapter,
        options.host,
        options.port,
        options.database,
    }
    return tconcat(name, '|')
end

function PostgreSql.execute_location_for(options)
    name = {
        PostgreSql.location_for(options),
        'execute'
    }
    return tconcat(name, '|')
end


-- quote
function PostgreSql.quote(options, str)
    return ngx.quote_sql_str(str)
end

-- return list of tables
function PostgreSql.tables(options)

end

-- return schema as a table
function PostgreSql.schema(options)

end

-- execute a query
function PostgreSql.execute(options, sql)
    local location = PostgreSql.execute_location_for(options)

    -- execute query
    local resp = ngx.location.capture("/" .. location, {
       method = ngx.HTTP_POST, body = sql
    })
    if resp.status ~= ngx.HTTP_OK or not resp.body then error("failed to query postgresql") end

    -- parse response
    local parser = require "rds.parser"
    local parsed_res, err = parser.parse(resp.body)
    if parsed_res == nil then error("failed to parse RDS: " .. err) end

    local rows = parsed_res.resultset
    if not rows or #rows == 0 then
        -- empty resultset
        return {}
    else
        return rows
    end
end

-- execute a query and return the last ID
function PostgreSql.execute_and_return_last_id(options, sql)

end

return PostgreSql

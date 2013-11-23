-- perf
local tconcat = table.concat


local PostgreSqlHelpers = {}

-- build location execute name
function PostgreSqlHelpers.location_for(options)
    name = {
        'gin',
        options.adapter,
        options.host,
        options.port,
        options.database,
    }
    return tconcat(name, '|')
end

function PostgreSqlHelpers.execute_location_for(options)
    name = {
        PostgreSqlHelpers.location_for(options),
        'execute'
    }
    return tconcat(name, '|')
end

return PostgreSqlHelpers

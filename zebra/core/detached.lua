local function require_adapter_and_fallback_to_detached(module_name, driver_module_name)
    local ok, adapter_or_error = try_require(module_name)

    if ok == true then return adapter_or_error end

    if ok == false and string.match(adapter_or_error, driver_module_name) then
        return require('zebra.db.sql.adapter_unavailable')
    else
        error(adapter_or_error)
    end
end

local adapter_mysql = require_adapter_and_fallback_to_detached('zebra.db.sql.mysql.adapter_detached', 'luasql.mysql')

package.loaded['zebra.db.sql.mysql.adapter'] = adapter_mysql

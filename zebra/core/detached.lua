-- user local drivers
local ok, adapter_mysql = try_require('zebra.db.sql.mysql.adapter_detached')
if ok == false then adapter_mysql = require('zebra.db.sql.adapter_unavailable') end

package.loaded['zebra.db.sql.mysql.adapter'] = adapter_mysql

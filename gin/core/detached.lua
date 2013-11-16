-- detached
local adapter_mysql = require 'gin.db.sql.mysql.adapter_detached'
package.loaded['gin.db.sql.mysql.adapter'] = adapter_mysql

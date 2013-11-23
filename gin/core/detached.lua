-- detached
local adapter_mysql = require 'gin.db.sql.mysql.adapter_detached'
package.loaded['gin.db.sql.mysql.adapter'] = adapter_mysql

local adapter_postgresql = require 'gin.db.sql.postgresql.adapter_detached'
package.loaded['gin.db.sql.postgresql.adapter'] = adapter_postgresql

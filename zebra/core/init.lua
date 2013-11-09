-- init module dependencies
require 'zebra.core.zebra'
-- load application modules
try_require('config.application')
try_require('config.routes')
try_require('db.db')
-- load application models
require_recursive("app/models")

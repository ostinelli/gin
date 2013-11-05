-- init module dependencies
require 'zebra.core.zebra'
-- load application modules
require 'config.application'
require 'config.routes'
require 'db.db'
-- load application models
require_recursive("app/models")

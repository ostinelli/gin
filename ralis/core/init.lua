-- init module dependencies
require 'ralis.core.ralis'
-- load application modules
require 'config.application'
require 'config.routes'
require 'db.db'
-- load application models
require_recursive("app/models")

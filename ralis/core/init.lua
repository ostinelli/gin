-- init module dependencies
require 'ralis.core.ralis'
-- load application modules
require 'config.application'
require 'config.routes'
require 'config.database'
-- load application models
dofile_recursive("app/models")

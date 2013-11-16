local Helpers = require 'gin.core.helpers'
-- local prettyprint = require 'pl.pretty'

-- -- console functions
-- function pp(o)
--     prettyprint.dump(o)
-- end

-- global settings
-- Gin = require 'gin.core.gin'
-- Error = require 'gin.core.error'

-- load models
Helpers.require_recursive('app/models')

local helpers = require 'gin.helpers.common'
-- local prettyprint = require 'pl.pretty'

-- -- console functions
-- function pp(o)
--     prettyprint.dump(o)
-- end

-- global settings
-- Gin = require 'gin.core.gin'
-- Error = require 'gin.core.error'

-- load models
helpers.require_recursive('app/models')

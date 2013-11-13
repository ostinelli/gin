local Helpers = require 'gin.core.helpers'
local prettyprint = require 'pl.pretty'

-- console functions
function pp(o)
    prettyprint.dump(o)
end

-- global settings
Gin = require 'gin.core.gin'
Error = require 'gin.core.error'

-- load models
local Models = require 'gin.core.models'
local models = Helpers.require_recursive('app/models')
for _, module_name in ipairs(models) do
    Models.load(module_name)
end

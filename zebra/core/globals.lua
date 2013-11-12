local Helpers = require 'zebra.core.helpers'
local prettyprint = require 'pl.pretty'

-- console functions
function pp(o)
    prettyprint.dump(o)
end

-- global settings
Zebra = require 'zebra.core.zebra'
Error = require 'zebra.core.error'

-- load models
local Models = require 'zebra.core.models'
local models = Helpers.require_recursive('app/models')
for _, module_name in ipairs(models) do
    Models.load(module_name)
end

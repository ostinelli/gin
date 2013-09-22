package.path = './?.lua;' .. package.path

require 'core/ralis'
Ralis.env = 'test'

local integration = require 'spec/support/integration'

-- helpers
function hit(request)
    integration.visit(request)
end

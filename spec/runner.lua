package.path = './?.lua;' .. package.path

require 'core/ralis'
Ralis.env = 'test'

local IntegrationRunner = require 'spec/runners/integration'

-- helpers
function hit(request)
    return IntegrationRunner.hit(request)
end

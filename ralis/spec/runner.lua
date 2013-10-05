package.path = './?.lua;' .. package.path

require 'ralis.core.ralis'

Ralis.env = 'test'

local IntegrationRunner = require 'ralis.spec.runners.integration'

-- helpers
function hit(request)
    return IntegrationRunner.hit(request)
end

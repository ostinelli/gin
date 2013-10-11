require 'ralis.spec.init'

local IntegrationRunner = require 'ralis.spec.runners.integration'

-- helpers
function hit(request)
    return IntegrationRunner.hit(request)
end

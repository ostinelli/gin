require 'zebra.spec.init'

-- add integration runner
local IntegrationRunner = require 'zebra.spec.runners.integration'

-- helpers
function hit(request)
    return IntegrationRunner.hit(request)
end

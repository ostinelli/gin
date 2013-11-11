require 'zebra.spec.init'

-- use detached drivers in db
require 'zebra.core.init_detached'

-- add integration runner
local IntegrationRunner = require 'zebra.spec.runners.integration'

-- helpers
function hit(request)
    return IntegrationRunner.hit(request)
end

require 'zebra.spec.init'

-- use local drivers in db
require 'zebra.core.local'
require 'db.db'

-- add integration runner
local IntegrationRunner = require 'zebra.spec.runners.integration'

-- helpers
function hit(request)
    return IntegrationRunner.hit(request)
end

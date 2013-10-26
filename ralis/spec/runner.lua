require 'ralis.spec.init'

-- mock dbs
package.loaded['ralis.db.adapters.mysql'] = {}
require 'config.database'

-- add integration runner
local IntegrationRunner = require 'ralis.spec.runners.integration'

-- helpers
function hit(request)
    return IntegrationRunner.hit(request)
end

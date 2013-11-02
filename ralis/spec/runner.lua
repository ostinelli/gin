require 'ralis.spec.init'

-- mock dbs
package.loaded['ralis.db.sql.mysq.adapter'] = {}
require 'config.database'

-- add integration runner
local IntegrationRunner = require 'ralis.spec.runners.integration'

-- helpers
function hit(request)
    return IntegrationRunner.hit(request)
end

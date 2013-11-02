require 'ralis.spec.init'

-- mock dbs
package.loaded['ralis.db.sql.mysql.adapter'] = {}
require 'db.db'

-- add integration runner
local IntegrationRunner = require 'ralis.spec.runners.integration'

-- helpers
function hit(request)
    return IntegrationRunner.hit(request)
end

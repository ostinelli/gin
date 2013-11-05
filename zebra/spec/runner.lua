require 'zebra.spec.init'

-- mock dbs
package.loaded['zebra.db.sql.mysql.adapter'] = {}
require 'db.db'

-- add integration runner
local IntegrationRunner = require 'zebra.spec.runners.integration'

-- helpers
function hit(request)
    return IntegrationRunner.hit(request)
end

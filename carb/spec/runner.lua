require 'carb.spec.init'

-- mock dbs
package.loaded['carb.db.sql.mysql.adapter'] = {}
require 'db.db'

-- add integration runner
local IntegrationRunner = require 'carb.spec.runners.integration'

-- helpers
function hit(request)
    return IntegrationRunner.hit(request)
end

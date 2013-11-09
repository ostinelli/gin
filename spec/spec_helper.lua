-- mock application modules here
Application = { name = "zebraapp" }
package.loaded['config.application'] = {}
package.loaded['config.routes'] = {}
package.loaded['config.settings'] = {}
package.loaded['db.db'] = {}

-- init
require 'zebra.spec.init'

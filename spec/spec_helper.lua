-- mock application modules here
Application = { name = "railsapp" }
package.loaded['config.application'] = {}
package.loaded['config.settings'] = {}
package.loaded['db.db'] = {}

-- init
require 'zebra.spec.init'

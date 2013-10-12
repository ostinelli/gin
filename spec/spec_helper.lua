-- mock application modules here
Application = { name = "railsapp" }
package.loaded['config.application'] = {}
package.loaded['config.settings'] = {}
-- mock modules that need openresty here
package.loaded['ralis.core.database'] = {}

-- init
require 'ralis.spec.init'

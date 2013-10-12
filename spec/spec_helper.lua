-- mock application modules here
Application = { name = "railsapp" }
package.loaded['config.application'] = {}
package.loaded['config.settings'] = {}
package.loaded['config.database'] = {}

-- init
require 'ralis.spec.init'

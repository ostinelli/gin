-- settings
local settings = require 'zebra.core.settings'


local Zebra = {}

-- version
Zebra.version = '0.0.1'

-- environment
Zebra.env = os.getenv("ZEBRA_ENV") or 'development'

-- directories
Zebra.app_dirs = {
    tmp = 'tmp',
    logs = 'logs',
    schemas = 'db/schemas',
    migrations = 'db/migrations'
}

Zebra.settings = settings.for_environment(Zebra.env)

return Zebra

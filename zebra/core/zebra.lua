-- -- init
-- require 'zebra.core.helpers'
-- require 'zebra.core.request'
-- require 'zebra.core.response'
-- require 'zebra.core.routes'

-- -- libraries
-- JSON = require 'cjson'
-- local lfs = require 'lfs'

-- init zebra
local Zebra = {}

-- version
Zebra.version = '0.0.1'

-- environment
Zebra.env = Zebra.env or os.getenv("ZEBRA_ENV") or 'development'

-- directories
Zebra.app_dirs = {
    tmp = 'tmp',
    logs = 'logs',
    schemas = 'db/schemas',
    migrations = 'db/migrations'
}

-- settings
local settings = require 'zebra.core.settings'
Zebra.settings = settings.for_environment(Zebra.env)

return Zebra

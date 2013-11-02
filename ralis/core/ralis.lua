-- init
require 'ralis.core.helpers'
require 'ralis.core.request'
require 'ralis.core.response'
require 'ralis.core.routes'

-- libraries
JSON = require 'cjson'
local lfs = require 'lfs'

-- init ralis if necessary
Ralis = Ralis or {}

-- version
Ralis.version = '0.1-rc1'

-- environment
Ralis.env = Ralis.env or os.getenv("RALIS_ENV") or 'development'

-- directories
Ralis.dirs = {
    tmp = 'tmp',
    logs = 'logs',
    migrations = 'db/migrations'
}

-- settings
local settings = require 'ralis.core.settings'
Ralis.settings = settings.for_current_environment()

-- load initializers
require_recursive("config/initializers")

-- ensure system errors get defined
require 'ralis.core.error'

return Ralis

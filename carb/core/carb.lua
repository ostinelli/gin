-- init
require 'carb.core.helpers'
require 'carb.core.request'
require 'carb.core.response'
require 'carb.core.routes'

-- libraries
JSON = require 'cjson'
local lfs = require 'lfs'

-- init carb if necessary
Carb = Carb or {}

-- version
Carb.version = '0.1-rc1'

-- environment
Carb.env = Carb.env or os.getenv("CARB_ENV") or 'development'

-- directories
Carb.app_dirs = {
    tmp = 'tmp',
    logs = 'logs',
    schemas = 'db/schemas',
    migrations = 'db/migrations'
}

-- settings
local settings = require 'carb.core.settings'
Carb.settings = settings.for_current_environment()

-- load initializers
require_recursive("config/initializers")

-- ensure system errors get defined
require 'carb.core.error'

return Carb

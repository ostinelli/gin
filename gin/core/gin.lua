-- gin
local settings = require 'gin.core.settings'

-- perf
local ogetenv = os.getenv


local Gin = {}

-- version
Gin.version = '0.2.0'

-- environment
Gin.env = ogetenv("GIN_ENV") or 'development'

-- directories
Gin.app_dirs = {
    tmp = 'tmp',
    logs = 'logs',
    db = 'db',
    schemas = 'db/schemas',
    migrations = 'db/migrations'
}

Gin.settings = settings.for_environment(Gin.env)

return Gin

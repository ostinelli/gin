-- gin
local settings = require 'gin.core.settings'

-- perf
local ogetenv = os.getenv


local Gin = {}

-- version
Gin.version = '0.0.1'

-- environment
Gin.env = ogetenv("GIN_ENV") or 'development'

-- directories
Gin.app_dirs = {
    tmp = 'tmp',
    logs = 'logs',
    schemas = 'db/schemas',
    migrations = 'db/migrations'
}

Gin.settings = settings.for_environment(Gin.env)

return Gin

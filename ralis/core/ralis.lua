require 'ralis.core.request'
CJSON = require 'cjson'

Ralis = {}

-- version
Ralis.version = '0.1'

-- environment
Ralis.env = os.getenv("RALIS_ENV") or 'development'

-- settings
-- local settings = require 'ralis.core.settings'
-- Ralis.settings = settings.for_current_environment()

return Ralis

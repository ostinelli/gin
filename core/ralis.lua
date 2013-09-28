require 'core/request'
CJSON = require 'cjson'

Ralis = {}

-- version
Ralis.version = '0.1'

-- environment
Ralis.env = os.getenv("RALIS_ENV") or 'development'

return Ralis

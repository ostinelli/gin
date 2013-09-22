require 'core/request'
require 'core/response'

Ralis = {}

-- version
Ralis.version = '0.1'

-- environment
Ralis.env = os.getenv("RALIS_ENV") or 'development'

return Ralis

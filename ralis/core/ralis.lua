require 'ralis.core.helpers'
require 'ralis.core.request'
require 'ralis.core.response'
require 'ralis.core.routes'

-- libraries
JSON = require 'cjson'
local lfs = require"lfs"

-- init ralis if necessary
Ralis = Ralis or {}

-- version
Ralis.version = '0.1'

-- environment
Ralis.env = Ralis.env or os.getenv("RALIS_ENV") or 'development'

-- settings
local settings = require 'ralis.core.settings'
Ralis.settings = settings.for_current_environment()

-- load initializers
dofile_recursive("config/initializers")

-- ensure system errors get defined
require 'ralis.core.error'

return Ralis

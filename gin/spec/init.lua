package.path = './?.lua;' .. package.path

-- gin
local helpers = require 'gin.helpers.common'


-- ensure test environment is specified
local posix = require "posix"
posix.setenv("GIN_ENV", 'test')

-- detached
require 'gin.core.detached'

-- helpers
function pp(o)
    return helpers.pp(o)
end

package.path = './?.lua;' .. package.path

-- gin
local Helpers = require 'gin.core.helpers'

-- ensure test environment is specified
local posix = require "posix"
posix.setenv("GIN_ENV", 'test')

-- helpers
function pp(o)
    return Helpers.pp(o)
end

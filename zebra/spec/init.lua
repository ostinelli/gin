package.path = './?.lua;' .. package.path

local posix = require "posix"

-- -- ensure test environment is specified
posix.setenv("ZEBRA_ENV", 'test')

-- init detached
require 'zebra.core.init_detached'

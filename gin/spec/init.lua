package.path = './?.lua;' .. package.path

-- -- ensure test environment is specified
local posix = require "posix"
posix.setenv("GIN_ENV", 'test')

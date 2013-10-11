package.path = './?.lua;' .. package.path

-- ensure test environment is specified
Ralis = {}
Ralis.env = 'test'

require 'ralis.core.ralis'

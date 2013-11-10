package.path = './?.lua;' .. package.path

-- ensure test environment is specified
Zebra = {}
Zebra.env = 'test'

-- init detached
require 'zebra.core.init_detached'

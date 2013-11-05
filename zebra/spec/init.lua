package.path = './?.lua;' .. package.path

-- ensure test environment is specified
Zebra = {}
Zebra.env = 'test'

require 'zebra.core.zebra'

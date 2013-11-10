package.path = './?.lua;' .. package.path

-- ensure test environment is specified
Zebra = {}
Zebra.env = 'test'

-- load detached
require 'zebra.core.zebra'
require 'zebra.core.detached'
require 'zebra.core.init'

local models = require 'zebra.core.models'
models.init()
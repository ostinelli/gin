package.path = './?.lua;' .. package.path

-- ensure test environment is specified
Carb = {}
Carb.env = 'test'

require 'carb.core.carb'

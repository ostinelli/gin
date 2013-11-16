-- dep
local ansicolors = require 'ansicolors'
local prettyprint = require 'pl.pretty'

-- gin
local Gin = require 'gin.core.gin'


local GinConsole = {}

function GinConsole.start()
    print(ansicolors("Loading %{cyan}" .. Gin.env .. "%{reset} environment (Gin v" .. Gin.version .. ")"))
    os.execute("lua -i -e \"require 'gin.core.detached' require 'gin.helpers.command'\"")
end

return GinConsole

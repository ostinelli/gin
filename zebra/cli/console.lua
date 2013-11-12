local ansicolors = require 'ansicolors'
local prettyprint = require 'pl.pretty'

-- zebra
local Zebra = require 'zebra.core.zebra'

local ZebraConsole = {}

function ZebraConsole.start()
    print(ansicolors("Loading %{cyan}" .. Zebra.env .. "%{reset} environment (Zebra v" .. Zebra.version .. ")"))
    os.execute("lua -i -e \"require 'zebra.core.globals'\"")
end

return ZebraConsole

local ansicolors = require 'ansicolors'

require 'zebra.core.zebra'


local ZebraConsole = {}

function ZebraConsole.start()
    print(ansicolors("Loading %{cyan}" .. Zebra.env .. "%{reset} environment (Zebra v" .. Zebra.version .. ")"))
    os.execute("lua -i -e \"require 'zebra.core.zebra' require 'zebra.core.detached' require 'zebra.core.init'\"")
end


return ZebraConsole

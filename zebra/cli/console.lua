require 'zebra.core.zebra'


local ZebraConsole = {}

function ZebraConsole.start()
    os.execute("lua -i -e \"require 'zebra.core.zebra' require 'zebra.core.detached' require 'zebra.core.init'\"")
end


return ZebraConsole

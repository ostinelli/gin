require 'core/ralis'

local RalisLauncher = {}

function RalisLauncher.start()
    result = os.execute("nginx -p `pwd`/ -c config/" .. RalisLauncher.config_file_name())
    if result == 0 and Ralis.env ~= 'test' then print("Ralis app was succesfully started.") end
end

function RalisLauncher.stop()
    result = os.execute("nginx -s stop -p `pwd`/ -c config/" .. RalisLauncher.config_file_name())
    if Ralis.env ~= 'test' then
        if result == 0 then
            print("Ralis app was succesfully stopped.")
        else
            print("ERROR: Could not stop Ralis app (maybe not started?)")
        end
    end
end

function RalisLauncher.config_file_name()
    return "nginx." .. Ralis.env .. ".conf"
end

return RalisLauncher

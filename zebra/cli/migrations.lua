-- dependencies
local ansicolors = require 'ansicolors'

require 'zebra.core.zebra'
require 'zebra.core.helpers'
local migrations = require 'zebra.db.migrations'


local migrations_new = [====[
local SqlMigration = {}

-- specify the database used in this migration (needed by the Zebra migration engine)
SqlMigration.db = MYSQLDB

function SqlMigration.up()
    -- Run your migration, for instance:
    -- SqlMigration.db:execute([[
    --     CREATE TABLE users (
    --         id int NOT NULL AUTO_INCREMENT,
    --         first_name varchar(255) NOT NULL,
    --         last_name varchar(255),
    --         PRIMARY KEY (id)
    --     );
    -- ]])
end

function SqlMigration.down()
    -- Run your rollback, for instance:
    -- SqlMigration.db:execute([[
    --     DROP TABLE users;
    -- ]])
end

return SqlMigration
]====]


local function display_result(direction, response)
    local error_head, error_message, success_message, symbol

    if direction == "up" then
        error_head = "An error occurred while running the migration:"
        error_message = "More recent migrations have been canceled. Please review the error:"
        success_message = "Successfully applied migration:"
        symbol = "==>"
    else
        error_head = "An error occurred while rolling back the migration:"
        error_message = "Please review the error:"
        success_message = "Successfully rolled back migration:"
        symbol = "<=="
    end

    if #response > 0 then
        for k, version_info in ipairs(response) do
            if version_info.error ~= nil then
                print(ansicolors("%{red}ERROR:%{reset} " .. error_head .. " %{cyan}" .. version_info.version .. "%{reset}"))
                print(error_message)
                print("-------------------------------------------------------------------")
                print(version_info.error)
                print("-------------------------------------------------------------------")
            else
                print(ansicolors(symbol .. " %{green}" .. success_message .. "%{reset} " .. version_info.version))
            end
        end
    end
end


local SqlMigrations = {}

function SqlMigrations.new(name)
    -- define file path
    local timestamp = os.date("%Y%m%d%H%M%S")
    local full_file_path = Zebra.app_dirs.migrations .. '/' .. timestamp .. '.lua'

    -- create file
    local fw = io.open(full_file_path, "w")
    fw:write(migrations_new)
    fw:close()

    -- output message
    print(ansicolors("%{green}Created new migration file%{reset}"))
    print("  " .. full_file_path)
end

function SqlMigrations.up()
    local ok, response = migrations.up()
    display_result("up", response)

end

function SqlMigrations.down()
    local ok, response = migrations.down()
    display_result("down", response)
end

return SqlMigrations

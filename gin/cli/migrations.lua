-- dep
local ansicolors = require 'ansicolors'

-- gin
local Gin = require 'gin.core.gin'
local helpers = require 'gin.helpers.common'
local Migrations = require 'gin.db.migrations'


local migrations_new = [====[
local SqlMigration = {}

-- specify the database used in this migration (needed by the Gin migration engine)
-- SqlMigration.db = require 'db.mysql'

function SqlMigration.up()
    -- Run your migration
end

function SqlMigration.down()
    -- Run your rollback
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
    local full_file_path = Gin.app_dirs.migrations .. '/' .. timestamp .. (name and '_' .. name or '') .. '.lua'

    -- create file
    local fw = io.open(full_file_path, "w")
    fw:write(migrations_new)
    fw:close()

    -- output message
    print(ansicolors("%{green}Created new migration file%{reset}"))
    print("  " .. full_file_path)
end

function SqlMigrations.up()
    print(ansicolors("Migrating up in %{cyan}" .. Gin.env .. "%{reset} environment"))

    local ok, response = Migrations.up()
    display_result("up", response)

end

function SqlMigrations.down()
    print(ansicolors("Rolling back one migration in %{cyan}" .. Gin.env .. "%{reset} environment"))

    local ok, response = Migrations.down()
    display_result("down", response)
end

return SqlMigrations

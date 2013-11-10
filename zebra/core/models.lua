local Models = {}

-- require recursively in a directory
local function init_models(path)
    if folder_exists(path) then
        for file_name in lfs.dir(path) do
            if file_name ~= "." and file_name ~= ".." then
                local file_path = path .. '/' .. file_name
                local attr = lfs.attributes(file_path)
                assert(type(attr) == "table")
                if attr.mode == "directory" then
                    -- recursive call for all subdirectories inside of directory
                    init_models(file_path)
                else
                    local module_name = get_lua_module_name(file_path)
                    -- require initializer
                    if module_name ~= nil then
                        local model = require(module_name)
                        model.init()
                    end
                end
            end
        end
    end
end

function Models.init()
    -- load application models
    init_models("app/models")
end

return Models

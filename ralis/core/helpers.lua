local lfs = require 'lfs'

-- check if folder exists
function folder_exists(folder_path)
    return lfs.attributes(folder_path:gsub("\\$",""), "mode") == "directory"
end

-- split function in
function split(str, pat)
    local t = {}
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)

    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
    end

    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end

    return t
end

function split_path(str)
   return split(str, '[\\/]+')
end

function mkdirs(file_path)
    -- get dir path and parts
    dir_path = string.match(file_path, "(.*)/.*")
    parts = split_path(dir_path)
    -- loop
    local current_dir = nil
    for _, part in ipairs(parts) do
        if current_dir == nil then
            current_dir = part
        else
            current_dir = current_dir .. '/' .. part
        end
        lfs.mkdir(current_dir)
    end
end

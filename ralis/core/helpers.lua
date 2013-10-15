-- dependencies
local lfs = require 'lfs'

-- perf
local assert = assert
local dofile = dofile
local ipairs = ipairs
local type = type
local lfs_attributes = lfs.attributes
local lfs_dir = lfs.dir
local lfs_mkdir = lfs.mkdir
local string_find = string.find
local string_match = string.match
local table_insert = table.insert


-- check if folder exists
function folder_exists(folder_path)
    return lfs_attributes(folder_path:gsub("\\$",""), "mode") == "directory"
end

-- split function
function split(str, pat)
    local t = {}
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = string_find(str, fpat, 1)

    while s do
        if s ~= 1 or cap ~= "" then
            table_insert(t,cap)
        end
        last_end = e+1
        s, e, cap = string_find(str, fpat, last_end)
    end

    if last_end <= #str then
        cap = string_find(str, last_end)
        table_insert(t, cap)
    end

    return t
end

-- split a path in individual parts
function split_path(str)
   return split(str, '[\\/]+')
end

-- recursively make directories
function mkdirs(file_path)
    -- get dir path and parts
    dir_path = string_match(file_path, "(.*)/.*")
    parts = split_path(dir_path)
    -- loop
    local current_dir = nil
    for _, part in ipairs(parts) do
        if current_dir == nil then
            current_dir = part
        else
            current_dir = current_dir .. '/' .. part
        end
        lfs_mkdir(current_dir)
    end
end

-- dofile recursively in a directory
function dofile_recursive(path)
    if folder_exists(path) then
        for file_name in lfs.dir(path) do
            if file_name ~= "." and file_name ~= ".." then
                local file_path = path .. '/' .. file_name
                local attr = lfs_attributes(file_path)
                assert(type(attr) == "table")
                if attr.mode == "directory" then
                    -- recursive call for all subdirectories inside of initializers
                    run_initializers(file_path)
                else
                    -- run initializer
                    dofile(file_path)
                end
            end
        end
    end
end

-- dependencies
local lfs = require 'lfs'

-- perf
local assert = assert
local dofile = dofile
local ipairs = ipairs
local lfs = lfs
local type = type
local strfind = string.find
local strmatch = string.match
local tinsert = table.insert


-- check if folder exists
function folder_exists(folder_path)
    return lfs.attributes(folder_path:gsub("\\$",""), "mode") == "directory"
end

-- split function
function split(str, pat)
    local t = {}
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = strfind(str, fpat, 1)

    while s do
        if s ~= 1 or cap ~= "" then
            tinsert(t,cap)
        end
        last_end = e+1
        s, e, cap = strfind(str, fpat, last_end)
    end

    if last_end <= #str then
        cap = strfind(str, last_end)
        tinsert(t, cap)
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
    dir_path = strmatch(file_path, "(.*)/.*")
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

-- dofile recursively in a directory
function dofile_recursive(path)
    if folder_exists(path) then
        for file_name in lfs.dir(path) do
            if file_name ~= "." and file_name ~= ".." then
                local file_path = path .. '/' .. file_name
                local attr = lfs.attributes(file_path)
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

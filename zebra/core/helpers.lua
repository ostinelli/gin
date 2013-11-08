-- dependencies
local lfs = require 'lfs'
local prettyprint = require 'pl.pretty'

-- perf
local strmatch = string.match
local strfind = string.find
local strsub = string.sub
local strgsub = string.gsub
local tinsert = table.insert
local ipairs = ipairs
local assert = assert
local type = type
local require = require

-- read file
function read_file(file_path)
    local f = io.open(file_path, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

-- check if folder exists
function folder_exists(folder_path)
    return lfs.attributes(strgsub(folder_path, "\\$",""), "mode") == "directory"
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
        cap = strsub(str, last_end)
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

-- get the lua module name?
function get_lua_module_name(file_path)
    return string.match(file_path, "(.*)%.lua")
end

-- require recursively in a directory
function require_recursive(path)
    if folder_exists(path) then
        for file_name in lfs.dir(path) do
            if file_name ~= "." and file_name ~= ".." then
                local file_path = path .. '/' .. file_name
                local attr = lfs.attributes(file_path)
                assert(type(attr) == "table")
                if attr.mode == "directory" then
                    -- recursive call for all subdirectories inside of directory
                    require_recursive(file_path)
                else
                    local module_name = get_lua_module_name(file_path)
                    -- require initializer
                    if module_name ~= nil then
                        require(module_name)
                    end
                end
            end
        end
    end
end

-- reverse indexed table
function table.reverse(tab)
    local size = #tab + 1
    local reversed = {}
    for i, v in ipairs(tab) do
        reversed[size - i] = v
    end
    return reversed
end

-- included in array
function included(t, value)
    for _, v in ipairs(t) do
        if v == value then return true end
    end
    return false
end

-- pretty print
function pp(o)
    prettyprint.dump(o)
end

-- pretty print to file
function pp_to_file(o, file_path)
    prettyprint.dump(o, file_path)
end

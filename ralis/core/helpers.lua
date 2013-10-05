local lfs = require"lfs"

-- check if folder exists
function folder_exists(folder_path)
    return lfs.attributes(folder_path:gsub("\\$",""), "mode") == "directory"
end

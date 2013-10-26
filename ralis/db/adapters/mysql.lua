-- perf
local error = error
local require = require


local mysql = require "resty.mysql"
local timeout_subsequent_ops = 1000 -- 1 sec
local max_idle_timeout = 10000 -- 10 sec
local max_packet_size = 1024 * 1024 -- 1MB

local MySql = {}

local function mysql_connect(options)
    -- create sql object
    local db, err = mysql:new()
    if not db then error("failed to instantiate mysql: " .. err) end
    -- set 1 second timeout for suqsequent operations
    db:set_timeout(timeout_subsequent_ops)
    -- connect to db
    local db_options = {
        host = options.host,
        port = options.port,
        database = options.database,
        user = options.user,
        password = options.password,
        max_packet_size = max_packet_size
    }
    local ok, err, errno, sqlstate = db:connect(db_options)
    if not ok then error("failed to connect to mysql: " .. err .. ": " .. errno .. " " .. sqlstate) end
    -- return
    return db
end

local function mysql_keepalive(db, options)
    -- put it into the connection pool
    local ok, err = db:set_keepalive(max_idle_timeout, options.pool)
    if not ok then error("failed to set mysql keepalive: ", err) end
end


function MySql.execute(options, sql)
    -- get db object
    local db = mysql_connect(options)
    -- execute query
    local res, err, errno, sqlstate = db:execute(sql)
    if not res then error("bad mysql result: " .. err .. ": " .. errno .. " " .. sqlstate) end
    -- keepalive
    mysql_keepalive(db, options)
    -- return
    return res
end

return MySql

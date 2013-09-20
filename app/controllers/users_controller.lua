local M = {}

function M.index(ngx, params)
    ngx.say('Index of Users!')
end

function M.show(ngx, params)
    ngx.say('Show user with id: ' .. params.id)
end

return M

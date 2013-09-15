local M = {}

function M.index(ngx, params)
	ngx.say('Hello Users!')
end

return M

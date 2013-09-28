
Request = {}
Request.__index = Request

function Request.new(ngx)
    local instance = {
        ngx = ngx,
        body = ngx.req.read_body(),
        __cache = {}
    }
    setmetatable(instance, Request)
    return instance
end

function Request:uri_params()
    return self:get_and_set_cache('uri_params', ngx.req.get_uri_args)
end

function Request:headers()
    return self:get_and_set_cache('headers', ngx.req.get_headers)
end

function Request:post_params()
    return self:get_and_set_cache('post_params', ngx.req.get_post_args)
end

function Request:get_and_set_cache(index, fun)
    local value = self.__cache[index]
    if value then return value end

    value = fun()
    self.__cache.uri_params = value
    return value
end

return Request

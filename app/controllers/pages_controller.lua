local PagesController = {}

function PagesController:body_and_url()
    json_body = CJSON.decode(self.request.body)
    return { page = self.request.uri_params.page, user = json_body.user }
end

function PagesController:catch_all()
    return { name = self.params[1] }
end

return PagesController

local PagesController = {}

function PagesController:catch_all()
    return { name = self.params[1] }
end

return PagesController

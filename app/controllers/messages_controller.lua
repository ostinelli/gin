local MessagesController = {}

function MessagesController:index()
    return { recipient = self.params.user_id, messages = { 'abc' } }
end

function MessagesController:show()
    return { message = { id = self.params.id, recipient = self.params.user_id, body = "Ralis is awesome." } }
end

return MessagesController

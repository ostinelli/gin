local MessagesController = {}

function MessagesController:index()
    return 'Index of messages for user: ' .. self.params.user_id
end

function MessagesController:show()
    return 'Messages with id: ' .. self.params.id .. ' of user: ' .. self.params.user_id
end

return MessagesController

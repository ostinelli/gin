local UsersController = {}

function UsersController:index()
    return 'Index of Users!'
end

function UsersController:show()
    return 'Page of user with id: ' .. self.params.id
end

return UsersController

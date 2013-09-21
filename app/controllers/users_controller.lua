local UsersController = {}

function UsersController:index()
    return { users = { 'roberto' } }
end

function UsersController:show()
    return { name = self.params.id }
end

return UsersController

local routes = require('core/routes')

-- define routes
routes.get("/users", { controller = "users", action = "index" })
routes.get("/users/:id", { controller = "users", action = "show" })

return routes

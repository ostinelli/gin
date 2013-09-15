local routes = require('core/routes')

-- define routes
routes.GET("/users", { controller = "users", action = "index" })
routes.GET("/users/:id", { controller = "users", action = "show" })

return routes

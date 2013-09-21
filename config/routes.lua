local routes = require 'core/routes'

-- define routes
routes.GET("/users", { controller = "users", action = "index" })
routes.GET("/users/:id", { controller = "users", action = "show" })
routes.GET("/users/:user_id/messages", { controller = "messages", action = "index" })
routes.GET("/users/:user_id/messages/:id", { controller = "messages", action = "show" })
routes.GET("/pages/(.+)", { controller = "pages", action = "catch_all" })

return routes

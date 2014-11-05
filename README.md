# GIN JSON-API framework

Gin is an JSON-API framework, currently in its early stage.

It has been designed to allow for fast development, TDD and ease of maintenance.

Gin is helpful when you need an extra-boost in performance and scalability, as it runs embedded in a packaged version of nginx
called [OpenResty](http://openresty.org/) and it's entirely written in [Lua](http://www.lua.org/).
For those not familiar with Lua, don't let that scare you away: Lua is really easy to use, very fast and simple to get started with.

For instance, this is what a simple Gin controller looks like:

```lua
local InfoController = {}

function InfoController:whoami()
    return 200, { name = 'gin' }
end

return InfoController
```

#### Features

Gin already provides:

 * [API Versioning](http://gin.io/docs/api_versioning.html) embedded in the framework
 * [Routes](http://gin.io/docs/routes.html) with named and pattern routes support
 * [Controllers](http://gin.io/docs/controllers.html)
 * [Models](http://gin.io/docs/models.html) and a MySql ORM
 * [Migrations](http://gin.io/docs/migrations.html) for SQL engines
 * [Test helpers](http://gin.io/docs/testing.html) and wrappers
 * Simple [error](http://gin.io/docs/errors.html) raising and definition
 * Support for multiple databases in your application
 * An embedded [API Console](http://gin.io/docs/api_console.html) to play with your API
 * A client to create, start and stop your applications

Get started now! Please refer to the official [gin.io](http://gin.io) website for documentation.

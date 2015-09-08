[![Build Status](https://travis-ci.org/ostinelli/gin.svg?branch=master)](https://travis-ci.org/ostinelli/gin)

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

When called, this returns an HTTP `200` response with body:

```json
{
	"name": "gin"
}
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


#### Contributing
So you want to contribute? That's great!
Please follow the guidelines below. It will make it easier to get merged in.

Before implementing a new feature, please submit a ticket to discuss what you intend to do.
Your feature might already be in the works, or an alternative implementation might have already been discussed.

Every pull request should have its own topic branch.
In this way, every additional adjustments to the original pull request might be done easily, and
squashed with `git rebase -i`. The updated branch will be visible in the same pull request, so
there will be no need to open new pull requests when there are changes to be applied.

Do not commit to master in your fork.
Provide a clean branch without merge commits.

Ensure to include proper testing. To test gin you simply have to be in the project's root directory
and issue:

```
$ busted

●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●● ○
195 successes / 0 failures / 0 pending : 0.156489 seconds.
```

There will be no merges without a clean build.

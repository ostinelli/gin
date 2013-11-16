package = "gin"
version = "dev-1"

source = {
    url = "git://github.com/ostinelli/gin.git"
}

description = {
    summary = "A fast, low-latency, low-memory footprint, web JSON-API framework with Test Driven Development helpers and patterns.",
    homepage = "http://gin.io",
    maintainer = "Roberto Ostinelli <roberto@ostinelli.net>",
    license = "MIT"
}

dependencies = {
    "lua >= 5.1",
    "ansicolors",
    "busted",
    "lua-cjson",
    "luasocket",
    "luafilesystem",
    "luaposix",
    "penlight"
}

build = {
    type = "builtin",
    modules = {
        ["gin.cli.api_console"] = "gin/cli/api_console.lua",
        ["gin.cli.application"] = "gin/cli/application.lua",
        ["gin.cli.base_launcher"] = "gin/cli/base_launcher.lua",
        ["gin.cli.console"] = "gin/cli/console.lua",
        ["gin.cli.launcher"] = "gin/cli/launcher.lua",
        ["gin.cli.migrations"] = "gin/cli/migrations.lua",
        ["gin.core.controller"] = "gin/core/controller.lua",
        ["gin.core.detached"] = "gin/core/detached.lua",
        ["gin.core.error"] = "gin/core/error.lua",
        ["gin.core.gin"] = "gin/core/gin.lua",
        ["gin.core.request"] = "gin/core/request.lua",
        ["gin.core.response"] = "gin/core/response.lua",
        ["gin.core.router"] = "gin/core/router.lua",
        ["gin.core.routes"] = "gin/core/routes.lua",
        ["gin.core.settings"] = "gin/core/settings.lua",
        ["gin.db.sql.mysql.adapter"] = "gin/db/sql/mysql/adapter.lua",
        ["gin.db.sql.mysql.adapter_detached"] = "gin/db/sql/mysql/adapter_detached.lua",
        ["gin.db.sql.mysql.orm"] = "gin/db/sql/mysql/orm.lua",
        ["gin.db.sql.orm"] = "gin/db/sql/orm.lua",
        ["gin.db.migrations"] = "gin/db/migrations.lua",
        ["gin.db.sql"] = "gin/db/sql.lua",
        ["gin.helpers.command"] = "gin/helpers/command.lua",
        ["gin.helpers.common"] = "gin/helpers/common.lua",
        ["gin.spec.runners.integration"] = "gin/spec/runners/integration.lua",
        ["gin.spec.runners.response"] = "gin/spec/runners/response.lua",
        ["gin.spec.init"] = "gin/spec/init.lua",
        ["gin.spec.runner"] = "gin/spec/runner.lua",
    },
    install = {
        bin = { "bin/gin" }
    },
}

package = "gin"
version = "0.2.0-1"

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
    "lua = 5.1",
    "ansicolors = 1.0.2-3",
    "busted = 2.0.rc10-0",
    "lua-cjson = 2.1.0-1",
    "luasocket = 3.0rc1-2",
    "luafilesystem = 1.6.3-1",
    "luaposix = 33.3.1-1",
    "penlight = 1.3.2-2",
    "luadbi = 0.5-1"
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
        ["gin.db.sql.common.orm"] = "gin/db/sql/common/orm.lua",
        ["gin.db.sql.mysql.adapter"] = "gin/db/sql/mysql/adapter.lua",
        ["gin.db.sql.mysql.adapter_detached"] = "gin/db/sql/mysql/adapter_detached.lua",
        ["gin.db.sql.mysql.orm"] = "gin/db/sql/mysql/orm.lua",
        ["gin.db.sql.postgresql.adapter"] = "gin/db/sql/postgresql/adapter.lua",
        ["gin.db.sql.postgresql.adapter_detached"] = "gin/db/sql/postgresql/adapter_detached.lua",
        ["gin.db.sql.postgresql.helpers"] = "gin/db/sql/postgresql/helpers.lua",
        ["gin.db.sql.postgresql.orm"] = "gin/db/sql/postgresql/orm.lua",
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

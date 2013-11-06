package = "zebra"
version = "dev-1"

source = {
    url = "git://github.com/ostinelli/zebra.git"
}

description = {
    summary = "A fast, low-latency, low-memory footprint, web JSON-API framework with Test Driven Development helpers and patterns.",
    homepage = "http://zebra.io",
    maintainer = "Roberto Ostinelli <roberto@ostinelli.net>",
    license = "MIT"
}

dependencies = {
    "lua >= 5.1",
    "ansicolors",
    "busted",
    "lua-cjson",
    "luasocket",
    "luafilesystem"
}

build = {
    type = "builtin",
    modules = {
        ["zebra.cli.api_console"] = "zebra/cli/api_console.lua",
        ["zebra.cli.application"] = "zebra/cli/application.lua",
        ["zebra.cli.base_launcher"] = "zebra/cli/base_launcher.lua",
        ["zebra.cli.console"] = "zebra/cli/console.lua",
        ["zebra.cli.launcher"] = "zebra/cli/launcher.lua",
        ["zebra.cli.sql_migrations"] = "zebra/cli/sql_migrations.lua",
        ["zebra.core.controller"] = "zebra/core/controller.lua",
        ["zebra.core.error"] = "zebra/core/error.lua",
        ["zebra.core.helpers"] = "zebra/core/helpers.lua",
        ["zebra.core.init"] = "zebra/core/init.lua",
        ["zebra.core.local"] = "zebra/core/local.lua",
        ["zebra.core.request"] = "zebra/core/request.lua",
        ["zebra.core.response"] = "zebra/core/response.lua",
        ["zebra.core.router"] = "zebra/core/router.lua",
        ["zebra.core.routes"] = "zebra/core/routes.lua",
        ["zebra.core.zebra"] = "zebra/core/zebra.lua",
        ["zebra.core.settings"] = "zebra/core/settings.lua",
        ["zebra.db.sql.mysql.adapter"] = "zebra/db/sql/mysql/adapter.lua",
        ["zebra.db.sql.mysql.adapter_local"] = "zebra/db/sql/mysql/adapter_local.lua",
        ["zebra.db.sql.mysql.orm"] = "zebra/db/sql/mysql/orm.lua",
        ["zebra.db.sql.migrations"] = "zebra/db/sql/migrations.lua",
        ["zebra.db.sql"] = "zebra/db/sql.lua",
        ["zebra.spec.runners.integration"] = "zebra/spec/runners/integration.lua",
        ["zebra.spec.runners.response"] = "zebra/spec/runners/response.lua",
        ["zebra.spec.init"] = "zebra/spec/init.lua",
        ["zebra.spec.runner"] = "zebra/spec/runner.lua",
    },
    install = {
        bin = { "bin/zebra" }
    },
}

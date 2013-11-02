package = "ralis"
version = "dev-1"

source = {
    url = "git://github.com/ostinelli/ralis.git"
}

description = {
    summary = "A fast, low-latency, low-memory footprint, web JSON-API framework with Test Driven Development helpers and patterns.",
    homepage = "http://ralis.io",
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
        ["ralis.cli.api_console"] = "ralis/cli/api_console.lua",
        ["ralis.cli.application"] = "ralis/cli/application.lua",
        ["ralis.cli.base_launcher"] = "ralis/cli/base_launcher.lua",
        ["ralis.cli.launcher"] = "ralis/cli/launcher.lua",
        ["ralis.cli.sql_migrations"] = "ralis/cli/sql_migrations.lua",
        ["ralis.core.controller"] = "ralis/core/controller.lua",
        ["ralis.core.error"] = "ralis/core/error.lua",
        ["ralis.core.helpers"] = "ralis/core/helpers.lua",
        ["ralis.core.init"] = "ralis/core/init.lua",
        ["ralis.core.ralis"] = "ralis/core/ralis.lua",
        ["ralis.core.request"] = "ralis/core/request.lua",
        ["ralis.core.response"] = "ralis/core/response.lua",
        ["ralis.core.router"] = "ralis/core/router.lua",
        ["ralis.core.routes"] = "ralis/core/routes.lua",
        ["ralis.core.settings"] = "ralis/core/settings.lua",
        ["ralis.db.sql.mysql.adapter"] = "ralis/db/sql/mysql/adapter.lua",
        ["ralis.db.sql.mysql.orm"] = "ralis/db/sql/mysql/orm.lua",
        ["ralis.db.sql.migration"] = "ralis/db/sql/migration.lua",
        ["ralis.db.sql"] = "ralis/db/sql.lua",
        ["ralis.spec.runners.integration"] = "ralis/spec/runners/integration.lua",
        ["ralis.spec.runners.response"] = "ralis/spec/runners/response.lua",
        ["ralis.spec.init"] = "ralis/spec/init.lua",
        ["ralis.spec.runner"] = "ralis/spec/runner.lua",
    },
    install = {
        bin = { "bin/ralis" }
    },
}

package = "carb"
version = "dev-1"

source = {
    url = "git://github.com/ostinelli/carb.git"
}

description = {
    summary = "A fast, low-latency, low-memory footprint, web JSON-API framework with Test Driven Development helpers and patterns.",
    homepage = "http://carb.io",
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
        ["carb.cli.api_console"] = "carb/cli/api_console.lua",
        ["carb.cli.application"] = "carb/cli/application.lua",
        ["carb.cli.base_launcher"] = "carb/cli/base_launcher.lua",
        ["carb.cli.launcher"] = "carb/cli/launcher.lua",
        ["carb.cli.sql_migrations"] = "carb/cli/sql_migrations.lua",
        ["carb.core.carb"] = "carb/core/carb.lua",
        ["carb.core.controller"] = "carb/core/controller.lua",
        ["carb.core.error"] = "carb/core/error.lua",
        ["carb.core.helpers"] = "carb/core/helpers.lua",
        ["carb.core.init"] = "carb/core/init.lua",
        ["carb.core.request"] = "carb/core/request.lua",
        ["carb.core.response"] = "carb/core/response.lua",
        ["carb.core.router"] = "carb/core/router.lua",
        ["carb.core.routes"] = "carb/core/routes.lua",
        ["carb.core.settings"] = "carb/core/settings.lua",
        ["carb.db.sql.mysql.adapter"] = "carb/db/sql/mysql/adapter.lua",
        ["carb.db.sql.mysql.orm"] = "carb/db/sql/mysql/orm.lua",
        ["carb.db.sql.migration"] = "carb/db/sql/migration.lua",
        ["carb.db.sql"] = "carb/db/sql.lua",
        ["carb.spec.runners.integration"] = "carb/spec/runners/integration.lua",
        ["carb.spec.runners.response"] = "carb/spec/runners/response.lua",
        ["carb.spec.init"] = "carb/spec/init.lua",
        ["carb.spec.runner"] = "carb/spec/runner.lua",
    },
    install = {
        bin = { "bin/carb" }
    },
}

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
    "luasec",
    "luafilesystem"
}

build = {
    type = "builtin",
    modules = {
        ["ralis.cli.launcher"] = "ralis/cli/launcher.lua",
        ["ralis.cli.application"] = "ralis/cli/application.lua",
        ["ralis.core.controller"] = "ralis/core/controller.lua",
        ["ralis.core.database"] = "ralis/core/database.lua",
        ["ralis.core.error"] = "ralis/core/error.lua",
        ["ralis.core.helpers"] = "ralis/core/helpers.lua",
        ["ralis.core.ralis"] = "ralis/core/ralis.lua",
        ["ralis.core.response"] = "ralis/core/response.lua",
        ["ralis.core.request"] = "ralis/core/request.lua",
        ["ralis.core.router"] = "ralis/core/router.lua",
        ["ralis.core.routes"] = "ralis/core/routes.lua",
        ["ralis.core.settings"] = "ralis/core/settings.lua",
        ["ralis.db.db"] = "ralis/db/db.lua",
        ["ralis.db.adapters.mysql"] = "ralis/db/adapters/mysql.lua",
        ["ralis.spec.init"] = "ralis/spec/init.lua",
        ["ralis.spec.runner"] = "ralis/spec/runner.lua",
        ["ralis.spec.runners.integration"] = "ralis/spec/runners/integration.lua",
        ["ralis.spec.runners.response"] = "ralis/spec/runners/response.lua"
    },
    install = {
        bin = { "bin/ralis" }
    },
}

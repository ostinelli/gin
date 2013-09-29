local AppConfig = {}

AppConfig.development = {
    worker_processes = 1,
    worker_connections = 1024,
    port = 7200
}

AppConfig.test = {
    worker_processes = 1,
    worker_connections = 1024,
    port = 7201
}

AppConfig.production = {
    worker_processes = 4,
    worker_connections = 16384,
    port = 80
}

return AppConfig

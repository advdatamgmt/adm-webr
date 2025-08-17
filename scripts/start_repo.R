httpuv::runStaticServer(
    dir = "scripts/output/repo",
    port = 9090,
    browse = FALSE,
    headers = list("Access-Control-Allow-Origin" = "*")
)

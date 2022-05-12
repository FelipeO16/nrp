local cfg = {}

-- mysql credentials
cfg.db = {
    driver = "ghmattimysql",
    host = "localhost",
    database = "nolife",
    user = "root",
    password = ""
}

cfg.save_interval = 30 -- segundo
cfg.whitelist = true -- ativar/desativar whitelist
cfg.load_duration = 20
cfg.load_delay = 60
cfg.global_delay = 0

cfg.ping_timeout = 5
cfg.ignore_ip_identifier = true
cfg.lang = "en"
cfg.debug = false
cfg.debug_async_time = 2

return cfg

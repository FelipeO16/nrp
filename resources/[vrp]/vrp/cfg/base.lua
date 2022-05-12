local cfg = {}

-- mysql credentials
cfg.db = {
    host = "127.0.0.1", -- database ip (default is local)
    database = "nolife", -- name of database
    user = "root", --  database username
    password = "" -- password of your database
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

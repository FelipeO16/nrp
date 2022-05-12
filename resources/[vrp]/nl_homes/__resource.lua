description "vRP Casas para IceBase"

client_script {
    "@vrp/lib/utils.lua",
    "client.lua"
}

server_script {
    "@vrp/lib/utils.lua",
    "server.lua"
}

ui_page { 
    "ui/ui.html"
}

files {
    "ui/ui.html",
    "ui/ui.css",
    "ui/ui.js",

    
    "ui/fonts/stratumno1_bold-webfont.woff",
    "ui/fonts/stratumno1_bold-webfont.woff2",
    "ui/fonts/stratumno1_light-webfont.woff",
    "ui/fonts/stratumno1_light-webfont.woff2",
}
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
    "HTML/ui.html"
}

files {
    "HTML/ui.html",
    "HTML/css/ui.css",
    "HTML/js/ui.js",
}
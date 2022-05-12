fx_version 'bodacious'
games { 'gta5' }

client_script {
    "@vrp/lib/utils.lua",
    "cfg/config.lua",
    "client.lua"
}

server_script {
    "@vrp/lib/utils.lua",
    "server.lua"
}

ui_page "html/ui.html"

files {
    "html/ui.html",
    "html/ui.css",
    "html/ui.js"
}

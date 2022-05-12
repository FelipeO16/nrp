resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description "Concessionaria NoLife RP"

client_script {
    "@vrp/lib/utils.lua",
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
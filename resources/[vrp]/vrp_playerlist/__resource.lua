dependency "vrp"
ui_page "ui/ui.html"

files {
  "ui/ui.html",
  "ui/ui.js",
  "ui/ui.css",
}

client_script {
  '@vrp/lib/utils.lua',
  'client.lua',
}

server_script {
  '@vrp/lib/utils.lua',
  'server.lua'
}
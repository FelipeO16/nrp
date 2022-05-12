ui_page "ui/ui.html"

files {
  "ui/ui.html",
  "ui/OwlCarousel2-2.3.4/docs/assets/vendors/jquery.min.js",
  "ui/OwlCarousel2-2.3.4/dist/assets/owl.carousel.min.css",
  "ui/OwlCarousel2-2.3.4/dist/owl.carousel.js",
  "ui/ui.js",
  "ui/ui.css",
}

client_script {
    '@vrp/lib/utils.lua',
    'cfg/config.lua',
    'client.lua'
}

server_script {
    '@vrp/lib/utils.lua',
    'server.lua'
}
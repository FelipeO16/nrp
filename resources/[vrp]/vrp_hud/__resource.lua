resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'
ui_page "ui/ui.html"

files {
  "ui/ui.html",
	"ui/ui.css",
	"ui/fonts/big_noodle_titling-webfont.woff",
	"ui/fonts/big_noodle_titling-webfont.woff2",
	"ui/fonts/pricedown.ttf",
}

client_script{ 
	'@vrp/lib/utils.lua',
	'client.lua'
}

server_script{
	'@vrp/lib/utils.lua',
	'server.lua'
}
resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description "RP module/framework"
ui_page "gui/index.html"


server_scripts{ 
  "lib/utils.lua",
  "base.lua",

  -- Comandos
  "comandos/admin.lua",
  "comandos/player.lua",

  -- Modules
  "modules/utils.lua",
  "modules/gui.lua",
  "modules/admin.lua",
  "modules/survival.lua",
  "modules/player_state.lua",
  "modules/inventory.lua",
  "modules/identity.lua",
  "modules/money.lua",
  --"modules/business.lua",
  --"modules/item_transformer.lua",
  --"modules/emotes.lua",
  "modules/mission.lua",
  "modules/map.lua",
  "modules/group.lua",
  --"modules/police.lua",
  --"modules/basic_atm.lua",
  "modules/basic_items.lua",
  "modules/basic_garage.lua",
  "modules/aptitude.lua",
  "modules/cloakroom.lua",
  "modules/home.lua",
  --"modules/home_components.lua",
}


client_scripts{
  "lib/utils.lua",
  "client/base.lua",
  "client/iplloader.lua",
  "client/map.lua",
  "client/radar.lua",
  "client/gui.lua",
  "client/admin.lua",
  "client/player_state.lua",
  "client/basic_garage.lua",
  "client/garagem.lua",
  "client/survival.lua",
  "client/identity.lua",
  "client/police.lua",
  "client/teleport.lua",
  "client/utils.lua"
}


files{
  "lib/Tunnel.lua",
  "lib/Proxy.lua",
  "lib/Debug.lua",
  "lib/Luaseq.lua",
  "lib/Tools.lua",
  "cfg/client.lua",
  "cfg/teleport.lua",
  "gui/index.html",
  "gui/design.css",
  "gui/main.js",
  "gui/Menu.js",
  "gui/ProgressBar.js",
  "gui/WPrompt.js",
  "gui/RequestManager.js",
  "gui/AnnounceManager.js",
  "gui/Div.js",
  "gui/dynamic_classes.js",
  'gui/fonts/big_noodle_titling-webfont.woff',
  'gui/fonts/big_noodle_titling-webfont.woff2',
  'gui/fonts/pricedown.ttf',
}

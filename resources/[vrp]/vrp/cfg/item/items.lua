-- define items, see the Inventory API on github

local cfg = {}

-- see the manual to understand how to create parametric items
-- idname = {name or genfunc, description or genfunc, genfunc choices or nil, weight or genfunc}
-- a good practice is to create your own item pack file instead of adding items here
cfg.items = {
	["pilulas"] = { "Pilulas","",nil,0.8 },
	
	["cafe"] = {"Café", "", nil, 0.5},
	["cha"] = {"Chá", "", nil, 0.5},
	["suco"] = {"Suco de Laranja", "", nil, 0.5},
	["cerveja"] = {"Cerveja", "", nil, 0.5},
	["cocacola"] = {"Coca-Cola", "", nil, 0.5},
	["vinho"] = {"Vinho", "", nil, 0.5},
	["vodka"] = {"Vodka", "", nil, 0.5},
	["energy"] = {"Energy", "", nil, 0.5},
	["caldo"] = {"Caldo", "", nil, 0.5},
	["leite"] = {"Leite", "", nil, 0.5},
	
	["hambuguer"] = { "Hambuguer", "", nil, 0.5 },
	["tortademaca"] = { "Torta de maca", "", nil, 0.5 },
	["tortadenozes"] = {"Torta de nozes", "", nil, 0.5},
	["bolodecenoura"] = {"Bolo de cenoura", "", nil, 0.5},
	["bolodequeijo"] = {"Bolo de queijo", "", nil, 0.5},
	["biscoito"] = {"Biscoito", "", nil, 0.5},
	["brigadeiro"] = {"Brigadeiro", "", nil, 0.5},
	["tortadelimão"] = {"Torta de limão", "", nil, 0.5},
	["sorvete"] = {"Sorvete", "", nil, 0.5},
	["brownie"] = {"Brownie", "", nil, 0.5},

}

-- load more items function
local function load_item_pack(name)
  local items = module("cfg/item/"..name)
  if items then
    for k,v in pairs(items) do
      cfg.items[k] = v
    end
  else
    print("[vRP] item pack ["..name.."] not found")
  end
end

-- PACKS
load_item_pack("armamentos")

return cfg

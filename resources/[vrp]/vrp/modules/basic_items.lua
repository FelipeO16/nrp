-- load config items
local cfg = module("cfg/item/items")

for k,v in pairs(cfg.items) do
  vRP.defInventoryItem(k,v[1],v[2],v[3],v[4])
end
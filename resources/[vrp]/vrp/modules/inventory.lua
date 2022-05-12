local lang = vRP.lang
local cfg = module("cfg/inventory")

-- this module define the player inventory (lost after respawn, as wallet)

vRP.items = {}

-- define an inventory item (call this at server start) (parametric or plain text data)
-- idname: unique item name
-- name: display name or genfunction
-- description: item description (html) or genfunction
-- choices: menudata choices (see gui api) only as genfunction or nil
-- weight: weight or genfunction
--
-- genfunction are functions returning a correct value as: function(args) return value end
-- where args is a list of {base_idname,arg,arg,arg,...}
function vRP.defInventoryItem(idname,name,description,weight)
  if weight == nil then
    weight = 0
  end

  local item = {name=name,description=description,weight=weight}
  vRP.items[idname] = item
end

function vRP.parseItem(idname)
  return splitString(idname,"|")
end

-- return name, description, weight
function vRP.getItemDefinition(idname)
  local args = vRP.parseItem(idname)
  local item = vRP.items[idname]
  if item then
    return item.name, item.description, item.weight
  end

  return nil,nil,nil
end

function vRP.getItemName(idname)
  local item = vRP.items[idname]
  if item then return item.name end
  return ""
end

function vRP.getItemDescription(idname)
  local item = vRP.items[idname]
  if item then return item.description end
  return ""
end

function vRP.getItemWeight(idname)
  local args = vRP.parseItem(idname)
  local item = vRP.items[idname]
  if item then return item.weight end
  return 0
end

-- compute weight of a list of items (in inventory/chest format)
function vRP.computeItemsWeight(items)
  local weight = 0

  for k,v in pairs(items) do
    local iweight = vRP.getItemWeight(k)
    weight = weight+iweight*v.amount
  end

  return weight
end

-- add item to a connected user inventory
function vRP.giveInventoryItem(user_id,idname,amount,notify)
  if notify == nil then notify = true end -- notify by default

  local data = vRP.getUserDataTable(user_id)
  if data and amount > 0 then
    local entry = data.inventory[idname]
    if entry then -- add to entry
      entry.amount = entry.amount+amount
    else -- new entry
      data.inventory[idname] = {amount=amount}
    end

    -- notify
    if notify then
      local player = vRP.getUserSource(user_id)
      if player then
        vRPclient._notify(player,lang.inventory.give.received({vRP.getItemName(idname),amount}))
      end
    end
  end
end

-- try to get item from a connected user inventory
function vRP.tryGetInventoryItem(user_id,idname,amount,notify)
  if notify == nil then notify = true end -- notify by default

  local data = vRP.getUserDataTable(user_id)
  if data and amount > 0 then
    local entry = data.inventory[idname]
    if entry and entry.amount >= amount then -- add to entry
      entry.amount = entry.amount-amount

      -- remove entry if <= 0
      if entry.amount <= 0 then
        data.inventory[idname] = nil 
      end

      -- notify
      if notify then
        local player = vRP.getUserSource(user_id)
        if player then
          vRPclient._notify(player,lang.inventory.give.given({vRP.getItemName(idname),amount}))
        end
      end
      return true
    else
      -- notify
      if notify then
        local player = vRP.getUserSource(user_id)
        if player then
          local entry_amount = 0
          if entry then entry_amount = entry.amount end
          vRPclient._notify(player,lang.inventory.missing({vRP.getItemName(idname),amount-entry_amount}))
        end
      end
    end
  end

  return false
end

-- get item amount from a connected user inventory
function vRP.getInventoryItemAmount(user_id,idname)
  local data = vRP.getUserDataTable(user_id)
  if data and data.inventory then
    local entry = data.inventory[idname]
    if entry then
      return entry.amount
    end
  end

  return 0
end

-- get connected user inventory
-- return map of full idname => amount or nil 
function vRP.getInventory(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data then
    return data.inventory
  end
end

-- return user inventory total weight
function vRP.getInventoryWeight(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data and data.inventory then
    return vRP.computeItemsWeight(data.inventory)
  end

  return 0
end

function verifyInventory(user_id)
  local level = math.floor(vRP.expToLevel(vRP.getExp(user_id, "exp", "level")))
  if level == 1 then
    return cfg.inventario_peso_padrao
  elseif level > 1 then
    return cfg.inventario_peso_padrao + math.floor(vRP.expToLevel(vRP.getExp(user_id, "exp", "level")))*cfg.inventario_peso_por_level
  end
end

-- return maximum weight of the user inventory
function vRP.getInventoryMaxWeight(user_id)
  return verifyInventory(user_id)
end

-- clear connected user inventory
function vRP.clearInventory(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.inventory = {}
  end
end

-- init inventory
AddEventHandler("vRP:playerJoin", function(user_id,source,name,last_login)
  local data = vRP.getUserDataTable(user_id)
  if not data.inventory then
    data.inventory = {}
  end
end)

-- CHEST SYSTEM

local chests = {}

-- build a menu from a list of items and bind a callback(idname)
local function build_itemlist_menu(name, items, cb)
  local menu = {name=name, css={top="75px",header_color="rgba(0,255,125,0.75)"}}

  local kitems = {}

  -- choice callback
  local choose = function(player,choice)
    local idname = kitems[choice]
    if idname then
      cb(idname)
    end
  end

  -- add each item to the menu
  for k,v in pairs(items) do 
    local name,description,weight = vRP.getItemDefinition(k)
    if name then
      kitems[name] = k -- reference item by display name
      menu[name] = {choose,lang.inventory.iteminfo({v.amount,description,string.format("%.2f", weight)})}
    end
  end

  return menu
end

-- open a chest by name
-- cb_close(): called when the chest is closed (optional)
-- cb_in(idname, amount): called when an item is added (optional)
-- cb_out(idname, amount): called when an item is taken (optional)
function vRP.openChest(source, name, max_weight, cb_close, cb_in, cb_out)
  local user_id = vRP.getUserId(source)
  if user_id then
    local data = vRP.getUserDataTable(user_id)
    if data.inventory then
      if not chests[name] then
        local close_count = 0 -- used to know when the chest is closed (unlocked)

        -- load chest
        local chest = {max_weight = max_weight}
        chests[name] = chest 
        local cdata = vRP.getSData("chest:"..name)
        chest.items = json.decode(cdata) or {} -- load items

        -- open menu
        local menu = {name=lang.inventory.chest.title(), css={top="75px",header_color="rgba(0,255,125,0.75)"}}
        -- take
        local cb_take = function(idname)
          local citem = chest.items[idname]
          local amount = vRP.prompt(source, lang.inventory.chest.take.prompt({citem.amount}), "")
          amount = parseInt(amount)
          if amount >= 0 and amount <= citem.amount then
            -- take item

            -- weight check
            local new_weight = vRP.getInventoryWeight(user_id)+vRP.getItemWeight(idname)*amount
            if new_weight <= vRP.getInventoryMaxWeight(user_id) then
              vRP.giveInventoryItem(user_id, idname, amount, true)
              citem.amount = citem.amount-amount

              if citem.amount <= 0 then
                chest.items[idname] = nil -- remove item entry
              end

              if cb_out then cb_out(idname,amount) end

              -- actualize by closing
              vRP.closeMenu(source)
            else
              vRPclient._notify(source,lang.inventory.full())
            end
          else
            vRPclient._notify(source,lang.common.invalid_value())
          end
        end

        local ch_take = function(player, choice)
          local submenu = build_itemlist_menu(lang.inventory.chest.take.title(), chest.items, cb_take)
          -- add weight info
          local weight = vRP.computeItemsWeight(chest.items)
          local hue = math.floor(math.max(125*(1-weight/max_weight), 0))
          submenu["<div class=\"dprogressbar\" data-value=\""..string.format("%.2f",weight/max_weight).."\" data-color=\"hsl("..hue..",100%,50%)\" data-bgcolor=\"hsl("..hue..",100%,25%)\" style=\"height: 12px; border: 3px solid black;\"></div>"] = {function()end, lang.inventory.info_weight({string.format("%.2f",weight),max_weight})}


          submenu.onclose = function()
            close_count = close_count-1
            vRP.openMenu(player, menu)
          end
          close_count = close_count+1
          vRP.openMenu(player, submenu)
        end


        -- put
        local cb_put = function(idname)
          local amount = vRP.prompt(source, lang.inventory.chest.put.prompt({vRP.getInventoryItemAmount(user_id, idname)}), "")
          amount = parseInt(amount)

          -- weight check
          local new_weight = vRP.computeItemsWeight(chest.items)+vRP.getItemWeight(idname)*amount
          if new_weight <= max_weight then
            if amount >= 0 and vRP.tryGetInventoryItem(user_id, idname, amount, true) then
              local citem = chest.items[idname]

              if citem ~= nil then
                citem.amount = citem.amount+amount
              else -- create item entry
                chest.items[idname] = {amount=amount}
              end

              -- callback
              if cb_in then cb_in(idname,amount) end

              -- actualize by closing
              vRP.closeMenu(source)
            end
          else
            vRPclient._notify(source,lang.inventory.chest.full())
          end
        end

        local ch_put = function(player, choice)
          local submenu = build_itemlist_menu(lang.inventory.chest.put.title(), data.inventory, cb_put)
          -- add weight info
          local weight = vRP.computeItemsWeight(data.inventory)
          local max_weight = vRP.getInventoryMaxWeight(user_id)
          local hue = math.floor(math.max(125*(1-weight/max_weight), 0))
          submenu["<div class=\"dprogressbar\" data-value=\""..string.format("%.2f",weight/max_weight).."\" data-color=\"hsl("..hue..",100%,50%)\" data-bgcolor=\"hsl("..hue..",100%,25%)\" style=\"height: 12px; border: 3px solid black;\"></div>"] = {function()end, lang.inventory.info_weight({string.format("%.2f",weight),max_weight})}

          submenu.onclose = function() 
            close_count = close_count-1
            vRP.openMenu(player, menu) 
          end
          close_count = close_count+1
          vRP.openMenu(player, submenu)
        end


        -- choices
        menu[lang.inventory.chest.take.title()] = {ch_take}
        menu[lang.inventory.chest.put.title()] = {ch_put}

        menu.onclose = function()
          if close_count == 0 then -- close chest
            -- save chest items
            vRP.setSData("chest:"..name, json.encode(chest.items))
            chests[name] = nil
            if cb_close then cb_close() end -- close callback
          end
        end

        -- open menu
        vRP.openMenu(source, menu)
      else
        vRPclient._notify(source,lang.inventory.chest.already_opened())
      end
    end
  end
end

-- STATIC CHESTS

local function build_client_static_chests(source)
  local user_id = vRP.getUserId(source)
  if user_id then
    for k,v in pairs(cfg.static_chests) do
      local mtype,x,y,z = table.unpack(v)
      local schest = cfg.static_chest_types[mtype]

      if schest then
        local function schest_enter(source)
          local user_id = vRP.getUserId(source)
          if user_id ~= nil and vRP.hasPermissions(user_id,schest.permissions or {}) then
            -- open chest
            vRP.openChest(source, "static:"..k, schest.weight or 0)
          end
        end

        local function schest_leave(source)
          vRP.closeMenu(source)
        end

        vRPclient._addBlip(source,x,y,z,schest.blipid,schest.blipcolor,schest.title)
        vRPclient._addMarker(source,x,y,z-1,0.7,0.7,0.5,255,226,0,125,150)

        vRP.setArea(source,"vRP:static_chest:"..k,x,y,z,1,1.5,schest_enter,schest_leave)
      end
    end
  end
end

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    -- load static chests
    build_client_static_chests(source)
  end
end)



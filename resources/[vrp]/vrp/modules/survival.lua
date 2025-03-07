local Tunnel = module("vrp", "lib/Tunnel")
local cfg = module("cfg/survival")
local cfgps = module("cfg/player_state")
local lang = vRP.lang
HUDclient = Tunnel.getInterface("vrp_hud")
-- api
function vRP.getHunger(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data then
    return data.hunger
  end

  return 0
end

function vRP.getThirst(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data then
    return data.thirst
  end

  return 0
end

function vRP.setHunger(user_id,value)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.hunger = value
    if data.hunger < 0 then data.hunger = 0
    elseif data.hunger > 100 then data.hunger = 100 
    end

    -- update bar
    local source = vRP.getUserSource(user_id)
    HUDclient.setHunger(source,data.hunger)
    if data.hunger >= 100 then
      --vRPclient._setProgressBarText(source,"vRP:hunger",lang.survival.starving())
    else
      --vRPclient._setProgressBarText(source,"vRP:hunger","")
    end
  end
end

function vRP.setThirst(user_id,value)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.thirst = value
    if data.thirst < 0 then data.thirst = 0
    elseif data.thirst > 100 then data.thirst = 100 
    end

    -- update bar
    local source = vRP.getUserSource(user_id)
    HUDclient.setThirst(source,data.thirst)
    if data.thirst >= 100 then
      --vRPclient._setProgressBarText(source,"vRP:thirst",lang.survival.thirsty())
    else
      --vRPclient._setProgressBarText(source,"vRP:thirst","")
    end
  end
end

function vRP.varyHunger(user_id, variation)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.hunger = data.hunger + variation
    -- apply overflow as damage
	if data.hunger <= 10 then
		local overflow = data.hunger-100
		if overflow > 0 then
		  vRPclient._varyHealth(vRP.getUserSource(user_id),-overflow*cfg.overflow_damage_factor)
		end
	end

    if data.hunger < 0 then data.hunger = 0
    elseif data.hunger > 100 then data.hunger = 100
    end

    -- set progress bar data
    local source = vRP.getUserSource(user_id)
    HUDclient.setHunger(source,data.hunger)
  end
end

function vRP.varyThirst(user_id, variation)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.thirst = data.thirst + variation

    -- apply overflow as damage
	if data.thirst <= 10 then
		local overflow = data.thirst-100
		if overflow > 0 then
		  vRPclient._varyHealth(vRP.getUserSource(user_id),-overflow*cfg.overflow_damage_factor)
		end
	end

    if data.thirst < 0 then data.thirst = 0
    elseif data.thirst > 100 then data.thirst = 100 
    end

    -- set progress bar data
    local source = vRP.getUserSource(user_id)
    HUDclient.setThirst(source,data.thirst)
    if was_thirsty and not is_thirsty then
     -- vRPclient._setProgressBarText(source,"vRP:thirst","")
    elseif not was_thirsty and is_thirsty then
     -- vRPclient._setProgressBarText(source,"vRP:thirst",lang.survival.thirsty())
    end
  end
end

-- tunnel api (expose some functions to clients)

function tvRP.varyHunger(variation)
  local user_id = vRP.getUserId(source)
  if user_id then
    vRP.varyHunger(user_id,variation)
  end
end

function tvRP.varyThirst(variation)
  local user_id = vRP.getUserId(source)
  if user_id then
    vRP.varyThirst(user_id,variation)
  end
end

function tvRP.finishComa(finishme)
	local user_id = vRP.getUserId(source)
	local data = vRP.getUserDataTable(user_id)
	if finishme then
		vRP.clearInventory(user_id)
		if cfgps.lose_aptitudes_on_death then
			data.gaptitudes = {}
		end
		vRP.setMoney(user_id,0)
		vRPclient.setHandcuffed(source, false)
		if cfgps.spawn_enabled then
			local x = cfgps.respawn_position[1]
			local y = cfgps.respawn_position[2]
			local z = cfgps.respawn_position[3]
			vRPclient.teleport(source,x,y,z)
		end
		if data.customization then
			-- Seta customização
			vRPclient._setCustomization(source,data.customization)
		end
	end
	return true
end

-- tasks

-- hunger/thirst increase
function task_update()
  for k,v in pairs(vRP.users) do
    vRP.varyHunger(v,-cfg.hunger_per_minute)
    vRP.varyThirst(v,-cfg.thirst_per_minute)
  end

  SetTimeout(60000,task_update)
end

async(function()
  task_update()
end)

-- handlers

-- init values
AddEventHandler("vRP:playerJoin",function(user_id,source,name,last_login)
  local data = vRP.getUserDataTable(user_id)
  if data.hunger == nil then
    data.hunger = 0
    data.thirst = 0
  end
end)

-- add survival progress bars on spawn
AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  local data = vRP.getUserDataTable(user_id)

  -- disable police
  vRPclient._setPolice(source,cfg.police)
  -- set friendly fire
  vRPclient._setFriendlyFire(source,cfg.pvp)

  --vRPclient._setProgressBar(source,"vRP:hunger","minimap",htxt,255,153,0,0)
  --vRPclient._setProgressBar(source,"vRP:thirst","minimap",ttxt,0,125,255,0)
  vRP.setHunger(user_id, data.hunger)
  vRP.setThirst(user_id, data.thirst)
end)

-- EMERGENCY

---- revive
local revive_seq = {
  {"amb@medic@standing@kneel@enter","enter",1},
  {"amb@medic@standing@kneel@idle_a","idle_a",1},
  {"amb@medic@standing@kneel@exit","exit",1}
}

local choice_revive = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id then
    local nplayer = vRPclient.getNearestPlayer(player,10)
      local nuser_id = vRP.getUserId(nplayer)
      if nuser_id then
        if vRPclient.isInComa(nplayer) then
            if vRP.tryGetInventoryItem(user_id,"medkit",1,true) then
              vRPclient._playAnim(player,false,revive_seq,false) -- anim
              SetTimeout(15000, function()
                vRPclient._varyHealth(nplayer,50) -- heal 50
              end)
            end
          else
            vRPclient._notify(player,lang.emergency.menu.revive.not_in_coma())
          end
      else
        vRPclient._notify(player,lang.common.no_player_near())
      end
  end
end,lang.emergency.menu.revive.description()}
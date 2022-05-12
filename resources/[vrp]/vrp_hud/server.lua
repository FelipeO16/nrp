-- DEFAULT --
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
vRPhud = {}
Tunnel.bindInterface("vrp_hud",vRPhud)

function vRPhud.checkHunger()
  local user_id = vRP.getUserId(source)
  return vRP.getHunger(user_id)
end

function vRPhud.checkThirst()
  local user_id = vRP.getUserId(source)
  return vRP.getThirst(user_id)
end

RegisterServerEvent('Hud:sendLevel')
AddEventHandler('Hud:sendLevel',function()
  local source = source
  local user_id = vRP.getUserId(source)
  local level = math.floor(vRP.expToLevel(vRP.getExp(user_id, "exp", "level")))
  
  TriggerClientEvent('Hud:getLevel', source, level) 
end)

function addComma(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

RegisterCommand('group',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"adm.perm") then
		if args[1] and args[2] then
			vRP.addUserGroup(parseInt(args[1]),args[2])
		end
	end
end)

RegisterServerEvent("notifySuccess:Server")
AddEventHandler("notifySuccess:Server", function(message)
  TriggerClientEvent("notifySuccess:Client", source, message)
end)

RegisterServerEvent("notifyError:Server")
AddEventHandler("notifyError:Server", function(message)
  TriggerClientEvent("notifyError:Client", source, message)
end)

RegisterServerEvent("notifyWarning:Server")
AddEventHandler("notifyWarning:Server", function(message)
  TriggerClientEvent("notifyWarning:Client", source, message)
end)

AddEventHandler('vRP:playerSpawn', function(user_id, source, first_spawn) 
  if user_id then
    TriggerEvent('Hud:sendLevel')
  end
end)
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
vRPtr = {}
TRclient = Tunnel.getInterface("vrp_trancar","vrp_trancar")
Tunnel.bindInterface("vrp_trancar",vRPtr)
Proxy.addInterface("vrp_trancar",vRPtr)

vGRGS = Proxy.getInterface("vrp_garagem","vrp_trancar")

-----------------------------------------------------------------------------------------------------------------------------------------
-- BOTÃO L PARA TRANCAR
-----------------------------------------------------------------------------------------------------------------------------------------
local lveh = {}
RegisterServerEvent("registerLock")
AddEventHandler("registerLock",function(veh)
	local source = source
	local user_id = vRP.getUserId(source)
	lveh[tonumber(veh)] = user_id
end)

RegisterServerEvent("unRegisterLock")
AddEventHandler("unRegisterLock",function(veh)
	if lveh[tonumber(veh)] then
		lveh[tonumber(veh)] = true
	end
end)

RegisterServerEvent("buttonLock")
AddEventHandler("buttonLock",function()
	local source = source
	local user_id = vRP.getUserId(source)
	local mPlaca, mName, mNet, mLock, mStreet, mVeh, mModel = vRPclient.ModelName(source,7)
	local veh = vGRGS.checkVehicle(user_id, mModel)
	if veh then
		if user_id == veh[3] and mNet == veh[4] then
			TRclient.toggleLock(source)
			TriggerClientEvent("vrp_sound:source",source,'lock',0.1)
		else
			TriggerClientEvent("Notify",source,"negado","Este veículo não é de sua propriedade")
		end
	else
		if lveh[tonumber(mVeh)] == user_id then
			TRclient.toggleLock(source)
		else
			TriggerClientEvent("Notify",source,"negado","Este veículo não é de sua propriedade")
		end
	end
end)

RegisterServerEvent("tryLock")
AddEventHandler("tryLock",function(nveh)
	TriggerClientEvent("syncLock",-1,nveh)
end)
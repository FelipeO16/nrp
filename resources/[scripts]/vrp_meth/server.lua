local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPmt = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_meth",vRPmt)
Proxy.addInterface("vrp_meth",vRPmt)

RegisterServerEvent('vrp_methcar:start')
AddEventHandler('vrp_methcar:start', function()
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.getInventoryItemAmount(user_id, "water") >= 5 and vRP.getInventoryItemAmount(user_id, "tacos") >= 2 and vRP.getInventoryItemAmount(user_id, "tacos") >= 1 then
		if vRP.getInventoryItemAmount(user_id, "tacos") >= 30 then
			TriggerClientEvent('vrp_methcar:notify', source, "~r~~h~Você não pode segurar mais metanfetamina")
		else
			TriggerClientEvent('vrp_methcar:startprod', source)
			vRP.tryGetInventoryItem(user_id, "water", 5, true)
			vRP.tryGetInventoryItem(user_id, "tacos", 2, true)
		end
	else
		TriggerClientEvent('vrp_methcar:notify', source, "~r~~h~Suprimentos insuficientes para começar a produzir metanfetamina")
	end
end)

RegisterServerEvent('vrp_methcar:make')
AddEventHandler('vrp_methcar:make', function(posx,posy,posz)
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.getInventoryItemAmount(user_id, "water") >= 1 then
		for uid,src in pairs(vRP.getUsers()) do
			TriggerClientEvent('vrp_methcar:smoke', src, posx, posy, posz, 'a') 
		end
	else
		TriggerClientEvent('vrp_methcar:stop', source)
	end
end)

RegisterServerEvent('vrp_methcar:finish')
AddEventHandler('vrp_methcar:finish', function(qualtiy)
	local source = source
	local user_id = vRP.getUserId(source)
	local rnd = math.random(-5, 5)
	vRP.giveInventoryItem(user_id, "meth", math.floor(qualtiy / 2) + rnd, true)
end)

RegisterServerEvent('vrp_methcar:blow')
AddEventHandler('vrp_methcar:blow', function(posx, posy, posz)
	local source = source
	local user_id = vRP.getUserId(source)
	for uid,src in pairs(vRP.getUsers()) do
		TriggerClientEvent('vrp_methcar:blowup', src, posx, posy, posz)
	end
	vRP.tryGetInventoryItem(user_id, "methlab", 1, true)
end)


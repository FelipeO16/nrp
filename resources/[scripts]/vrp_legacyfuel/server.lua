local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

RegisterServerEvent("vrp_legacyfuel:pagamento")
AddEventHandler("vrp_legacyfuel:pagamento",function(price,galao)
	local user_id = vRP.getUserId(source)
	if user_id and price > 0 then
		if vRP.tryPayment(user_id,price) then
			if galao then
				TriggerClientEvent('vrp_legacyfuel:galao',source)
				vRPclient._notify("sucesso","Pagou <b>$".. price .." dólares</b> pelo <b>Galão</b>.")
			else
				vRPclient._notify("sucesso","Pagou <b>$".. price .." dólares</b> em combustível.")
			end
		else
			TriggerClientEvent('vrp_legacyfuel:insuficiente',source)
			vRPclient._notify("negado","Dinheiro insuficiente.")
		end
	end
end)
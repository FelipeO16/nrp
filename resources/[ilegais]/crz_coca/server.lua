--Settings--
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local group = ""

RegisterServerEvent('crz_cocaina:receberItem')
AddEventHandler('crz_cocaina:receberItem', function()
	local src = source
	local user_id = vRP.getUserId(source)
	local player = vRP.getUserSource(user_id)
	if vRP.getInventoryWeight(user_id)+vRP.getItemWeight("folhacoca")*6 <= vRP.getInventoryMaxWeight(user_id) then
		if vRP.hasGroup(user_id,group) then -- GRUPO PARA FARMAR
			vRP.giveInventoryItem(user_id, "folhacoca", 6,true)
		end
	else
		local typemessage = "error"
		local mensagem = "Espaço insuficiente no seu inventário"
		vRPclient.setDiv(src, "Alerta","body {font-family: 'Source Sans Pro', 'Helvetica Neue', Arial, sans-serif;color: #34495e;-webkit-font-smoothing: antialiased;line-height: 1.6em;}p {margin: 0;}.notice {margin: 1em;background: #F9F9F9;padding: 1em 1em 1em 2em;border-left: 4px solid #DDD;box-shadow: 0 1px 1px rgba(0, 0, 0, 0.125);bottom: 20%;right: 1%;line-height: 22px;position: absolute;max-width: 500px;-webkit-border-radius: 5px; -webkit-animation: fadein 2s; -moz-animation: fadein 2s; -ms-animation: fadein 2s; -o-animation: fadein 2s; animation: fadein 2s;}.notice:before {position: absolute;top: 50%;margin-top: -17px;left: -17px;background-color: #DDD;color: #FFF;width: 30px;height: 30px;text-align: center;line-height: 30px;font-weight: bold;font-family: Georgia;text-shadow: 1px 1px rgba(0, 0, 0, 0.5);}.info {border-color: #0074D9;}.info:before {content: \"i\";background-color: #0074D9;}.sucesso {border-color: #2ECC40;}.sucesso:before {content: \"√\";background-color: #2ECC40;}.aviso {border-color: #FFDC00;}.aviso:before {content: \"!\";background-color: #FFDC00;}.error {border-color: #FF4136;}.error:before {content: \"X\";background-color: #FF4136;}@keyframes fadein {from { opacity: 0; }to   { opacity: 1; }}@-moz-keyframes fadein {from { opacity: 0; }to   { opacity: 1; }}@-webkit-keyframes fadein {from { opacity: 0; }to   { opacity: 1; }}@-ms-keyframes fadein {from { opacity: 0; }to   { opacity: 1; }}@-o-keyframes fadein {from { opacity: 0; }to   { opacity: 1; }}","<div class=\"notice "..typemessage.."\"><p>"..mensagem..".</p></div>")
		SetTimeout(5000,function()
			vRPclient.removeDiv(src, "Alerta")
		end)
	end
end)

----------------------------------------
-------------- PERMISSÕES -----------------
----------------------------------------
RegisterServerEvent('crz_cocaina:permissao')
AddEventHandler('crz_cocaina:permissao', function()
	local source = source
	local user_id = vRP.getUserId(source)
	local player = vRP.getUserSource(user_id)
	if vRP.hasGroup(user_id,group) then
		TriggerClientEvent('crz_cocaina:permissao', player)
	end
end)
RegisterServerEvent('crz_cocaina:entrada')
AddEventHandler('crz_cocaina:entrada', function()
	local source = source
	local user_id = vRP.getUserId(source)
	local player = vRP.getUserSource(user_id)
	if vRP.hasGroup(user_id,group) then
	  TriggerClientEvent('crz_cocaina:entrada', player)
	end
end)


RegisterServerEvent('crz_cocaina:quantasfolhas')
AddEventHandler('crz_cocaina:quantasfolhas', function()
	local src = source
	local user_id = vRP.getUserId(src)
	local player = vRP.getUserSource(user_id)
	local perguntar = vRP.prompt(player,"Quantas folhas colocar?", "10")
	if vRP.hasGroup(user_id,group) then
		if tonumber(perguntar) > 10 then
			TriggerClientEvent('chatMessage',player, "COCAINA",{255,70,50},"Tanque cheio, você pode produzir até 10 pasta de coca.")
		else
			if vRP.tryGetInventoryItem(user_id,"folhacoca",tonumber(perguntar),true) then
				TriggerClientEvent('crz_cocaina:prodstep2', player, tonumber(perguntar))
			else
				TriggerClientEvent('chatMessage',player, "COCAINA",{255,70,50},"Você não possui folha de cocaina.")
			end
		end
	end
end)


RegisterServerEvent('crz_cocaina:prodCocaSj')
AddEventHandler('crz_cocaina:prodCocaSj', function()
	local src = source
	local user_id = vRP.getUserId(src)
	local player = vRP.getUserSource(user_id)
	if vRP.hasGroup(user_id,group) then
		TriggerClientEvent('crz_cocaina:prodStep4', player)
	end
end)

RegisterServerEvent('crz_cocaina:enviarItem')
AddEventHandler('crz_cocaina:enviarItem',function(quantidade)
	local src = source
	local user_id = vRP.getUserId(src)
	local player = vRP.getUserSource(user_id)
	if vRP.giveInventoryItem(user_id, "podecocaina", tonumber(quantidade),true) then
		local typemessage = "sucesso"
		local mensagem = "Você produziu <font color=\"green\">"..tonumber(quantidade).."</font>x"
		vRPclient.setDiv(player, "Alerta","body {font-family: 'Source Sans Pro', 'Helvetica Neue', Arial, sans-serif;color: #34495e;-webkit-font-smoothing: antialiased;line-height: 1.6em;}p {margin: 0;}.notice {margin: 1em;background: #F9F9F9;padding: 1em 1em 1em 2em;border-left: 4px solid #DDD;box-shadow: 0 1px 1px rgba(0, 0, 0, 0.125);bottom: 20%;right: 1%;line-height: 22px;position: absolute;max-width: 500px;-webkit-border-radius: 5px; -webkit-animation: fadein 2s; -moz-animation: fadein 2s; -ms-animation: fadein 2s; -o-animation: fadein 2s; animation: fadein 2s;}.notice:before {position: absolute;top: 50%;margin-top: -17px;left: -17px;background-color: #DDD;color: #FFF;width: 30px;height: 30px;text-align: center;line-height: 30px;font-weight: bold;font-family: Georgia;text-shadow: 1px 1px rgba(0, 0, 0, 0.5);}.info {border-color: #0074D9;}.info:before {content: \"i\";background-color: #0074D9;}.sucesso {border-color: #2ECC40;}.sucesso:before {content: \"√\";background-color: #2ECC40;}.aviso {border-color: #FFDC00;}.aviso:before {content: \"!\";background-color: #FFDC00;}.error {border-color: #FF4136;}.error:before {content: \"X\";background-color: #FF4136;}@keyframes fadein {from { opacity: 0; }to   { opacity: 1; }}@-moz-keyframes fadein {from { opacity: 0; }to   { opacity: 1; }}@-webkit-keyframes fadein {from { opacity: 0; }to   { opacity: 1; }}@-ms-keyframes fadein {from { opacity: 0; }to   { opacity: 1; }}@-o-keyframes fadein {from { opacity: 0; }to   { opacity: 1; }}","<div class=\"notice "..typemessage.."\"><p>"..mensagem..".</p></div>")
		SetTimeout(5000,function()
			vRPclient.removeDiv(player, "Alerta")
		end)
	end
end)

RegisterServerEvent('crz_cocaina:limparCoca')
AddEventHandler('crz_cocaina:limparCoca',function(quantidade)
	local src = source
	local user_id = vRP.getUserId(src)
	local player = vRP.getUserSource(user_id)
	if vRP.tryGetInventoryItem(user_id,"podecocaina",5,true) then
		vRP.giveInventoryItem(user_id, "cocaina", 3,true)
	end
end)



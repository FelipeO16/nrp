--Settings--
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local group = ""

----------------------------------------
-------------- PERMISSÕES -----------------
----------------------------------------
RegisterServerEvent('crz_heroina:entrada')
AddEventHandler('crz_heroina:entrada', function()
	local source = source
	local user_id = vRP.getUserId(source)
	local player = vRP.getUserSource(user_id)
	if vRP.hasGroup(user_id,group) then -- GRUPO PARA FARMAR
	    TriggerClientEvent('crz_heroina:entrada', player)
	end
end)

RegisterServerEvent('crz_heroina:enviarItem')
AddEventHandler('crz_heroina:enviarItem', function()
	local src =  source
    local user_id = vRP.getUserId(source)
	local player = vRP.getUserSource(user_id)
	if vRP.getInventoryWeight(user_id)+vRP.getItemWeight("heroina")*5 <= vRP.getInventoryMaxWeight(user_id) then
		if vRP.hasGroup(user_id,group) then
			vRP.giveInventoryItem(user_id, "heroina", 5,true)
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
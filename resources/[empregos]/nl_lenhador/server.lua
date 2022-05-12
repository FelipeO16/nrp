local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
emP = {}
Tunnel.bindInterface("lenhador_coletar",emP)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------
local valorMadeira = 15
local blipID = {}
local refinamento = {}
local quantidade = {}

local blips = {
	{nome = "~y~Lenhador | ~w~Coletar", id = 285, cor = 21, x = -471.108, y = 5304.714, z = 84.980},
	{nome = "~y~Lenhador | ~w~Vender", id = 285, cor = 21, x = 1167.661, y = -1347.221, z = 33.915},
}

function emP.Quantidade()
	local source = source
	if quantidade[source] == nil then
		quantidade[source] = math.random(3)
	end
end

function emP.checkPayment()
	emP.Quantidade()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		TriggerClientEvent("DropSystem:drop", source, "tronco", quantidade[source])
		quantidade[source] = nil
		return true
	end
end

function emP.enviarItem()
	local source = source
	local coords = {x = -550.28637695313, y = 5331.7602539063, z = 74.870613098145}
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		refinamento["processo"] = nil
		vRPclient._notify(source, "[Refinamento] Concluido!")
		TriggerClientEvent("DropSystem:dropCoords", source, "madeira_refinada", math.random(5, 10), coords)
		return true
	end
end

function emP.verificarItem()
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.tryGetInventoryItem(user_id,"tronco",1,true) then
		return true
	end
end

function emP.verificarRefinamento()
	local source = source
	local user_id = vRP.getUserId(source)
	if refinamento["processo"] == nil then
		if emP.verificarItem() then
			refinamento["processo"] = true
			return true
		end
	else
		vRPclient._notify(source, "Já tem um refinamento em andamento")
	end
end

RegisterServerEvent('Lenhador:iniciarRefinamento')
AddEventHandler('Lenhador:iniciarRefinamento', function(prop)
	local source = source
	local user_id = vRP.getUserId(source)
	TriggerClientEvent('Lenhador:atualizarRefinamento', -1, prop)
end)

RegisterServerEvent('Lenhador:venderMadeiras')
AddEventHandler('Lenhador:venderMadeiras', function()
	local source = source
	local user_id = vRP.getUserId(source)
	local madeirasAmount = vRP.getInventoryItemAmount(user_id, "madeira_refinada")
	if madeirasAmount > 0 then
		local amount = madeirasAmount * valorMadeira
        vRP.giveMoney(user_id, amount)
        vRP.tryGetInventoryItem(user_id, "madeira_refinada", madeirasAmount, false)
        vRPclient._notify(source, "Você vendeu suas Madeiras Refinadas por $"..amount.." !")
	end
end)


-- Criar Blip quando o player Entrar no grupo de "Lenhador"
AddEventHandler("vRP:playerJoinGroup", function(user_id, group, gtype)
	if user_id then
		local player = vRP.getUserSource(user_id)
		if gtype == "job" and group == "Lenhador" then
			for k,v in pairs(blips) do
				local criarBlip = vRPclient.addBlip(player, v.x, v.y, v.z, v.id, v.cor, v.nome, 0.8)
				blipID[user_id..'-'..player] = {
					["id"] = criarBlip
				}
			end
		end
	end
end)
  
AddEventHandler("vRP:playerLeaveGroup", function(user_id, group, gtype)
	if user_id then
		local player = vRP.getUserSource(user_id)
		if gtype == "job" and group == "Lenhador" then
			local blip = blipID[user_id..'-'..player]
			if blip then
				vRPclient.removeBlip(player, blip.id)
				blipID = {}
			end
		end
	end
end)

AddEventHandler('vRP:playerSpawn', function(user_id, source, first_spawn) 
    if user_id then
		local emprego = vRP.hasGroup(user_id, "Lenhador")
		if emprego then
			for k,v in pairs(blips) do
				local criarBlip = vRPclient.addBlip(source, v.x, v.y, v.z, v.id, v.cor, v.nome, 0.8)
				table.insert(blipID, {
					["id"] = criarBlip
				})
			end
		end
    end
end)
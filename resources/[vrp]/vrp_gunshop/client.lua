local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local cfg = module("vrp_gunshop", "cfg/config")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
SVnui = Tunnel.getInterface("vrp_gunshop")

local armas = cfg.gunshop
local abrirLoja = false

local lojas = {}
local users = {}
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function criarBlip()
	for k, v in pairs(armas) do
		local item = armas[k].info
        item.blip = AddBlipForCoord(item.x, item.y, item.z)
        SetBlipSprite(item.blip, item.id)
        SetBlipColour(item.blip, item.cor)
        SetBlipScale(item.blip, 0.6)
        SetBlipAsShortRange(item.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(item.nome)
        EndTextCommandSetBlipName(item.blip)
    end
end

function acessarGunshop()
	for k,v in pairs(armas) do
		local item = armas[k].info
		if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), item.x, item.y, item.z, true ) <= 1 then
			if not abrirLoja then
				DrawText3D(item.x, item.y, item.z, "[~g~E~w~] Para acessar")
			end
			if (IsControlJustReleased(1, 51)) then
				TriggerServerEvent('Gunshop:EnviarArmas', k)
			end
		end
	end
end

function acessarCofre()
	for k,v in pairs(lojas) do
		local cofre = armas[k].cofre
		if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), cofre.posicao.x, cofre.posicao.y, cofre.posicao.z, true ) <= 1 and not lojas[k].a_venda then
			local dono = index_filter(users, function(o)
				return o.id == v.id_dono
			end)
			if dono then
				DrawText3Ds(cofre.posicao.x, cofre.posicao.y, cofre.posicao.z+0.2, "~w~[~g~E~w~] Para retirar o dinheiro do cofre\n ~g~$"..addCommam(lojas[k].cofre).."/"..addCommam(lojas[k].cofreLimite))
				if (IsControlJustReleased(1, 51)) then
					TriggerServerEvent('Gunshop:retirarDinheiro', k)
				end
			end
		end
	end
end

function index_filter(t, filter)
    local out = nil
    for k,v in pairs(t) do
        if filter(v,k,t) then 
          out = k
          break
        end
    end
    return out
end

function addCommam(amount)
	local formatted = amount
	while true do  
	  formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
	  if (k==0) then
		break
	  end
	end
	return formatted
end

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.28, 0.28)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.005+ factor, 0.03, 41, 11, 41, 68)
end

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.28, 0.28)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EVENTOS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('Gunshop:receberLojas')
AddEventHandler('Gunshop:receberLojas', function(loja)
    lojas = loja
end)

RegisterNetEvent('Gunshop:InserirUsers')
AddEventHandler('Gunshop:InserirUsers', function(user_id)
    users[user_id] = {id = user_id}
end)

RegisterNetEvent('Gunshop:RemoverUsers')
AddEventHandler('Gunshop:RemoverUsers', function(user_id)
    users[user_id] = nil
end)

RegisterNetEvent('Gunshop:ReceberArmas')
AddEventHandler('Gunshop:ReceberArmas', function(armas)
	TransitionToBlurred(1000)
	SetNuiFocus(true, true)
	SendNUIMessage({
        show = true,
		armas = armas
	})
end)

RegisterNUICallback('fechar', function()
	abrirLoja = false
	TransitionFromBlurred(1000)
    SetNuiFocus(false, false)
end)

RegisterNUICallback('comprar', function(data, cb)
	SetNuiFocus(false, false)
	local loja = data.loja
	local arma, quantidade = data.id, data.quantidade
    TriggerServerEvent('Gunshop:comprarArma', loja, arma, quantidade)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- THREAD
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		-- Acessar Gunshop e Cofre
		acessarCofre()
		acessarGunshop()
		-- Comprar loja se estiver a venda
		for k,v in pairs(lojas) do
			local comprar = armas[k].comprar
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), comprar.x, comprar.y, comprar.z, true ) <= 1 then
				if (lojas[k].a_venda) then
					DrawText3Ds(comprar.x, comprar.y, comprar.z+0.2, "~b~[À venda]\n~w~[~g~E~w~] Para comprar a Ammunation ("..k..") \nPreço: ~g~$"..armas[k].preco)
					if (IsControlJustReleased(1, 51)) then
						TriggerServerEvent('Gunshop:comprarLoja', k, armas[k].preco)
					end
				end
			end
		end
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
    criarBlip()
end)

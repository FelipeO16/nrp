local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
JBserver = Tunnel.getInterface("vrp_agencia")

local blip = {
	{name = "Agência de Empregos", id = 351, colour = 21, x = -266.821, y = -960.292, z = 31.023},
}

function criarBlip()
    for _, item in pairs(blip) do
        item.blip = AddBlipForCoord(item.x, item.y, item.z)
        SetBlipSprite(item.blip, item.id)
        SetBlipColour(item.blip, item.colour)
        SetBlipScale(item.blip, 0.6)
        SetBlipAsShortRange(item.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(item.name)
        EndTextCommandSetBlipName(item.blip)
    end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		DrawMarker(27, -266.821,-960.292,31.223-1.0001, 0, 0, 0, 0, 0, 0, 1.0001,1.0001,1.0001, 0, 232, 255, 155, 0, 0, 0, 0, 0, 0, 0)
		if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -266.821,-960.292,31.023, true ) < 1 then
			DrawText3Ds(-266.821,-960.292,31.023, "~g~[E]~w~ Para acessar")
			if (IsControlJustReleased(1, 51)) then
				TriggerServerEvent('Agencia:enviarEmpregos')
			end
		end
	end
end)

RegisterNetEvent('Agencia:receberEmpregos')
AddEventHandler('Agencia:receberEmpregos', function(empregos, identidade, level)
	TransitionToBlurred(1000)
	SetNuiFocus( true, true )
	SendNUIMessage({ativa = true, empregos = empregos, level = level})
end)

RegisterNUICallback('assinar', function(data, cb)
	SetNuiFocus(false, false)
	local emprego = data.id
	local xp = data.xp
	TriggerServerEvent('Agencia:setarEmprego', emprego, xp)	
end)

RegisterNUICallback('fechar', function(data, cb)
	SetNuiFocus( false )
	TransitionFromBlurred(1000)
	SendNUIMessage({ativa = false})
  	cb('ok')
end)

Citizen.CreateThread(function()
	criarBlip()
end)

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end
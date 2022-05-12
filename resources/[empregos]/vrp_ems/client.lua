local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local cfg = module("vrp_ems", "cfg/config")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
SVjob = Tunnel.getInterface("vrp_ems")

local ems = cfg.ems
local display = false

RegisterNetEvent('Emergencia:ReceberCarros')
AddEventHandler('Emergencia:ReceberCarros', function(veiculos)
    TransitionToBlurred(1000)
	SetNuiFocus(true, true)
	SendNUIMessage({
        show = true,
		veiculos = veiculos
	})
end)

function criarBlip()
	for k,v in pairs(ems) do
		local item = ems[k].blip
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

function tickDisplay()
    if SVjob.Permissao() then
        display = true
    else
        display = false
    end
end

function criarMarkers()
    for k,v in pairs(ems) do
        local garagem = ems[k].garagem
        local item = garagem.acessar
        DrawMarker(27, item.x, item.y, item.z-0.94, 0, 0, 0, 0, 0, 0, 2.0001,2.0001,2.0001, 0, 232, 255, 155, 0, 0, 0, 0, 0, 0, 0)
    end
end

function SpawnGaragem(vtype)
	  local mhash = GetHashKey(vtype)

      RequestModel(mhash)
	  while not HasModelLoaded(mhash) do
		Citizen.Wait(10)
	  end

	  if HasModelLoaded(mhash) then
        for k,v in pairs(ems) do
            local garagem = ems[k].garagem
			local item = garagem.spawn
            local pos = item[math.random(1, #item)]
			local nveh = CreateVehicle(mhash, pos.x, pos.y, pos.z, pos.h, true, false)
			SetVehicleOnGroundProperly(nveh)
			SetEntityInvincible(nveh,false)
			SetVehicleNumberPlateText(nveh, "NL-LSPD")
			Citizen.InvokeNative(0xAD738C3085FE7E11, nveh, true, true) 
			SetVehicleHasBeenOwnedByPlayer(nveh,true)
			SetModelAsNoLongerNeeded(mhash)
			return true
		end
	  end
	return false
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

Citizen.CreateThread(function()
    criarBlip()
end)

Citizen.CreateThread(function()
    while true do
        tickDisplay()
        Wait(1000)
    end
end)

Citizen.CreateThread(function ()
	while true do
		criarMarkers()
		Citizen.Wait(1)
	end
end)

Citizen.CreateThread(function() 
    while true do
        for k,v in pairs(ems) do
            local item = ems[k].servico
            local servico = item.entrar
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), servico.x, servico.y, servico.z, true ) <= 1 and display then
                DrawText3D(servico.x, servico.y, servico.z, "Aperte [~g~E~w~] para entrar em serviço")
                if IsControlJustReleased(1, 51) then
                    TriggerServerEvent('Emergencia:EntrarServico')
                end
            end
            
            item = ems[k].garagem
            local garagem = item.acessar
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), garagem.x, garagem.y, garagem.z, true ) <= 1 and display then
                DrawText3D(garagem.x, garagem.y, garagem.z, "Aperte [~g~E~w~] para acessar a garagem")
                if IsControlJustReleased(1, 51) then
                    TriggerServerEvent('Emergencia:EnviarCarros')
                end
            end
        end
        Wait(1)
    end
end)

RegisterNUICallback('retirar', function(data, cb)
    TransitionFromBlurred(1000)
	SetNuiFocus(false)
    local veh = data.id
    SpawnGaragem(veh)
    TriggerServerEvent('Emergencia:AtualizarEstoque', veh)
end)

RegisterNUICallback('fechar', function(data, cb)
	TransitionFromBlurred(1000)
	SetNuiFocus(false)
  	cb('ok')
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
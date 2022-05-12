local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

vRPc = {}
Tunnel.bindInterface("vrp_concessionaria",vRPc)
Proxy.addInterface("vrp_concessionaria",vRPc)
CNserver = Tunnel.getInterface("vrp_concessionaria")

local veiculos = {}
local spawnConce = {
    {x = -47.640, y = -1116.790, z = 26.433, h = 6.800},
	{x = -47.577, y = -1116.562, z = 26.434, h = 6.800},
	{x = -50.647, y = -1116.634, z = 26.434, h = 6.800},
    {x = -53.423, y = -1116.685, z = 26.434, h = 6.800},
    {x = -56.240, y = -1116.933, z = 26.434, h = 6.800},
    {x = -59.037, y = -1116.948, z = 26.434, h = 6.800},
    {x = -61.8131, y = -1117.024, z = 26.433, h = 6.800}
}

function vRPc.spawnVeiculo(vehicle)
	
	local veh,placa = vehicle.vehicle,vehicle.placa
	local motor,lataria,gasolina = vehicle.motor,vehicle.lataria,vehicle.gasolina
	
	local mhash = GetHashKey(veh)
	RequestModel(mhash)
	while not HasModelLoaded(mhash) do
		Citizen.Wait(0)
	end
	local pos = spawnConce[math.random(1, #spawnConce)]
	local nveh = CreateVehicle(mhash, pos.x, pos.y, pos.z, pos.h, true, false)
	local coords = GetEntityCoords(nveh,true)
	local netID = VehToNet(nveh)
	SetModelAsNoLongerNeeded(mhash)
	SetEntityAsMissionEntity(nveh, true, true)
	SetVehicleHasBeenOwnedByPlayer(nveh, true)
	SetVehicleNumberPlateText(nveh, placa)
	SetVehicleEngineHealth(nveh,motor+0.0)
	SetVehicleBodyHealth(nveh,lataria+0.0)
	SetVehicleFuelLevel(nveh,gasolina-0.1)
	NetworkRequestControlOfEntity(nveh)
	while not NetworkHasControlOfEntity(nveh) do
		Citizen.Wait(100)
	end
	SetEntityCollision(nveh, false, false)
	SetEntityAlpha(nveh, 0.0, true)
	SetEntityAsMissionEntity(nveh, true, true)
	SetEntityAsNoLongerNeeded(nveh)
	
	local colours = table.pack(GetVehicleColours(veh))
	local extra_colors = table.pack(GetVehicleExtraColours(veh))

	local custom = {}

	custom.colour = {}
	custom.colour.primary = colours[1]
	custom.colour.secondary = colours[2]
	custom.colour.pearlescent = extra_colors[1]
	custom.colour.wheel = extra_colors[2]
	DeleteEntity(nveh)
	return custom
end

RegisterNetEvent('Concessionaria:receberVeiculos')
AddEventHandler('Concessionaria:receberVeiculos', function(veiculos, garagem, identidade)
	TransitionToBlurred(1000)
	SetNuiFocus(true, true)
		SendNUIMessage({
			dono = true,
			veiculos = veiculos,
			garagem = garagem,
			identidade = identidade
		})
		if CNserver.PermVip() then
			SendNUIMessage({vip = true})
		end
end)

RegisterNUICallback('comprar', function(data, cb)
	SetNuiFocus(false, false)
	TriggerServerEvent('Concessionaria:comprarCarro', data.id)	
end)

RegisterNUICallback('anunciar', function(data, cb)
	SetNuiFocus(false, false)
	local nome = data.nome
	local tipo = data.tipo
	local qtd = data.qtd
	local desc = data.desc
	local img = data.img
	TriggerServerEvent('Concessionaria:anunciarVeiculo', veh, nome, tipo, qtd, desc, img)	
end)

RegisterNUICallback('fechar', function()
	TransitionFromBlurred(1000)
    SetNuiFocus(false, false)
end)

Citizen.CreateThread(function ()
	SetNuiFocus(false)
	while true do
		Citizen.Wait(0)
		DrawMarker(27, -29.842,-1104.661,26.500-1.0001, 0, 0, 0, 0, 0, 0, 1.0001,1.0001,1.0001, 0, 0, 0, 0.8, 0, 0, 0, 0, 0, 0, 0)
		if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -29.842,-1104.661,26.422, true ) < 1 then
		 	if (IsControlJustReleased(1, 51)) then
				TriggerServerEvent('Concessionaria:enviarVeiculos')
		 	end
		end
	end
end)
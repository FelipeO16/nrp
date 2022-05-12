local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local cfg = module("vrp_policia", "cfg/config")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
SVjob = Tunnel.getInterface("vrp_policia")

local dp = cfg.policia
local display = false
local vehicle = {}
local vehicles = {}

local in_tablet = false
local in_vehicle = true
local in_tabletMenu = false
local tabletProp = "prop_cs_tablet"
local tab = CreateObject(GetHashKey("prop_cs_tablet"), 0, 0, 0, true, true, false)
local nuiOpen = false

local PoliciaAcoes = {
    IniciarServico = function(coords)
        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords.x, coords.y, coords.z, true ) <= 1 and display then
            DrawText3D(coords.x, coords.y, coords.z, "Aperte [~g~E~w~] para entrar em serviço")
            if IsControlJustReleased(1, 51) then
                TriggerServerEvent('Policia:EntrarServico')
            end
        end
    end,
    AcessarArsenal = function(coords)
        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords.x, coords.y, coords.z, true ) <= 1 and display then
            DrawText3D(coords.x, coords.y, coords.z, "Aperte [~g~E~w~] para escolher seu arsenal")
            if IsControlJustReleased(1, 51) then
                TriggerServerEvent('Policia:EnviarArsenal')
            end
        end
    end,
    AcessarGaragem = function(coords)
        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords.x, coords.y, coords.z, true ) <= 1 and display then
            DrawText3D(coords.x, coords.y, coords.z, "Aperte [~g~E~w~] para acessar a garagem")
            if IsControlJustReleased(1, 51) then
                TriggerServerEvent('Policia:EnviarCarros')
            end
        end
    end,
    Algemar = function()
        if IsControlJustReleased(0, 58) then
			if not nuiOpen then
				TriggerServerEvent('Policia:AlgemarPlayer')
			else
				SetNuiFocus(true, true)
				SendNUIMessage({phone = true, toggle = true})
				nuiOpen = false
			end
        end
    end,
    Arrastar = function()
        if IsControlJustReleased(1, 101) then
            TriggerServerEvent('Policia:ArrastarPlayer')
        end
    end,
    tablet = function()
        if IsControlJustReleased(0, 212) and SVjob.Permissao() then
            in_tablet = true
            pegarTablet()
            SetNuiFocus(true, true)
            SendNUIMessage({tablet = true})
        end
    end,
    pegarColete = function()
        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 452.383, -981.222, 30.689, true ) <= 1 and display then
            DrawText3D(452.383, -981.222, 30.689, "Aperte [~g~E~w~] para pegar colete")
            if IsControlJustReleased(1, 51) then
                SetPedArmour(PlayerPedId(),100)
            end
        end
    end
}

function pegarTablet()
    if in_tablet and in_vehicle then
        in_tabletMenu = true
        startAnim()
    end
end

Citizen.CreateThread(function()
    while true do
        if IsPedInAnyVehicle(PlayerPedId(), true) then
            in_vehicle = false
        end
        Citizen.Wait(500)
    end
end)

----------------------------------------------------------------------------------------------------------------------------------------------
-- Eventos
----------------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('Policia:ReceberArsenal')
AddEventHandler('Policia:ReceberArsenal', function(arsenal)
    TransitionToBlurred(1000)
	SetNuiFocus(true, true)
	SendNUIMessage({
        showArsenal = true,
		arsenal = arsenal
	})
end)

RegisterNetEvent('Policia:ReceberCarros')
AddEventHandler('Policia:ReceberCarros', function(veiculos)
    TransitionToBlurred(1000)
	SetNuiFocus(true, true)
	SendNUIMessage({
        show = true,
		veiculos = veiculos
	})
end)

RegisterNetEvent('Policia:Algemar')
AddEventHandler('Policia:Algemar', function(target)
    Algemado = true

	local playerPed = PlayerPedId()
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))

	AttachEntityToEntity(playerPed, targetPed, 11816, -0.1, 0.45, 0.0, 0.0, 0.0, 20.0, false, false, false, false, 20, false)

    -- Você faz
	Citizen.Wait(950)
	DetachEntity(playerPed, true, false)

	Algemado = false
end)

local arrastando = false
RegisterNetEvent('Policia:Arrastar')
AddEventHandler('Policia:Arrastar', function(target)
	local playerPed = PlayerPedId()
    local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
    if targetPed and not arrastando then
        AttachEntityToEntity(playerPed, targetPed, 11816, -0.1, 0.45, 0.0, 0.0, 0.0, 20.0, false, false, false, false, 20, false)
        arrastando = true
    else
        if arrastando then
            DetachEntity(PlayerPedId(),true,false)
            arrastando = false
        end
    end
end)

RegisterNetEvent('Policia:infoPlayer')
AddEventHandler('Policia:infoPlayer', function(nome,image,age)
	SendNUIMessage({infoShowUser = true, nome = nome, image = image, age = age})
end)

RegisterNetEvent('Policia:infoVeh')
AddEventHandler('Policia:infoVeh', function(dono,placa,image)
	SendNUIMessage({infoShowVeh = true,dono=dono,placa=placa,image=image})
end)

local sairPrisao = false
local prisioneiro = false
RegisterNetEvent('Polcia:Prisioneiro')
AddEventHandler('Polcia:Prisioneiro',function(status)
    prisioneiro = status
end)

RegisterNetEvent('Polcia:sairPrisao')
AddEventHandler('Polcia:sairPrisao',function()
    local ped = PlayerPedId()
    SetEntityCoords(ped,1791.482,2604.702,45.564)
    SetTimeout(1500, function() 
        TaskGoToCoordAnyMeans(PlayerPedId(), 1791.705, 2593.767, 45.795, 1.0, 0, 0, 786603, 0xbf800000)
        sairPrisao = true
    end)
end)
----------------------------------------------------------------------------------------------------------------------------------------------
-- Funções
----------------------------------------------------------------------------------------------------------------------------------------------
function criarBlip()
	for k, v in pairs(dp) do
		local item = dp[k].blip
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
    for k, v in pairs(dp) do
        local garagem = dp[k].garagem
        local item = garagem.acessar
        DrawMarker(27, item.x, item.y, item.z-0.94, 0, 0, 0, 0, 0, 0, 2.0001,2.0001,2.0001, 0, 232, 255, 155, 0, 0, 0, 0, 0, 0, 0)
    end
end

function SpawnGaragem(vtype)
	  local mhash = GetHashKey(vtype)
	  local i = 0
	  while not HasModelLoaded(mhash) and i < 10000 do
		RequestModel(mhash)
		Citizen.Wait(10)
		i = i+1
	  end

	  if HasModelLoaded(mhash) then
        for k,v in pairs(dp) do
            local garagem = dp[k].garagem
			local item = garagem.spawn
            local pos = item[math.random(1, #item)]
			local nveh = CreateVehicle(mhash, pos.x, pos.y, pos.z, pos.h, true, false)
			SetVehicleOnGroundProperly(nveh)
			SetEntityInvincible(nveh,false)
			SetVehicleNumberPlateText(nveh, "PH-LSPD")
			Citizen.InvokeNative(0xAD738C3085FE7E11, nveh, true, true) 
			SetVehicleHasBeenOwnedByPlayer(nveh,true)
			SetModelAsNoLongerNeeded(mhash)
			return true
		end
	  end
	return false
end

function despawnGarageVehicle(veh,max_range)
	local veiculo = VehToNet(veh)
	local x,y,z = table.unpack(GetEntityCoords(NetToVeh(veiculo),true))
	local px,py,pz = vRP.getPosition()

	if GetDistanceBetweenCoords(x,y,z,px,py,pz,true) < max_range then
		local entityModel = GetEntityModel(NetToVeh(veiculo))
        local model = string.lower(GetDisplayNameFromVehicleModel(entityModel))
		SetVehicleHasBeenOwnedByPlayer(NetToVeh(veiculo),false)
		Citizen.InvokeNative(0xAD738C3085FE7E11,NetToVeh(veiculo),true,true)
		SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(NetToVeh(veiculo)))
		DeleteEntity(NetToVeh(veiculo))
		return true
	end
	return false
end

function startAnim()
	Citizen.CreateThread(function()
        RequestAnimDict("amb@code_human_in_bus_passenger_idles@female@tablet@idle_a")

        while not HasAnimDictLoaded("amb@code_human_in_bus_passenger_idles@female@tablet@idle_a") do
            Citizen.Wait(0)
        end
      
        RequestModel(tabletProp)

        while not HasModelLoaded(tabletProp) do
            Citizen.Wait(150)
        end


        AttachEntityToEntity(tab, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), -0.03, 0.0, 0.0, 0.0, 0.0, 0.0, true, false, false, false, 2, true)
        TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a", "idle_a", 3.0, -8, -1, 63, 0, 0, 0, 0 )
        in_tabletMenu = false

	end)
end

function stopAnim()
    StopAnimTask(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a", "idle_a" ,8.0, -8.0, -1, 50, 0, false, false, false)
    DetachEntity(tab, true, false)
    DeleteEntity(tab)
end

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.40, 0.40)
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

function closeMe()
	TransitionFromBlurred(1000)
    SetNuiFocus(false)
    stopAnim()
    in_tablet = false
    in_vehicle = true
	nuiOpen = false
end

----------------------------------------------------------------------------------------------------------------------------------------------
-- RegistersNUI
----------------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback('retirar', function(data, cb)
    TransitionFromBlurred(1000)
	SetNuiFocus(false)
    local veh = data.id
    SpawnGaragem(veh)
    TriggerServerEvent('Policia:AtualizarEstoque', veh, true)
end)

RegisterNUICallback('devolver', function(data, cb)
    TransitionFromBlurred(1000)
	SetNuiFocus(false)
    local veh = data.id
    despawnGarageVehicle(veh, 15)
    TriggerServerEvent('Policia:AtualizarEstoque', veh, false)
end)

RegisterNUICallback('retirarArma', function(data, cb)
    TransitionFromBlurred(1000)
	SetNuiFocus(false)
    local arma = data.id
    TriggerServerEvent('Policia:ReceberArmaArsenal', arma)
end)

RegisterNUICallback('devolverArma', function(data, cb)
    TransitionFromBlurred(1000)
	SetNuiFocus(false)
    local arma = data.id
    TriggerServerEvent('Policia:DevolverArmaArsenal', arma)
end)

RegisterNUICallback('pegarUser', function(data, cb)
    local userId = data.id
    TriggerServerEvent('Policia:procurarPlayer', userId)
end)

RegisterNUICallback('pegarVeh', function(data, cb)
    local vehId = data.id
    TriggerServerEvent('Policia:procurarVeiculo', vehId)
end)

RegisterNUICallback('fechar', function(data, cb)
	closeMe()
  	cb('ok')
end)

RegisterNUICallback('toggleNui', function(data, cb)
	SetNuiFocus(false)
	vRP.notify("Aperte G para retornar a revista")
	nuiOpen = true
end)

RegisterNUICallback('apagarRevista', function(data, cb)
	TriggerServerEvent("vrp_policia:apagarRegistro",data.id, data.nuserid)
	closeMe()
end)

RegisterNUICallback('apreenderRevista', function(data, cb)
	TriggerServerEvent("vrp_policia:apreenderRegistro",data.id, data.items, data.nuserid)
	closeMe()
end)

----------------------------------------------------------------------------------------------------------------------------------------------
-- Threads
----------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        tickDisplay()
        Wait(1000)
    end
end)

Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(0)
		criarMarkers()
	end
end)

-- Não conseguir escapar!
Citizen.CreateThread(function()
	while true do
        Citizen.Wait(3000)
		if prisioneiro then
			local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),1680.1,2513.0,45.5,true)
            if distance >= 100 then
                print("é maior")
				SetEntityCoords(PlayerPedId(),1680.1,2513.0,45.5)
			end
		end
	end
end)

local chegouPertences = false
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if sairPrisao then
			local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),1791.705,2593.767,45.795,true)
			if distance <= 1 then
                DrawText3D(1791.705,2593.767,45.795, "Aperte [~g~E~w~] para pegar seus pertences")
                chegouPertences = true
                if IsControlJustReleased(1, 51) then
                    TriggerServerEvent('Policia:pegarPertences')
                    sairPrisao = false
                    chegouPertences = false
                end
            elseif distance >= 5 and chegouPertences then
                SetEntityCoords(PlayerPedId(),1791.705,2593.767,45.795)
			end
		end
	end
end)

Citizen.CreateThread(function() 
    while true do
        for k,v in pairs(dp) do
            -- Markers
            local servico,arsenal,garagem = v.servico,v.arsenal,v.garagem
            PoliciaAcoes.IniciarServico(servico.entrar)
            PoliciaAcoes.AcessarArsenal(arsenal.localizacao)    
            PoliciaAcoes.AcessarGaragem(garagem.acessar)
            -- Algemar e Arrastar
            PoliciaAcoes.Algemar()
            PoliciaAcoes.Arrastar()
            -- Tablet
            PoliciaAcoes.tablet()
            -- Pegar colete
            PoliciaAcoes.pegarColete()
        end
        Wait(0)
    end
end)

Citizen.CreateThread(function()
    criarBlip()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)

RegisterNetEvent('vrp_policia:FoundItems')
AddEventHandler('vrp_policia:FoundItems', function(data, id, nuserid)
	SetNuiFocus(true, true)
	SendNUIMessage({phone = true, revistar = true, items = data, id = id, nuserid = nuserid})
end)
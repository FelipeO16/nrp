local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local cfg = module("vrp_garagem", "cfg/config")
vRP = Proxy.getInterface("vRP")

vRPg = {}
Tunnel.bindInterface("vrp_garagem",vRPg)
Proxy.addInterface("vrp_garagem",vRPg)
vGRGS = Tunnel.getInterface("vrp_garagem", "vrp_garagem")

local register = {}
local vehicles = {}

local garagem = cfg.garagem
local rent = cfg.rent
local store = nil

function criarBlip()
	for k, v in pairs(garagem) do
		local item = garagem[k].info
        local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
        SetBlipSprite(blip, item.id)
        SetBlipColour(blip, item.cor)
        SetBlipScale(blip, 0.6)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(item.nome)
        EndTextCommandSetBlipName(blip)
    end
	
	local rentBlip = {}
	for k, v in pairs(rent) do
		if rent[k] == "" or vGRGS.requestPerm(rent[k].perm) then
			local item = rent[k].coords
			print("BLIP adicionado: "..k)
			rentBlip[k] = {}
			for k2, v2 in pairs(item) do
				local blip = AddBlipForCoord(v2.x, v2.y, (GetGroundZFor_3dCoord(v2.x, v2.y, v2.z) or v2.z))
				table.insert(rentBlip[k], blip)
				SetBlipSprite(blip, 357)
				SetBlipColour(blip, 1)
				SetBlipScale(blip, 0.6)
				SetBlipAsShortRange(blip, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(k)
				EndTextCommandSetBlipName(blip)
			end
		end
    end
	
	while true do
		Citizen.Wait(5000)
		for k, v in pairs(rent) do
			if rent[k] == "" or vGRGS.requestPerm(rent[k].perm) then
				if not rentBlip[k] then
					local item = rent[k].coords
					rentBlip[k] = {}
					for k2, v2 in pairs(item) do
						local blip = AddBlipForCoord(v2.x, v2.y, (GetGroundZFor_3dCoord(v2.x, v2.y, v2.z) or v2.z))
						table.insert(rentBlip[k], blip)
						SetBlipSprite(blip, 357)
						SetBlipColour(blip, 3)
						SetBlipScale(blip, 0.6)
						SetBlipAsShortRange(blip, true)
						BeginTextCommandSetBlipName("STRING")
						AddTextComponentString(k)
						EndTextCommandSetBlipName(blip)
					end
					print("BLIP adicionado: "..k)
				end
			else
				if rentBlip[k] then
					for k2, v2 in pairs(rentBlip[k]) do
						if DoesBlipExist(v2) then
							RemoveBlip(v2)
						end
					end
					rentBlip[k] = nil
					print("BLIP removido: "..k)
				end
			end
			Citizen.Wait(10)
		end
	end
end

Citizen.CreateThread(function ()
	while true do
		for k,v in pairs(garagem) do
			local item = v.info
			local cds = v.coords
			local dist = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), cds.x, cds.y, cds.z, true )
			if dist <= 8.0 then
				DrawMarker(27, cds.x, cds.y, cds.z-1.0, 0, 0, 0, 0, 0, 0, 1.0001,1.0001,1.0001, 0, 232, 255, 155, 0, 0, 0, 0, 0, 0, 0)
			end
			if  dist <= 1.5 then
				if IsControlJustReleased(1, 51) then
					local ok = false
					if item.home then 
						ok = vGRGS.requestOwner(item.home)
					else
						ok = true
					end
					if ok then
						register = k
						TriggerServerEvent('Garagem:enviarVeiculos',item.tipo)
					end
				end
			end
		end
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function ()
	SetNuiFocus(false)
	while true do
		for k,v in pairs(rent) do
			local item = v.coords
			for idx, cds in pairs(item) do
				local dist = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), cds.x, cds.y, cds.z, true )
				if dist <= 8.0 then
					DrawMarker(27, cds.x, cds.y, cds.z-1.0, 0, 0, 0, 0, 0, 0, 1.0001,1.0001,1.0001, 0, 232, 255, 155, 0, 0, 0, 0, 0, 0, 0)
					if  dist <= 1.5 then
						if (IsControlJustReleased(1, 51)) then
							local ok, vehs, identidade = vGRGS.requestVehAndPerm(v.perm, v.carros)
							if ok then
								register = k
								SetNuiFocus(true, true)
								TransitionToBlurred(1000)
								SendNUIMessage({
									show = "dentro",
									js = vehs,
									identidade = identidade,
									titulo = register
								})
								store = "rent"
							end
						end
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

RegisterNetEvent('Garagem:receberVeiculos')
AddEventHandler('Garagem:receberVeiculos', function(veiculo, identidade, quantidade)
	SetNuiFocus(true, true)
	TransitionToBlurred(1000)
	SendNUIMessage({
	show = "dentro",
		js = veiculo,
		identidade = identidade,
		titulo = register
	})
	store = "garage"
end)

RegisterNetEvent('deletarveiculo')
AddEventHandler('deletarveiculo',function(vehicle)
    TriggerServerEvent("trydeleteveh",VehToNet(vehicle))
end)

RegisterNetEvent("syncdeleteveh")
AddEventHandler("syncdeleteveh",function(index)
    Citizen.CreateThread(function()
        if NetworkDoesNetworkIdExist(index) then
            SetVehicleAsNoLongerNeeded(index)
            SetEntityAsMissionEntity(index,true,true)
            local v = NetToVeh(index)
            if DoesEntityExist(v) then
                SetVehicleHasBeenOwnedByPlayer(v,false)
                PlaceObjectOnGroundProperly(v)
                SetEntityAsNoLongerNeeded(v)
                SetEntityAsMissionEntity(v,true,true)
				DeleteVehicle(v)
            end
        end
    end)
end)

RegisterNUICallback('spawn', function(data, cb)
	SetNuiFocus(false, false)
	TriggerServerEvent("Garagem:SpawnVeh", data, store)
end)

RegisterNUICallback('guardar', function(data, cb)
	SetNuiFocus(false, false)
	TriggerServerEvent("Garagem:DespawnVeh", data)
end)

RegisterNUICallback('vender', function(data, cb)
	SetNuiFocus(false, false)
	vGRGS._GaragemVenderVeh(data, store)
end)

RegisterNUICallback('pagar', function(data, cb)
	SetNuiFocus(false, false)
	vGRGS._GaragemPagarTarifa(data, store)
end)

function vRPg.freeThisVeh(veh)
	if vehicles[GetEntityModel(veh)] then
		vehicles[GetEntityModel(veh)] = nil
	end
	if DoesEntityExist(veh) then
		NetworkRequestControlOfEntity(veh)
		while not NetworkHasControlOfEntity(veh) do
			Citizen.Wait(100)
		end
		SetEntityCollision(veh, false, false)
		SetEntityAlpha(veh, 0.0, true)
		SetEntityAsMissionEntity(veh, true, true)
		SetEntityAsNoLongerNeeded(veh)
		DeleteEntity(veh)
	end
end


function vRPg.deleteThisVeh(veh)
	if DoesEntityExist(veh) then
		NetworkRequestControlOfEntity(veh)
		while not NetworkHasControlOfEntity(veh) do
			Citizen.Wait(100)
		end
		SetEntityCollision(veh, false, false)
		SetEntityAlpha(veh, 0.0, true)
		SetEntityAsMissionEntity(veh, true, true)
		SetEntityAsNoLongerNeeded(veh)
		DeleteEntity(veh)
	end
end

function vRPg.checkCarSpace()
	local found = false
	local r = register
	local fg
	if garagem[r] then fg = garagem[r] else fg = rent[r] end
	for x, y in pairs(fg.spawn) do
		if not found then
			checkPos = GetClosestVehicle(y.x,y.y,y.z,3.001,0,71)
			if not DoesEntityExist(checkPos) and not checkPos ~= nil then
				found = x
			end
		end
	end
	return found
end

function vRPg.GaragemSpawnVeiculo(vehicle,custom, space, plate)
	local veh,placa = vehicle[1].vehicle,vehicle[1].placa
	local motor,lataria,gasolina = vehicle[1].motor,vehicle[1].lataria,vehicle[1].gasolina
	local mhash = GetHashKey(veh)
	RequestModel(mhash)
	while not HasModelLoaded(mhash) do
		Citizen.Wait(0)
	end

	local item
	if garagem[register] then item = garagem[register].spawn else item = rent[register].spawn end
	local pos = item[space]
	if clearAreaOfVehicles(3) then
		local nveh = CreateVehicle(mhash, pos.x, pos.y, pos.z, pos.h, true, false)
		local coords = GetEntityCoords(nveh,true)
		
		SetVehicleEngineHealth(nveh,motor+0.0)
		SetVehicleBodyHealth(nveh,lataria+0.0)
		SetVehicleFuelLevel(nveh,gasolina-0.1)
		if custom then
			vRPg.setVehicleMods(custom, nveh)
		end
		SetEntityAsMissionEntity(nveh, true, true)
		SetVehicleHasBeenOwnedByPlayer(nveh, true)
		SetVehicleNumberPlateText(nveh,plate)
		
		NetworkRegisterEntityAsNetworked(nveh)
		local netID = VehToNet(nveh)
		
		SetNetworkIdExistsOnAllMachines(netID, true)
		
		
		vehicles[GetEntityModel(nveh)] = netID
		local model = GetEntityModel(nveh)
		return true, netID, model
	end
	return false, nil, nil
end

function vRPg.despawnGarageVehicle(netid, model, update)
	local veh = NetToVeh(netid)
	local entityModel = GetEntityModel(veh)
	
	NetworkRequestControlOfEntity(veh)
	while not NetworkHasControlOfEntity(veh) do
		Citizen.Wait(100)
	end
	
	local gveh = GetVehicleEngineHealth(veh)
	local gvbh = GetVehicleBodyHealth(veh)
	local gvfl = GetVehicleFuelLevel(veh)
	
	if detach then
		DetachEntity(veh, 0, false)
	end
	SetEntityCollision(veh, false, false)
	SetEntityAlpha(veh, 0.0, true)
	SetEntityAsMissionEntity(veh, true, true)
	SetEntityAsNoLongerNeeded(veh)
	DeleteEntity(veh)
	if update then
		TriggerServerEvent("Garagem:statusUpdate",entityModel, gveh, gvbh, gvfl)
		vehicles[entityModel] = nil
	end
	return model
end

function clearAreaOfVehicles(radius)
	local closeby = vRP.getNearestOwnedVehicle(radius)
	if IsEntityAVehicle(closeby) then
	  return false
	end
	return true
end

-- return ok,name
function vRPg.getNearestOwnedVehicle(radius)
	local px,py,pz = vRP.getPosition()
	for k,v in pairs(vehicles) do
		local x,y,z = table.unpack(GetEntityCoords(NetToVeh(v),true))
		local dist = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
		if dist <= radius+0.0001 then
			return true,v,GetEntityModel(NetToVeh(v))
		end -- netid / model
	end
  
	return false,0,""
end

function vRPg.getNearestVehicle(radius)
	local px,py,pz = vRP.getPosition()
	local v = vRP.getNearestVehicle(radius)
	if v then
		local x,y,z = table.unpack(GetEntityCoords(v,true))
		local dist = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
		if dist <= radius+0.0001 then
			return true,VehToNet(v),GetEntityModel(v)
		end -- netid / model
	end
  
	return false,0,""
end

function vRPg.setVehicleMods(custom,veh)
	if custom and veh then
		SetVehicleModKit(veh,0)

		if not custom.customcolor1 and not custom.customcolor2 then
			if custom.color then
				SetVehicleColours(veh,tonumber(custom.color[1]),tonumber(custom.color[2]))
				SetVehicleExtraColours(veh,tonumber(custom.extracolor[1]),tonumber(custom.extracolor[2]))
			end
		else
			SetVehicleCustomPrimaryColour(veh,tonumber(custom.customcolor1[1]),tonumber(custom.customcolor1[2]),tonumber(custom.customcolor1[3]))
			SetVehicleCustomSecondaryColour(veh,tonumber(custom.customcolor2[1]),tonumber(custom.customcolor2[2]),tonumber(custom.customcolor2[3]))
		end

		if custom.smokecolor then
			SetVehicleTyreSmokeColor(veh,tonumber(custom.smokecolor[1]),tonumber(custom.smokecolor[2]),tonumber(custom.smokecolor[3]))
		end

		if custom.neon then
			SetVehicleNeonLightEnabled(veh,0,1)
			SetVehicleNeonLightEnabled(veh,1,1)
			SetVehicleNeonLightEnabled(veh,2,1)
			SetVehicleNeonLightEnabled(veh,3,1)
			SetVehicleNeonLightsColour(veh,tonumber(custom.neoncolor[1]),tonumber(custom.neoncolor[2]),tonumber(custom.neoncolor[3]))
		else
			SetVehicleNeonLightEnabled(veh,0,0)
			SetVehicleNeonLightEnabled(veh,1,0)
			SetVehicleNeonLightEnabled(veh,2,0)
			SetVehicleNeonLightEnabled(veh,3,0)
		end

		if custom.windowtint then
			SetVehicleWindowTint(veh,tonumber(custom.windowtint))
		end

		if custom.bulletProofTyres then
			SetVehicleTyresCanBurst(veh,custom.bulletProofTyres)
		end

		if custom.wheeltype then
			SetVehicleWheelType(veh,tonumber(custom.wheeltype))
		end

		if custom.spoiler then
			SetVehicleMod(veh,0,tonumber(custom.spoiler))
			SetVehicleMod(veh,1,tonumber(custom.fbumper))
			SetVehicleMod(veh,2,tonumber(custom.rbumper))
			SetVehicleMod(veh,3,tonumber(custom.skirts))
			SetVehicleMod(veh,4,tonumber(custom.exhaust))
			SetVehicleMod(veh,5,tonumber(custom.rollcage))
			SetVehicleMod(veh,6,tonumber(custom.grille))
			SetVehicleMod(veh,7,tonumber(custom.hood))
			SetVehicleMod(veh,8,tonumber(custom.fenders))
			SetVehicleMod(veh,10,tonumber(custom.roof))
			SetVehicleMod(veh,11,tonumber(custom.engine))
			SetVehicleMod(veh,12,tonumber(custom.brakes))
			SetVehicleMod(veh,13,tonumber(custom.transmission))
			SetVehicleMod(veh,14,tonumber(custom.horn))
			SetVehicleMod(veh,15,tonumber(custom.suspension))
			SetVehicleMod(veh,16,tonumber(custom.armor))
			SetVehicleMod(veh,23,tonumber(custom.tires),custom.tiresvariation)
		
			if IsThisModelABike(GetEntityModel(veh)) then
				SetVehicleMod(veh,24,tonumber(custom.btires),custom.btiresvariation)
			end
		
			SetVehicleMod(veh,25,tonumber(custom.plateholder))
			SetVehicleMod(veh,26,tonumber(custom.vanityplates))
			SetVehicleMod(veh,27,tonumber(custom.trimdesign)) 
			SetVehicleMod(veh,28,tonumber(custom.ornaments))
			SetVehicleMod(veh,29,tonumber(custom.dashboard))
			SetVehicleMod(veh,30,tonumber(custom.dialdesign))
			SetVehicleMod(veh,31,tonumber(custom.doors))
			SetVehicleMod(veh,32,tonumber(custom.seats))
			SetVehicleMod(veh,33,tonumber(custom.steeringwheels))
			SetVehicleMod(veh,34,tonumber(custom.shiftleavers))
			SetVehicleMod(veh,35,tonumber(custom.plaques))
			SetVehicleMod(veh,36,tonumber(custom.speakers))
			SetVehicleMod(veh,37,tonumber(custom.trunk)) 
			SetVehicleMod(veh,38,tonumber(custom.hydraulics))
			SetVehicleMod(veh,39,tonumber(custom.engineblock))
			SetVehicleMod(veh,40,tonumber(custom.camcover))
			SetVehicleMod(veh,41,tonumber(custom.strutbrace))
			SetVehicleMod(veh,42,tonumber(custom.archcover))
			SetVehicleMod(veh,43,tonumber(custom.aerials))
			SetVehicleMod(veh,44,tonumber(custom.roofscoops))
			SetVehicleMod(veh,45,tonumber(custom.tank))
			SetVehicleMod(veh,46,tonumber(custom.doors))
			SetVehicleMod(veh,48,tonumber(custom.liveries))
			SetVehicleLivery(veh,tonumber(custom.liveries))

			ToggleVehicleMod(veh,20,tonumber(custom.tyresmoke))
			ToggleVehicleMod(veh,22,tonumber(custom.headlights))
			ToggleVehicleMod(veh,18,tonumber(custom.turbo))
		end
		if tonumber(custom.headlights) == 1 then
            SetVehicleHeadlightsColour(veh,tonumber(custom.xenoncolor))
        end
	end
end

RegisterNUICallback('fechar', function()
	SetNuiFocus(false, false)
	TransitionFromBlurred(1000)
end)

local entityEnumerator = {
	__gc = function(enum)
	    if enum.destructor and enum.handle then
		    enum.destructor(enum.handle)
	    end
	    enum.destructor = nil
	    enum.handle = nil
	end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
	    local iter, id = initFunc()
	    if not id or id == 0 then
	        disposeFunc(iter)
		    return
	    end
	  
	    local enum = {handle = iter, destructor = disposeFunc}
	    setmetatable(enum, entityEnumerator)
	  
	    local next = true
	    repeat
		    coroutine.yield(id)
		    next, id = moveFunc(iter)
	    until not next
	  
	    enum.destructor, enum.handle = nil, nil
	    disposeFunc(iter)
	end)
end

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function vRPg.clearAreaServer()
	local mycoords = GetEntityCoords(PlayerPedId())
	local vehs = EnumerateVehicles()
	for Veh in vehs do
		local pedin = false
		for i=-1, 2 do
			if GetPedInVehicleSeat(Veh, i) and GetPedInVehicleSeat(Veh, i) ~= 0 and IsPedAPlayer(GetPedInVehicleSeat(Veh, i)) then
				pedin = true
			end
		end
		if DoesEntityExist(Veh) and not pedin then
			TriggerServerEvent("Garagem:DespawnVeh", {placa = GetVehicleNumberPlateText(Veh), id = GetEntityModel(Veh)})
			TriggerServerEvent("Garagem:forceDeleteVehicle",Veh)
		end
		Citizen.Wait(50)
	end
end

Citizen.CreateThread(function()
	while true do
		if IsControlJustPressed(0,182) then
			local vehid, lock = vGRGS.vehicleLock()
			if vehid then
				if NetworkDoesNetworkIdExist(vehid) then
					local v = NetToVeh(vehid)
					if DoesEntityExist(v) and IsEntityAVehicle(v) then
						if lock == 1 then
							SetVehicleDoorsLocked(v,2)
						else
							SetVehicleDoorsLocked(v,1)
						end
						SetVehicleLights(v,2)
						Wait(200)
						SetVehicleLights(v,0)
						Wait(200)
						SetVehicleLights(v,2)
						Wait(200)
						SetVehicleLights(v,0)
					end
				end
			end
		end
		Citizen.Wait(5)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- REPARAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('reparar')
AddEventHandler('reparar',function()
	local vehicle = vRP.getNearestVehicle(3)
	if IsEntityAVehicle(vehicle) then
		TriggerServerEvent("tryreparar",VehToNet(vehicle))
	end
end)

RegisterNetEvent('syncreparar')
AddEventHandler('syncreparar',function(index)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToVeh(index)
		local fuel = GetVehicleFuelLevel(v)
		if DoesEntityExist(v) then
			if IsEntityAVehicle(v) then
				SetVehicleFixed(v)
				SetVehicleDirtLevel(v,0.0)
				SetVehicleUndriveable(v,false)
				Citizen.InvokeNative(0xAD738C3085FE7E11,v,true,true)
				SetVehicleOnGroundProperly(v)
				SetVehicleFuelLevel(v,fuel)
			end
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- REPARAR MOTOR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('repararmotor')
AddEventHandler('repararmotor',function()
	local vehicle = vRP.getNearestVehicle(3)
	if IsEntityAVehicle(vehicle) then
		TriggerServerEvent("trymotor",VehToNet(vehicle))
	end
end)

RegisterNetEvent('syncmotor')
AddEventHandler('syncmotor',function(index)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToVeh(index)
		if DoesEntityExist(v) then
			if IsEntityAVehicle(v) then
				SetVehicleEngineHealth(v,1000.0)
			end
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- SETCOLOR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("color1",function(source,args)
	local vehiclecolor = vRP.getNearestVehicle(5)
	if vGRGS.CheckColorPermission() then
		SetVehicleCustomPrimaryColour(vehiclecolor,tonumber(args[1]),tonumber(args[2]),tonumber(args[3]))
	end
end)

RegisterCommand("color2",function(source,args)
	local vehiclecolor = vRP.getNearestVehicle(5)
	if vGRGS.CheckColorPermission() then
		SetVehicleCustomSecondaryColour(vehiclecolor,tonumber(args[1]),tonumber(args[2]),tonumber(args[3]))
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETLIVERY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("setlivery",function(source,args)
	local vehiclelivery = vRP.getNearestVehicle(5)
	if vGRGS.CheckLiveryPermission() then
        SetVehicleLivery(vehiclelivery,tonumber(args[1]))
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RETURNCOLOR
-----------------------------------------------------------------------------------------------------------------------------------------
function vRPg.returncolor1(vehicle,color)
	local ped = PlayerPedId()
	local vehicle = vRP.getNearestVehicle(5)
	local r,g,b = GetVehicleCustomPrimaryColour(vehicle)
	return r,g,b
end

function vRPg.returncolor2(vehicle,color)
	local ped = PlayerPedId()
	local vehicle = vRP.getNearestVehicle(5)
	local r,g,b = GetVehicleCustomSecondaryColour(vehicle)
	return r,g,b
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RETURNLIVERY
-----------------------------------------------------------------------------------------------------------------------------------------
function vRPg.returnlivery(vehicle,livery)
	local ped = PlayerPedId()
	local vehicle = vRP.getNearestVehicle(5)
	local livery = GetVehicleLivery(vehicle)
	return livery
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GET HASH
-----------------------------------------------------------------------------------------------------------------------------------------
function vRPg.getHash(vehiclehash)
    local vehicle = vRP.getNearestVehicle(7)
    local vehiclehash = GetEntityModel(vehicle)
    return vehiclehash
end
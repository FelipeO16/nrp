local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
SVnt = Tunnel.getInterface("vrp_nitro")

local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local hasNitroItem = false
local hasWrenchItem = false
local vehicleCoord = nil
local IsInstallingNitro = false
local nitroUsed = false
local nitroveh = nil
local soundofnitro
local sound = false
local exhausts = {}
local installedCars = {}

RegisterNetEvent('Nitro:syncInstalledVehicles')
AddEventHandler('Nitro:syncInstalledVehicles', function(vehicles)
	installedCars = vehicles
end)

RegisterNetEvent('Nitro:hasNitro')
AddEventHandler('Nitro:hasNitro', function(nitro)
	hasNitroItem = nitro
end)

RegisterNetEvent('Nitro:hasWrench')
AddEventHandler('Nitro:hasWrench', function(wrench)
	hasWrenchItem = wrench
end)


local EntityExist = false
local inAnyVehicle = false
local inAnyVehicle2 = false
local playerCoord = false
local coordA = false
local coordB = false
local vehicle = false

Citizen.CreateThread(function() 
    while true do
        if EntityExist then
            if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
                local x, y, z = table.unpack(GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "engine")))
                local distanceToEngine = GetDistanceBetweenCoords(coordA, x, y, z, 1)
                if distanceToEngine < 1.5 then
                    if not hasNitroItem then
                        TriggerServerEvent("Nitro:verifyNitro")
                    end

                    if not hasWrenchItem then
                        TriggerServerEvent("Nitro:verifyWrench")
                    end
                end
            end
        end
        Wait(500)
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if EntityExist then
            if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
                local x, y, z = table.unpack(GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "engine")))
                local distanceToEngine = GetDistanceBetweenCoords(coordA, x, y, z, 1)
                local getPlate = GetVehicleNumberPlateText(vehicle)
                local str = getPlate:gsub("%s+", "")
                local plate = getPlate.gsub(str, "%s+", "")
                local entityModel = GetEntityModel(vehicle)
                local model = string.lower(GetDisplayNameFromVehicleModel(entityModel))
                if distanceToEngine < 1.5 then
                    vehicleCoord = GetEntityCoords(vehicle)
                    if IsControlJustReleased(0, Keys["E"]) then
                        if not IsPlateInList(model, plate) then
                            if hasNitroItem then 
                                TriggerEvent('Nitro:PassOnSequence', model, vehicle, plate, "install")
                                Citizen.Wait(5000)
                            end
                        end
                        if IsPlateInList(model, plate) then
                            if hasWrenchItem then 
                                TriggerEvent('Nitro:PassOnSequence', model, vehicle, plate, "uninstall")
                                Citizen.Wait(5000)
                            end
                        end
                    end
                end

                if hasNitroItem and vehicleCoord ~= nil and not IsPlateInList(model, plate) then
                    DrawText3D(x, y, z, "Press ~r~[E]~s~ para instalar o nitro", 0.6)
                end

                if hasWrenchItem and vehicleCoord ~= nil and IsPlateInList(model, plate) then
                    DrawText3D(x, y, z, "Press ~r~[E]~s~ para remover o nitro", 0.6)
                end
            else
                resetVisual()
            end

            if IsInstallingNitro then
                DisableInput(vehicle)
            end
        end
        Wait(1)
    end
end)

AddEventHandler('Nitro:PassOnSequence', function(model, vehicle, plate, type)
    if IsPlateInList(model, plate) == true then
        if type == "uninstall" then
            TriggerEvent('Nitro:UninstallNitroFromVehicle', model, vehicle, plate)
        end
    else
        if type == "install" then
            TriggerEvent('Nitro:ImplementNitro', model, vehicle, plate)
        end
    end
end)

AddEventHandler('Nitro:ImplementNitro', function(model, vehicle, plate)
    IsInstallingNitro = true
    FreezeEntityPosition(vehicle, true)
    FreezeEntityPosition(PlayerPedId(), true)
    SetVehicleDoorOpen(vehicle, 4, 0, 0)
    startAnim("mini@repair", "fixing_a_ped")
    Wait(2000)
    PlaySoundFromEntity(-1, "Bar_Unlock_And_Raise", vehicle, "DLC_IND_ROLLERCOASTER_SOUNDS", 0, 0)
    Wait(2000)
    SetAudioFlag("LoadMPData", true)
    PlaySoundFrontend(-1, "Lowrider_Upgrade", "Lowrider_Super_Mod_Garage_Sounds", 1)
    Wait(1000)
			
    SetVehicleDoorShut(vehicle, 4, 0)
    FreezeEntityPosition(vehicle, false)
    FreezeEntityPosition(PlayerPedId(), false)
    TriggerServerEvent('Nitro:InstallNitro', model, plate, 100)
    IsInstallingNitro = false
end)

AddEventHandler('Nitro:UninstallNitroFromVehicle', function(model, vehicle, plate)
    IsInstallingNitro = true
    FreezeEntityPosition(vehicle, true)
    FreezeEntityPosition(PlayerPedId(), true)
    SetVehicleDoorOpen(vehicle, 4, 0, 0)
    startAnim("mini@repair", "fixing_a_ped")
    Wait(5000)
    SetVehicleDoorShut(vehicle, 4, 0)
    FreezeEntityPosition(vehicle, false)
    FreezeEntityPosition(PlayerPedId(), false)

    local breakchance = math.random(1, 25)
    if breakchance == 13 then
        SetVehicleEngineOn(vehicle, false, false )
        SetVehicleEngineHealth(vehicle, 0)
        SetVehicleUndriveable(vehicle, true)
    else
        print("removido")
    end
    TriggerServerEvent('Nitro:UninstallNitro', model, plate)
    IsInstallingNitro = false
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if IsControlPressed(0, Keys["LEFTSHIFT"]) and GetPedInVehicleSeat(veh, -1) == ped then
            local getPlate = GetVehicleNumberPlateText(veh)
            local str = getPlate:gsub("%s+", "")
            local plate = getPlate.gsub(str, "%s+", "")
            local entityModel = GetEntityModel(veh)
            local model = string.lower(GetDisplayNameFromVehicleModel(entityModel))
            local isVehicleMarked = IsPlateInList(model, plate)
            if isVehicleMarked then
                local nitroVehicle = GetPlateFromList(model, plate)
                if nitroVehicle.amount > 0 then
                    Citizen.InvokeNative(0xB59E4BD37AE292DB, veh, 5.0)
                    Citizen.InvokeNative(0x93A3996368C94158, veh, 25.0)
                    nitroUsed = true
                    StartScreenEffect("RaceTurbo", 750, false)

                    if sound == false then
                        soundofnitro = PlaySoundFromEntity(GetSoundId(), "Flare", veh, "DLC_HEISTS_BIOLAB_FINALE_SOUNDS", 0, 0)
                        sound = true
                    end
                end
            end
        else
            nitroUsed = false
            Citizen.InvokeNative(0xB59E4BD37AE292DB, veh, 1.0)
            Citizen.InvokeNative(0x93A3996368C94158, veh, 1.0)

            if sound == true then
                StopSound(soundofnitro)
                ReleaseSoundId(soundofnitro)
                sound = false
            end
        end
        Wait(100)
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if inAnyVehicle then
            local veh = GetVehiclePedIsIn(ped, false)
            local getPlate = GetVehicleNumberPlateText(veh)
            if getPlate then
                local str = getPlate:gsub("%s+", "")
                local plate = getPlate.gsub(str, "%s+", "")
                local model = string.lower(GetDisplayNameFromVehicleModel(veh))
                local hash = GetEntityModel(veh)

                if IsThisModelACar(hash) and IsPlateInList(model, plate) then
                    exhausts = {}
                    for i=1,12 do
                        local exhaust = GetEntityBoneIndexByName(veh, "exhaust_" .. i)
                        if i == 1 and GetEntityBoneIndexByName(veh, "exhaust") ~= -1 then
                            table.insert(exhausts, GetEntityBoneIndexByName(veh, "exhaust"))
                        end
                        if exhaust ~= -1 then
                            table.insert(exhausts, exhaust)
                        end
                    end
                end
            end
        end
        Wait(100)
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if inAnyVehicle then
            local veh = GetVehiclePedIsIn(ped, false)
            local getPlate = GetVehicleNumberPlateText(veh)
            if getPlate then
                local str = getPlate:gsub("%s+", "")
                local plate = getPlate.gsub(str, "%s+", "")
                local entityModel = GetEntityModel(veh)
                local model = string.lower(GetDisplayNameFromVehicleModel(entityModel))
                local nitroVehicle = GetPlateFromList(model, plate)
                if nitroUsed and nitroVehicle.amount > 0 then
                    Wait(Config.consumption)
                    nitroVehicle.amount = nitroVehicle.amount - 1
                    if exhausts ~= {} then
                        flame(veh, #exhausts)
                    end
                end
            end
        end
        Wait(100)
    end
end)

Citizen.CreateThread(function() 
    while true do
        local ped = PlayerPedId()
        if inAnyVehicle then
            local veh = GetVehiclePedIsIn(ped, false)
            local getPlate = GetVehicleNumberPlateText(veh)
            if getPlate then
                local str = getPlate:gsub("%s+", "")
                local plate = getPlate.gsub(str, "%s+", "")
                local entityModel = GetEntityModel(veh)
                local model = string.lower(GetDisplayNameFromVehicleModel(entityModel))
                local nitroVehicle = GetPlateFromList(model, plate)
                if nitroVehicle then
                    if nitroVehicle.amount > 0 then
                        TriggerServerEvent('Nitro:UpdateNitroAmount', model, plate, nitroVehicle.amount)
                    elseif nitroVehicle.amount == 0 then
                        TriggerServerEvent('Nitro:UpdateNitroAmount', model, plate, 0)
                        break
                    end
                end
            end
        end
        Wait(5000)
    end
end)

local uix = 0.01135
local uiy = 0.002

Citizen.CreateThread(function()
    while true do
        if inAnyVehicle2 then
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            local getPlate = GetVehicleNumberPlateText(veh)
            if getPlate then
                local str = getPlate:gsub("%s+", "")
                local plate = getPlate.gsub(str, "%s+", "")
                local entityModel = GetEntityModel(veh)
                local model = string.lower(GetDisplayNameFromVehicleModel(entityModel))
                if IsPlateInList(model, plate) then
                    local nitroVehicle = GetPlateFromList(model, plate)
                    drawRct(0.097 - uix, 0.95 - uiy, 0.046, 0.03, 0, 0, 0, 150)
                    DrawAdvancedText(0.171 - uix, 0.957 - uiy, 0.005, 0.0028, 0.3, "NOS~r~["..tostring(nitroVehicle.amount).."]~s~", 255, 255, 255, 255, 9, 1)
                end
            end
        end
        Wait(1)
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if ped then
            inAnyVehicle = IsPedInAnyVehicle(ped)
            inAnyVehicle2 = IsPedInAnyVehicle(ped, false)
            EntityExist = DoesEntityExist(ped)
            playerCoord = GetEntityCoords(ped)
            coordA = GetEntityCoords(ped, 1)
            coordB = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
            vehicle = GetVehicleInDirection(coordA, coordB)
        end
        Wait(500)
    end
end)

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

function IsPlateInList(veh, plate)
    if installedCars[veh] then
        if installedCars[veh].plate == plate then
            return true
        end
    end
    return false
end

function GetPlateFromList(veh, plate)
    if installedCars[veh] then
        if installedCars[veh].plate == plate then
            return installedCars[veh]
        end
    end
    return nil
end

function resetVisual()
    vehicleCoord = nil
    hasNitroItem = false
    hasWrenchItem = false
end

function DisableInput(vehicle)
    DisableControlAction(0, 24, true) -- Attack
	DisableControlAction(0, 257, true) -- Attack 2
	DisableControlAction(0, 25, true) -- Aim
	DisableControlAction(0, 263, true) -- Melee Attack 1
	DisableControlAction(0, 32, true) -- W
	DisableControlAction(0, 34, true) -- A
	DisableControlAction(0, 31, true) -- S
	DisableControlAction(0, 30, true) -- D

	DisableControlAction(0, 45, true) -- Reload
	DisableControlAction(0, 22, true) -- Jump
	DisableControlAction(0, 44, true) -- Cover
	DisableControlAction(0, 37, true) -- Select Weapon
	DisableControlAction(0, 23, true) -- Also 'enter'?

	DisableControlAction(0, 288,  true) -- Disable phone
	DisableControlAction(0, 289, true) -- Inventory
	DisableControlAction(0, 170, true) -- Animations
	DisableControlAction(0, 167, true) -- Job

	DisableControlAction(0, 73, true) -- Disable clearing animation
	DisableControlAction(2, 199, true) -- Disable pause screen

	DisableControlAction(0, 59, true) -- Disable steering in vehicle
	DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
	DisableControlAction(0, 72, true) -- Disable reversing in vehicle

	DisableControlAction(2, 36, true) -- Disable going stealth

	DisableControlAction(0, 47, true)  -- Disable weapon
	DisableControlAction(0, 264, true) -- Disable melee
	DisableControlAction(0, 257, true) -- Disable melee
	DisableControlAction(0, 140, true) -- Disable melee
	DisableControlAction(0, 141, true) -- Disable melee
	DisableControlAction(0, 142, true) -- Disable melee
	DisableControlAction(0, 143, true) -- Disable melee
	DisableControlAction(0, 75, true)  -- Disable exit vehicle
	DisableControlAction(27, 75, true) -- Disable exit vehicle
end

function flame (veh, count)
    if exhausts then
        if not HasNamedPtfxAssetLoaded("core") then
            RequestNamedPtfxAsset("core")
            while not HasNamedPtfxAssetLoaded("core") do
                Wait(1)
            end
        end
        if count == 1 then
            UseParticleFxAssetNextCall("core")
            fire = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[1], 1.0, 0, 0, 0)
            Wait(100)
            StopParticleFxLooped(fire, false)
        elseif count == 2 then
            UseParticleFxAssetNextCall("core")
            fire = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[1], 1.0, 0, 0, 0)
            UseParticleFxAssetNextCall("core")
            fire2 = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[2], 1.0, 0, 0, 0)
            Wait(100)
            StopParticleFxLooped(fire, false)
            StopParticleFxLooped(fire2, false)
        elseif count == 3 then
            UseParticleFxAssetNextCall("core")
            fire = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[1], 1.0, 0, 0, 0)
            UseParticleFxAssetNextCall("core")
            fire2 = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[2], 1.0, 0, 0, 0)
            UseParticleFxAssetNextCall("core")
            fire3 = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[3], 1.0, 0, 0, 0)
            Wait(100)
            StopParticleFxLooped(fire, false)
            StopParticleFxLooped(fire2, false)
            StopParticleFxLooped(fire3, false)
        elseif count == 4 then
            UseParticleFxAssetNextCall("core")
            fire = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[1], 1.0, 0, 0, 0)
            UseParticleFxAssetNextCall("core")
            fire2 = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[2], 1.0, 0, 0, 0)
            UseParticleFxAssetNextCall("core")
            fire3 = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[3], 1.0, 0, 0, 0)
            UseParticleFxAssetNextCall("core")
            fire4 = StartParticleFxLoopedOnEntityBone_2("veh_backfire", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhausts[4], 1.0, 0, 0, 0)
            Wait(100)
            StopParticleFxLooped(fire, false)
            StopParticleFxLooped(fire2, false)
            StopParticleFxLooped(fire3, false)
            StopParticleFxLooped(fire4, false)
        end
    end
end

function GetVehicleInDirection(coordFrom, coordTo)
    local rayHandle = StartShapeTestRay(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, PlayerPedId(), 0)
    local _, _, _, _, vehicle = GetRaycastResult(rayHandle)
    return vehicle
end

function drawRct(x, y, width, height, r, g, b, a)
	DrawRect(x, y, width, height, r, g, b, a)
end

function DrawAdvancedText(x,y ,w,h,sc, text, r,g,b,a,font,jus)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
    N_0x4e096588b13ffeca(jus)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - 0.1+w, y - 0.02+h)
end

function startAnim(lib, anim)
	RequestAnimDict(lib, function()
		TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, 5000, 0, 0, false, false, false)
	end)
end
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

vRP_progress = {
    name = "",
    duration = 0,
    label = "",
    useWhileDead = false,
    canCancel = true,
    controlDisables = {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = false,
    },
    animation = {
        animDict = nil,
        anim = nil,
        flags = 0,
        task = nil,
    },
    prop = {
        model = nil,
        bone = nil,
        coords = { x = 0.0, y = 0.0, z = 0.0 },
        rotation = { x = 0.0, y = 0.0, z = 0.0 },
    },
}

local isDoingAction = false
local disableMouse = false
local wasCancelled = false
local isAnim = false
local isProp = false
local prop_net = nil

function Progress(action, finish)
    local ped = PlayerPedId()
    vRP_progress = action

    if not IsEntityDead(ped) or vRP_progress.useWhileDead then
        if not isDoingAction then
            isDoingAction = true
            wasCancelled = false
            isAnim = false
            isProp = false

            SendNUIMessage({
                action = "call_progress",
                duration = vRP_progress.duration,
                label = vRP_progress.label
            })

            Citizen.CreateThread(function ()
                while isDoingAction do
                    Citizen.Wait(0)
                    if IsControlJustPressed(0, 178) and vRP_progress.canCancel then
                        TriggerEvent("vrp_progress:client:cancel")
                    end
                end
                if finish ~= nil then
                    finish(wasCancelled)
                end
            end)
        else
            vRP.notify('Ação já realizada')
        end
    else
        vRP.notify('Não pode fazer a ação enquanto morto')
    end
end

function ProgressWithStartEvent(action, start, finish)
    local ped = PlayerPedId()
    vRP_progress = action

    if not IsEntityDead(ped) or vRP_progress.useWhileDead then
        if not isDoingAction then
            isDoingAction = true
            wasCancelled = false
            isAnim = false
            isProp = false

            SendNUIMessage({
                action = "call_progress",
                duration = vRP_progress.duration,
                label = vRP_progress.label
            })

            Citizen.CreateThread(function ()
                if start ~= nil then
                    start()
                end
                while isDoingAction do
                    Citizen.Wait(1)
                    if IsControlJustPressed(0, 178) and vRP_progress.canCancel then
                        TriggerEvent("vrp_progress:client:cancel")
                    end
                end
                if finish ~= nil then
                    finish(wasCancelled)
                end
            end)
        else
            vRP.notify("Ação já realizada")
        end
    else
        vRP.notify("Não pode fazer a ação enquanto morto")
    end
end

function ProgressWithTickEvent(action, tick, finish)
    local ped = PlayerPedId()
    vRP_progress = action

    if not IsEntityDead(ped) or vRP_progress.useWhileDead then
        if not isDoingAction then
            isDoingAction = true
            wasCancelled = false
            isAnim = false
            isProp = false

            SendNUIMessage({
                action = "call_progress",
                duration = vRP_progress.duration,
                label = vRP_progress.label
            })

            Citizen.CreateThread(function ()
                while isDoingAction do
                    Citizen.Wait(1)
                    if tick ~= nil then
                        tick()
                    end
                    if IsControlJustPressed(0, 178) and vRP_progress.canCancel then
                        TriggerEvent("vrp_progress:client:cancel")
                    end
                end
                if finish ~= nil then
                    finish(wasCancelled)
                end
            end)
        else
            vRP.notify("Ação já realizada")
        end
    else
        vRP.notify("Não pode fazer a ação enquanto morto")
    end
end

function ProgressWithStartAndTick(action, start, tick, finish)
    local ped = PlayerPedId()
    vRP_progress = action

    if not IsEntityDead(ped) or vRP_progress.useWhileDead then
        if not isDoingAction then
            isDoingAction = true
            wasCancelled = false
            isAnim = false
            isProp = false

            SendNUIMessage({
                action = "call_progress",
                duration = vRP_progress.duration,
                label = vRP_progress.label
            })

            Citizen.CreateThread(function ()
                if start ~= nil then
                    start()
                end
                while isDoingAction do
                    Citizen.Wait(1)
                    if tick ~= nil then
                        tick()
                    end
                    if IsControlJustPressed(0, 178) and vRP_progress.canCancel then
                        TriggerEvent("vrp_progress:client:cancel")
                    end
                end
                if finish ~= nil then
                    finish(wasCancelled)
                end
            end)
        else
            vRP.notify("Ação já realizada")
        end
    else
        vRP.notify("Não pode fazer a ação enquanto morto")
    end
end

RegisterNetEvent("vrp_progress:client:progress")
AddEventHandler("vrp_progress:client:progress", function(action, finish)
    Progress(action, finish)
end)

RegisterNetEvent("vrp_progress:client:ProgressWithStartEvent")
AddEventHandler("vrp_progress:client:ProgressWithStartEvent", function(action, start, finish)
    ProgressWithStartEvent(action, start, finish)
end)

RegisterNetEvent("vrp_progress:client:ProgressWithTickEvent")
AddEventHandler("vrp_progress:client:ProgressWithTickEvent", function(action, tick, finish)
    ProgressWithTickEvent(action, tick, finish)
end)

RegisterNetEvent("vrp_progress:client:ProgressWithStartAndTick")
AddEventHandler("vrp_progress:client:ProgressWithStartAndTick", function(action, start, tick, finish)
    ProgressWithStartAndTick(action, start, tick, finish)
end)

RegisterNetEvent("vrp_progress:client:cancel")
AddEventHandler("vrp_progress:client:cancel", function()
    isDoingAction = false
    wasCancelled = true

    TriggerEvent("vrp_progress:client:actionCleanup")

    SendNUIMessage({
        action = "cancel_progress"
    })
end)

RegisterNetEvent("vrp_progress:client:actionCleanup")
AddEventHandler("vrp_progress:client:actionCleanup", function()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    StopAnimTask(ped, vRP_progress.animDict, vRP_progress.anim, 1.0)
    DetachEntity(NetToObj(prop_net), 1, 1)
    DeleteEntity(NetToObj(prop_net))
    prop_net = nil
end)

Citizen.CreateThread(function()
    
    while true do
        local ped = PlayerPedId()
        if isDoingAction then
            if not isAnim then
                if vRP_progress.animation ~= nil then
                    if vRP_progress.animation.task ~= nil then
                        TaskStartScenarioInPlace(ped, vRP_progress.animation.task, 0, true)
                    elseif vRP_progress.animation.animDict ~= nil and vRP_progress.animation.anim ~= nil then
                        if vRP_progress.animation.flags == nil then
                            vRP_progress.animation.flags = 1
                        end

                        if ( DoesEntityExist( ped ) and not IsEntityDead( ped )) then
                            loadAnimDict( vRP_progress.animation.animDict )
                            TaskPlayAnim( ped, vRP_progress.animation.animDict, vRP_progress.animation.anim, 3.0, 1.0, -1, vRP_progress.animation.flags, 0, 0, 0, 0 )     
                        end
                    else
                        TaskStartScenarioInPlace(ped, 'PROP_HUMAN_BUM_BIN', 0, true)
                    end
                end

                isAnim = true
            end
            if not isProp and vRP_progress.prop ~= nil and vRP_progress.prop.model ~= nil then
                RequestModel(vRP_progress.prop.model)

                while not HasModelLoaded(GetHashKey(vRP_progress.prop.model)) do
                    Citizen.Wait(0)
                end

                local pCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 0.0)
                local modelSpawn = CreateObject(GetHashKey(vRP_progress.prop.model), pCoords.x, pCoords.y, pCoords.z, true, true, true)

                local netid = ObjToNet(modelSpawn)
                SetNetworkIdExistsOnAllMachines(netid, true)
                NetworkSetNetworkIdDynamic(netid, true)
                SetNetworkIdCanMigrate(netid, false)
                if vRP_progress.prop.bone == nil then
                    vRP_progress.prop.bone = 60309
                end

                if vRP_progress.prop.coords == nil then
                    vRP_progress.prop.coords = { x = 0.0, y = 0.0, z = 0.0 }
                end

                if vRP_progress.prop.rotation == nil then
                    vRP_progress.prop.rotation = { x = 0.0, y = 0.0, z = 0.0 }
                end

                AttachEntityToEntity(modelSpawn, ped, GetPedBoneIndex(ped, vRP_progress.prop.bone), vRP_progress.prop.coords.x, vRP_progress.prop.coords.y, vRP_progress.prop.coords.z, vRP_progress.prop.rotation.x, vRP_progress.prop.rotation.y, vRP_progress.prop.rotation.z, 1, 1, 0, 1, 0, 1)
                prop_net = netid

                isProp = true
            end

            DisableActions(ped)
        end
        Citizen.Wait(0)
    end
end)

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end

function DisableActions(ped)
    if vRP_progress.controlDisables.disableMouse then
        DisableControlAction(0, 1, true) -- LookLeftRight
        DisableControlAction(0, 2, true) -- LookUpDown
        DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
    end

    if vRP_progress.controlDisables.disableMovement then
        DisableControlAction(0, 30, true) -- disable left/right
        DisableControlAction(0, 31, true) -- disable forward/back
        DisableControlAction(0, 36, true) -- INPUT_DUCK
        DisableControlAction(0, 21, true) -- disable sprint
    end

    if vRP_progress.controlDisables.disableCarMovement then
        DisableControlAction(0, 63, true) -- veh turn left
        DisableControlAction(0, 64, true) -- veh turn right
        DisableControlAction(0, 71, true) -- veh forward
        DisableControlAction(0, 72, true) -- veh backwards
        DisableControlAction(0, 75, true) -- disable exit vehicle
    end

    if vRP_progress.controlDisables.disableCombat then
        DisablePlayerFiring(ped, true) -- Disable weapon firing
        DisableControlAction(0, 24, true) -- disable attack
        DisableControlAction(0, 25, true) -- disable aim
        DisableControlAction(1, 37, true) -- disable weapon select
        DisableControlAction(0, 47, true) -- disable weapon
        DisableControlAction(0, 58, true) -- disable weapon
        DisableControlAction(0, 140, true) -- disable melee
        DisableControlAction(0, 141, true) -- disable melee
        DisableControlAction(0, 142, true) -- disable melee
        DisableControlAction(0, 143, true) -- disable melee
        DisableControlAction(0, 263, true) -- disable melee
        DisableControlAction(0, 264, true) -- disable melee
        DisableControlAction(0, 257, true) -- disable melee
    end
end

RegisterNUICallback('concluir', function(data, cb)
    isDoingAction = false
    TriggerEvent("vrp_progress:client:actionCleanup")
    cb('ok')
end)

RegisterNUICallback('cancelar', function(data, cb)
    cb('ok')
end)
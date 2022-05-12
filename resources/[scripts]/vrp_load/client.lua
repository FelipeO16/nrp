local wasmenuopen = false

Citizen.CreateThread(function()
	while true do
		Wait(0)
		if IsPauseMenuActive() and not wasmenuopen then
			SetCurrentPedWeapon(PlayerPedId(), 0xA2719263, true) -- set unarmed
			TriggerEvent("Map:ToggleMap")
			--TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_TOURIST_MAP", 0, false) -- Start the scenario
			wasmenuopen = true
		end
		
		if not IsPauseMenuActive() and wasmenuopen then
			Wait(2000)
			TriggerEvent("Map:ToggleMap")
			wasmenuopen = false
		end
	end
end)

local holdingMap = false
local mapModel = "prop_tourist_map_01"
local animDict = "amb@world_human_tourist_map@male@base"
local animName = "base"
local map_net = nil

-- Toggle Map --

RegisterNetEvent("Map:ToggleMap")
AddEventHandler("Map:ToggleMap", function()
    if not holdingMap then
        RequestModel(GetHashKey(mapModel))
        while not HasModelLoaded(GetHashKey(mapModel)) do
            Citizen.Wait(100)
        end

        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(100)
        end

        local plyCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0)
        local mapspawned = CreateObject(GetHashKey(mapModel), plyCoords.x, plyCoords.y, plyCoords.z, 1, 1, 1)
        Citizen.Wait(1000)
        local netid = ObjToNet(mapspawned)
        SetNetworkIdExistsOnAllMachines(netid, true)
        NetworkSetNetworkIdDynamic(netid, true)
        SetNetworkIdCanMigrate(netid, false)
        AttachEntityToEntity(mapspawned, PlayerPedId()), GetPedBoneIndex(PlayerPedId()), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
        TaskPlayAnim(PlayerPedId()), 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = 32 + 16 + 2
        TaskPlayAnim(PlayerPedId()), animDict, animName, 1.0, -1, -1, 50, 0, 0, 0, 0)
        map_net = netid
        holdingMap = true
    else
        ClearPedSecondaryTask(PlayerPedId()))
        DetachEntity(NetToObj(map_net), 1, 1)
        DeleteEntity(NetToObj(map_net))
        map_net = nil
        holdingMap = false
    end
end)

------------------------------------------------------------------
--                          vRP Tunnel/Proxy
------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPcr = {}
Tunnel.bindInterface("vrp_personagem",vRPcr)
Proxy.addInterface("vrp_personagem",vRPcr)
vRP = Proxy.getInterface("vRP")

------------------------------------------------------------------
--                          Variables
------------------------------------------------------------------
local pos = nil
local camPos = nil
local inCreation = false
local cam = -1							-- Camera control
local heading = 180.000				    -- Heading coord
local zoom = "visage"					-- Define which tab is shown first (Default: Head)

------------------------------------------------------------------
--                          Table
------------------------------------------------------------------
local custom = { 
	model = "", fathersID = 0, mothersID = 0, skinColor = 0, eyesColor = 0, acne = 0, skinProblem = 0, freckle = -1, wrinkle = 0, wrinkleopacity = 0, 
	hairModel = 0, firstHairColor = 0, secondHairColor = 0, eyebrow = 0, eyebrowopacity = 0, beard = 0, beardopacity = 0, beardcolor = 0, hats = 0, 
	glasses = 0, ears = 0, tops = 0, pants = 0, shoes = 0, watches = 0, braco = 0
}

------------------------------------------------------------------
--                          NUI
------------------------------------------------------------------
RegisterNUICallback('updateSkin', function(data)
	v = data.value
	-- Face
	custom.fathersID = tonumber(data.dad)
	custom.mothersID = tonumber(data.mum)
	custom.skinColor = tonumber(data.skin)
	custom.eyesColor = tonumber(data.eyecolor)
	custom.acne = tonumber(data.acne)
	custom.skinProblem = tonumber(data.skinproblem)
	custom.freckle = tonumber(data.freckle)
	custom.wrinkle = tonumber(data.wrinkle)
	custom.wrinkleopacity = tonumber(data.wrinkleopacity)
	custom.hairModel = tonumber(data.hair)
	custom.firstHairColor = tonumber(data.haircolor)
	custom.eyebrow = tonumber(data.eyebrow)
	custom.eyebrowopacity = tonumber(data.eyebrowopacity)
	custom.beard = tonumber(data.beard)
	custom.beardopacity = tonumber(data.beardopacity)
	custom.beardcolor = tonumber(data.beardcolor)
	-- Clothes
	custom.hats = tonumber(data.hats)
	custom.glasses = tonumber(data.glasses)
	custom.ears = tonumber(data.ears)
	custom.tops = tonumber(data.tops)
	custom.pants = tonumber(data.pants)
	custom.shoes = tonumber(data.shoes)
	custom.watches = tonumber(data.watches)
	custom.braco = tonumber(data.braco)

	-- Ped
	local ped = PlayerPedId()
	-- Face
	if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then
		custom.mothersID = 0
		SetPedHeadBlendData(ped, custom.fathersID, custom.fathersID, custom.fathersID, custom.skinColor, custom.skinColor, custom.skinColor, 0.1, 0.1, 1.0, true)
	else
		custom.fathersID = 0
		SetPedHeadBlendData(ped, custom.mothersID, custom.mothersID, custom.mothersID, custom.skinColor, custom.skinColor, custom.skinColor, 0.1, 0.1, 1.0, true)
	end
	SetPedEyeColor				(ped, custom.eyesColor)
	if custom.acne == 0 then
		SetPedHeadOverlay		(ped, 0, custom.acne, 0.0)
	else
		SetPedHeadOverlay		(ped, 0, custom.acne, 1.0)
	end
	SetPedHeadOverlay			(ped, 6, custom.skinProblem, 1.0)
	if custom.freckle == 0 then
		SetPedHeadOverlay		(ped, 9, custom.freckle, 0.0)
	else
		SetPedHeadOverlay		(ped, 9, custom.freckle, 1.0)
	end
	SetPedHeadOverlay       	(ped, 3, custom.wrinkle, custom.wrinkleopacity * 0.1)
	SetPedComponentVariation	(ped, 2, custom.hairModel, 0, 2)
	SetPedHairColor				(ped, custom.firstHairColor, custom.wrinkle)
	SetPedHeadOverlay       	(ped, 2, custom.eyebrow, custom.eyebrowopacity * 0.1) 
	SetPedHeadOverlay       	(ped, 1, custom.beard, custom.beardopacity * 0.1)   
	SetPedHeadOverlayColor  	(ped, 1, 1, custom.beardcolor, custom.beardcolor) 
	SetPedHeadOverlayColor  	(ped, 2, 1, custom.beardcolor, custom.beardcolor)

	-- Custom
	if custom.tops == 0 then
		SetPedComponentVariation(ped, 3, 15, 0, 2)
		SetPedComponentVariation(ped, 7, 0, 0, 2)
		SetPedComponentVariation(ped, 8, 15, 0, 2)
		SetPedComponentVariation(ped, 11, 15, 0, 2)
	else
		SetPedComponentVariation(ped, 11, custom.tops, 0, 2)
	end

	if custom.braco == 0 then
		SetPedComponentVariation(ped, 3, 15, 0, 2)
	else
		SetPedComponentVariation(ped, 3, custom.braco, 0, 2)
	end

	if custom.pants == 0 then
		SetPedComponentVariation(ped, 4, 61, 4, 2)
	else
		SetPedComponentVariation(ped, 4, custom.pants)
	end

	if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then
		if custom.shoes == 0 then 	
			SetPedComponentVariation(ped, 6, 34, 0, 2)
		else
			SetPedComponentVariation(ped, 6, custom.shoes)
		end
	else
		if custom.shoes == 0 then 	
			SetPedComponentVariation(ped, 6, 0, 0, 2)
		else
			SetPedComponentVariation(ped, 6, custom.shoes)
		end
	end

	-- Props
	if custom.hats == 0 then
		ClearPedProp(ped, 0)
	else
		SetPedPropIndex(ped, 0, custom.hats, 1-1, 2)
	end

	if custom.glasses == 0 then
		ClearPedProp(ped, 1)
	else
		SetPedPropIndex(ped, 1, custom.glasses, 1-1, 2)
	end

	if custom.ears == 0 then
		ClearPedProp(ped, 2)
	else
		SetPedPropIndex(ped, 2, custom.ears, 1-1, 2)
	end

	if custom.watches == 0 then
		ClearPedProp(ped, 6)
	else
		SetPedPropIndex(ped, 6, custom.watches, 1-1, 2)
	end
end)

Citizen.CreateThread(function()
    while true do
		if not inCreation then
			if custom then
				setCustomization()
			end
        end
        Citizen.Wait(500)
    end
end)

RegisterNUICallback('rotateleftheading', function(data)
	local currentHeading = GetEntityHeading(PlayerPedId())
	heading = currentHeading+tonumber(data.value)
end)

RegisterNUICallback('rotaterightheading', function(data)
	local currentHeading = GetEntityHeading(PlayerPedId())
	heading = currentHeading-tonumber(data.value)
end)

RegisterNUICallback('zoom', function(data)
	zoom = data.zoom
end)

RegisterNUICallback('masculino', function(data,cb)
	custom.model = "mp_m_freemode_01"
	changeGender("mp_m_freemode_01")
	SetPedComponentVariation(PlayerPedId(), 3, 15, 0, 2)
	SetPedComponentVariation(PlayerPedId(), 4, 61, 4, 2)
	SetPedComponentVariation(PlayerPedId(), 6, 34, 0, 2)
	SetPedComponentVariation(PlayerPedId(), 8, 15, 0, 2)
	SetPedComponentVariation(PlayerPedId(), 11, 15, 0, 2)
end)

RegisterNUICallback('feminino', function(data,cb)
	custom.model = "mp_f_freemode_01"
	changeGender("mp_f_freemode_01")
	SetPedHeadBlendData(PlayerPedId(), 45, 45, 45, 12, 12, 12, 2 * 0.1, 2 * 0.1, 1.0, true)
	SetPedComponentVariation(PlayerPedId(), 3, 15, 0, 2)
	SetPedComponentVariation(PlayerPedId(), 4, 61, 4, 2)
	SetPedComponentVariation(PlayerPedId(), 6, 1, 0, 2)
	SetPedComponentVariation(PlayerPedId(), 8, 15, 0, 2)
	SetPedComponentVariation(PlayerPedId(), 11, 15, 0, 2)
end)

RegisterNUICallback('criar', function(data)
	CloseCreator()
	PlayerReturnInstancia()
	DoScreenFadeOut(500)
	Citizen.Wait(500)
	TriggerServerEvent('skinCreator:criarIndentidade', data, custom)
	DoScreenFadeIn(1000)
end)

RegisterNetEvent('skinCreator:abrirCriacao')
AddEventHandler('skinCreator:abrirCriacao', function()
	SkinCreator()
	SetNuiFocus(true, true)
	SendNUIMessage({
		openSkinCreator = true
	})
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)

------------------------------------------------------------------
--                          Functions
------------------------------------------------------------------
function PlayerInstancia()
    for _, player in ipairs(GetActivePlayers()) do
        local ped = PlayerPedId()
        local otherPlayer = GetPlayerPed(player)
        if ped ~= otherPlayer then
            SetEntityVisible(otherPlayer, false)
            SetEntityNoCollisionEntity(ped, otherPlayer, true)
        end
    end
end

function PlayerReturnInstancia()
    for _, player in ipairs(GetActivePlayers()) do
        local ped = PlayerPedId()
        local otherPlayer = GetPlayerPed(player)
        if ped ~= otherPlayer then
            SetEntityVisible(otherPlayer, true)
            SetEntityCollision(ped, true)
        end
    end
end

function vRPcr.setOverlay(data)
	if data then
		custom = data
	end
end

function changeGender(model)
    local mhash = GetHashKey(model)
    while not HasModelLoaded(mhash) do
        RequestModel(mhash)
        Citizen.Wait(50)
	end

    if HasModelLoaded(mhash) then
        SetPlayerModel(PlayerId(), mhash)
		SetModelAsNoLongerNeeded(mhash)
    end
end

function setCustomization()
	local ped = PlayerPedId()
	
	if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then
		SetPedHeadBlendData(ped, custom.fathersID, custom.fathersID, custom.fathersID, custom.skinColor, custom.skinColor, custom.skinColor, 0.1, 0.1, 1.0, true)
	else
		SetPedHeadBlendData(ped, custom.mothersID, custom.mothersID, custom.mothersID, custom.skinColor, custom.skinColor, custom.skinColor, 0.1, 0.1, 1.0, true)
	end
	SetPedEyeColor(ped, custom.eyecolor)
	if custom.acne == 0 then
		SetPedHeadOverlay(ped, 0, custom.acne, 0.0)
	else
		SetPedHeadOverlay(ped, 0, custom.acne, 1.0)
	end
	SetPedHeadOverlay(ped, 6, custom.skinProblem, 1.0)
	if custom.freckle == 0 then
		SetPedHeadOverlay(ped, 9, custom.freckle, 0.0)
	else
		SetPedHeadOverlay(ped, 9, custom.freckle, 1.0)
	end
	SetPedHeadOverlay(ped, 3, custom.wrinkle, custom.wrinkleopacity * 0.1)
	SetPedComponentVariation(ped, 2, custom.hairModel, 0, 2)
	SetPedHairColor(ped, custom.firstHairColor, custom.wrinkle)
	SetPedHeadOverlay(ped, 2, custom.eyebrow, custom.eyebrowopacity * 0.1) 
	SetPedHeadOverlay(ped, 1, custom.beard, custom.beardopacity * 0.1)   
	SetPedHeadOverlayColor(ped, 1, 1, custom.beardcolor, custom.beardcolor) 
	SetPedHeadOverlayColor(ped, 2, 1, custom.beardcolor, custom.beardcolor)
end

function DefaultCustomization()
	local ped = PlayerPedId()
	SetPedComponentVariation(ped, 3, 15, 0, 2)
	SetPedComponentVariation(ped, 7, 0, 0, 2)
	SetPedComponentVariation(ped, 8, 15, 0, 2)
	SetPedComponentVariation(ped, 11, 15, 0, 2)
	SetPedComponentVariation(ped, 6, 34, 0, 2)
	SetPedComponentVariation(ped, 4, 61, 4, 2)
	ClearPedProp(ped, 0)
	ClearPedProp(ped, 1)
	ClearPedProp(ped, 2)
	ClearPedProp(ped, 6)
end

function SetCameraCoords()
	local ped = PlayerPedId()
	RenderScriptCams(false, false, 0, 1, 0)
	DestroyCam(cam, false)
	if not DoesCamExist(cam) then
		cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
		SetCamActive(cam, true)
        RenderScriptCams(true, true, 500, true, true)

        pos = GetEntityCoords(ped)
        camPos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
        SetCamCoord(cam, camPos.x, camPos.y, camPos.z+0.75)
		PointCamAtCoord(cam, pos.x, pos.y, pos.z+0.15)
        SetEntityLocallyVisible(ped)
    end
end

function DeleteCam()
	SetCamActive(cam, false)
	RenderScriptCams(false, true, 0, true, true)
	cam = nil
end

function ChangeCameraCoords()
	local ped = PlayerPedId()
	SetEntityHeading(ped, heading)
	local x,y,z = table.unpack(GetEntityCoords(ped))
	if zoom == "visage" or zoom == "pilosite" then
		SetCamCoord(cam, pos.x, pos.y-0.5, pos.z+0.7)
		PointCamAtCoord(cam, pos.x, pos.y, pos.z+0.60)
		SetCamRot(cam, 0.0, 0.0, 0.0)
	elseif zoom == "vetements" then
		SetCamCoord(cam, pos.x, pos.y-1.5, pos.z+1.0)
		PointCamAtCoord(cam, pos.x, pos.y, pos.z+0.20)
		SetCamRot(cam, 0.0, 0.0, 170.0)
	end
end

function SkinCreator()
	local ped = PlayerPedId()
	inCreation = true

	DisableControlAction(2, 14, true)
	DisableControlAction(2, 15, true)
	DisableControlAction(2, 16, true)
	DisableControlAction(2, 17, true)
	DisableControlAction(2, 30, true)
	DisableControlAction(2, 31, true)
	DisableControlAction(2, 32, true)
	DisableControlAction(2, 33, true)
	DisableControlAction(2, 34, true)
	DisableControlAction(2, 35, true)
	DisableControlAction(0, 25, true)
	DisableControlAction(0, 24, true)

	if IsDisabledControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 142) then
		SendNUIMessage({type = "click"})
	end

	-- Player
	DefaultCustomization()
	SetEntityCoords(ped, 402.882, -996.537, -99.000-1.0)
	SetPlayerInvincible(ped, true)
	-- Cam
	SetCameraCoords()
end

function CloseCreator()
	inCreation = false
	DeleteCam()
	SetNuiFocus(false, false)
	EnableControlAction(2, 14, true)
	EnableControlAction(2, 15, true)
	EnableControlAction(2, 16, true)
	EnableControlAction(2, 17, true)
	EnableControlAction(2, 30, true)
	EnableControlAction(2, 31, true)
	EnableControlAction(2, 32, true)
	EnableControlAction(2, 33, true)
	EnableControlAction(2, 34, true)
	EnableControlAction(2, 35, true)
	EnableControlAction(0, 25, true)
	EnableControlAction(0, 24, true)
end

Citizen.CreateThread(function()
    while true do
        N_0xf4f2c0d4ee209e20()
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
	while true do
		if inCreation then
			ChangeCameraCoords()
		end

		if inCreation then
            PlayerInstancia()
            DisableControlAction(1, 1, true)
            DisableControlAction(1, 2, true)
            DisableControlAction(1, 24, true)
            DisablePlayerFiring(PlayerPedId(), true)
            DisableControlAction(1, 142, true)
            DisableControlAction(1, 106, true)
            DisableControlAction(1, 37, true)
        end
		Citizen.Wait(1)
	end
end)
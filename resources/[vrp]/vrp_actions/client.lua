local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
JBserver = Tunnel.getInterface("vrp_actions","vrp_actions")

local toggleCapot = 0
local movieview = false

local UI = { 
	x =  0.000 ,
	y = -0.001 ,
}

local npcs = {
	["Lenhador"] = {
		["Refinamento"] = {x = -471.108, y = 5304.714, z = 84.980},
		["Comprador"] = {x = 1167.661, y = -1347.221, z = 33.915}
	}
}

function checkDistancia(coords, coords2)
	local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, coords2.x,coords2.y,coords2.z, true)
	if distance <= 5 then
		return true
	end
	return false
end

function clickNpc(coords)
	for k,v in pairs(npcs) do
		local refinamento = checkDistancia(v.Refinamento, coords)
		if refinamento then
			TriggerEvent("Lenhador:clickLenhador")
		end
		local comprador = checkDistancia(v.Comprador, coords)
		if comprador then
			TriggerEvent("Lenhador:clickComprador")
		end
	end
end

Citizen.CreateThread(function()
    while true do
		Citizen.Wait(0)
		listOn = true
        if IsControlJustReleased(0, 246) then
            TransitionToBlurred(1000)
			SetNuiFocus(true, true)
			SendNUIMessage({show = true})
		end
    end
end)

RegisterNUICallback('click', function(data)
	local x,y = data.screen2d.positionX, data.screen2d.positionY
    local mousePos = vector2(x,y)
	local hit, coords, entity = vRP.screen2dToWorld3d(mousePos.x, mousePos.y)
	local _x,_y,_z = vRP.getPosition()
	if hit and IsEntityAPed(entity) and GetEntityType(entity) == 1 then

        local px,py,pz = table.unpack(GetEntityCoords(entity,true))
        local distance = GetDistanceBetweenCoords(_x,_y,_z,px,py,pz,true)
		if distance <= 5 then
			TriggerServerEvent("Actions:ReceberCoordsEntity", coords)
		end
		
	elseif GetEntityType(entity) == 2 then
		local px,py,pz = table.unpack(GetEntityCoords(entity,true))
        local distance = GetDistanceBetweenCoords(_x,_y,_z,px,py,pz,true)
		if distance <= 5 then
			local ped = PlayerPedId()
			local playerCoords = GetEntityCoords(ped)
			local retval, screenX, screenY = World3dToScreen2d(playerCoords.x, playerCoords.y, playerCoords.z + 1)
			offsetX = (screenX * 100 + 5)
			offsetY = (screenY * 100 + 10)
			SendNUIMessage({ showcarMenu = true, x = offsetX, y = offsetY, entity = entity})
		end
	end
	clickNpc(coords)
end)

RegisterNetEvent('Actions:enviarActions')
AddEventHandler('Actions:enviarActions', function(id,identidade,lspd)
	SetNuiFocus(true, true)
	local ped = PlayerPedId()
	local playerCoords = GetEntityCoords(ped)
	local retval, screenX, screenY = World3dToScreen2d(playerCoords.x, playerCoords.y, playerCoords.z + 1)
	offsetX = (screenX * 100 + 5)
	offsetY = (screenY * 100 + 10)
	SendNUIMessage({
		showMenu = true,
		lspd = lspd,
		identidade = identidade,
		id = id,
		x = offsetX,
		y = offsetY
	})
end)

RegisterNUICallback('fechar', function()
    TransitionFromBlurred(1000)
    SetNuiFocus(false, false)
end)

RegisterNUICallback('inventario', function()
    TriggerServerEvent('Inventario:pegarInventario')
end)

RegisterNUICallback('score', function()
    TriggerServerEvent('abrir:scoreSV')
end)

RegisterNUICallback('configcine', function(data)
    movieview = data.id
end)

RegisterNUICallback('actionsMenu', function(data)
	if data.data == "abrirCapo" then
		if(toggleCapot == 0)then
			SetVehicleDoorOpen(data.id, 4, false)
			toggleCapot = 1
		else
			SetVehicleDoorShut(data.id, 4, false)
			toggleCapot = 0
		end
	end
	if data.data == "conviteOrg" then	
		TriggerServerEvent("Org:InviteMembro", data.id)
	end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		if movieview then
			HideHUDThisFrame()
			drawRct(UI.x + 0.0, 	UI.y + 0.0, 1.0,0.15,0,0,0,255) -- Top Bar
			drawRct(UI.x + 0.0, 	UI.y + 0.85, 1.0,0.151,0,0,0,255) -- Bottom Bar
		end
	end
end)

function drawRct(x,y,width,height,r,g,b,a)
	DrawRect(x + width/2, y + height/2, width, height, r, g, b, a)
end

function HideHUDThisFrame()
	HideHelpTextThisFrame()
	HideHudAndRadarThisFrame()
	HideHudComponentThisFrame(1)
	HideHudComponentThisFrame(2)
	HideHudComponentThisFrame(3)
	HideHudComponentThisFrame(4)
	HideHudComponentThisFrame(6)
	HideHudComponentThisFrame(7)
	HideHudComponentThisFrame(8)
	HideHudComponentThisFrame(9)
	HideHudComponentThisFrame(13)
	HideHudComponentThisFrame(11)
	HideHudComponentThisFrame(12)
	HideHudComponentThisFrame(15)
	HideHudComponentThisFrame(18)
	HideHudComponentThisFrame(19)
end
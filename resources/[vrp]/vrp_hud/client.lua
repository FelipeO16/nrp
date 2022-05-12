local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
HUDserver = Tunnel.getInterface("vrp_hud")
vRPhud = {}
Tunnel.bindInterface("vrp_hud",vRPhud)

local fome = 0
local sede = 0
local Voice = true
local vida = false
local colete = false

function vRPhud.setHunger(hunger)
	fome = hunger
end

function vRPhud.setThirst(thirst)
	sede = thirst
end

RegisterNetEvent('Hud:sendStatus')
AddEventHandler('Hud:sendStatus',function(level)
	local ped = PlayerPedId()
	SendNUIMessage({
		show = IsPauseMenuActive(),
		vida = vida,
		colete = GetPedArmour(ped),
		sede = math.ceil(100-sede),
		fome = math.ceil(100-fome)
	})
end)

RegisterNetEvent('Hud:getLevel')
AddEventHandler('Hud:getLevel',function(level)
	SendNUIMessage({
		level = level
	})
end)

RegisterNUICallback('fechar', function(data)
	local tipo = data.id
	SendNUIMessage({show = tipo})
end)

-- Animação para tirar a arma
local weapons = {
	'WEAPON_PISTOL',
	'WEAPON_COMBATPISTOL',
	'WEAPON_APPISTOL',
	'WEAPON_PISTOL50',
	'WEAPON_REVOLVER',
	'WEAPON_SNSPISTOL',
	'WEAPON_HEAVYPISTOL',
	'WEAPON_VINTAGEPISTOL',
	'WEAPON_MACHINEPISTOL'
}

local holstered = true
local canfire = true
local currWeapon = nil
local entityExist = false
local entityDead = false
local isInAnyVehicle = false

Citizen.CreateThread(function()
	while true do
		local player = PlayerPedId()
		local retval = GetEntityCanBeDamaged(player)
			
		if entityExist and not entityDead and not isInAnyVehicle then
			if currWeapon ~= GetSelectedPedWeapon(player) then
				local pos = GetEntityCoords(player, true)
				local rot = GetEntityHeading(player)

				local newWeap = GetSelectedPedWeapon(player)
				SetCurrentPedWeapon(player, currWeapon, true)
				loadAnimDict( "reaction@intimidation@1h" )

				if CheckWeapon(newWeap) then
					if holstered then
						canFire = false
						TaskPlayAnimAdvanced(player, "reaction@intimidation@1h", "intro", pos, 0, 0, rot, 8.0, 3.0, -1, 50, 0.325, 0, 0)
						SetCurrentPedWeapon(player, newWeap, true)
						Citizen.Wait(600)
						ClearPedTasks(player)
						holstered = false
						canFire = true
						currWeapon = newWeap
					elseif newWeap ~= currWeapon then
						canFire = false
						TaskPlayAnimAdvanced(player, "reaction@intimidation@1h", "outro", pos, 0, 0, rot, 8.0, 3.0, -1, 50, 0.125, 0, 0)
						Citizen.Wait(900)
						ClearPedTasks(player)
						TaskPlayAnimAdvanced(player, "reaction@intimidation@1h", "intro", pos, 0, 0, rot, 8.0, 3.0, -1, 50, 0.325, 0, 0)
						SetCurrentPedWeapon(player, newWeap, true)
						Citizen.Wait(600)
						ClearPedTasks(player)
						holstered = false
						canFire = true
						currWeapon = newWeap
					end
				else
					if not holstered then
						canFire = false
						TaskPlayAnimAdvanced(player, "reaction@intimidation@1h", "outro", pos, 0, 0, rot, 8.0, 3.0, -1, 50, 0.125, 0, 0)
						Citizen.Wait(900)
						SetCurrentPedWeapon(player, newWeap, true)
						ClearPedTasks(player)
						holstered = true
						canFire = true
						currWeapon = newWeap
					else
						canFire = false
						TaskPlayAnimAdvanced(player, "reaction@intimidation@1h", "intro", pos, 0, 0, rot, 8.0, 3.0, -1, 50, 0.325, 0, 0)
						SetCurrentPedWeapon(player, newWeap, true)
						Citizen.Wait(600)
						ClearPedTasks(player)
						holstered = false
						canFire = true
						currWeapon = newWeap
					end
				end
			end
		end
		Citizen.Wait(0)
	end
end)

local isTalking = false
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if NetworkIsPlayerTalking(PlayerId()) and not isTalking then 
			isTalking = not isTalking
			SendNUIMessage({ action = 'isTalking', value = isTalking })
		elseif not NetworkIsPlayerTalking(PlayerId()) and isTalking then 
			isTalking = not isTalking
			SendNUIMessage({ action = 'isTalking', value = isTalking })
		end
		
	end
end)

Citizen.CreateThread(function()
    while true do
		local player = PlayerPedId()
      	entityExist = DoesEntityExist(player)
		entityDead = IsEntityDead(player)
		isInAnyVehicle = IsPedInAnyVehicle(player, true)
		colete = GetPedArmour(player)
		vida = math.floor((GetEntityHealth(player)-100)/(GetEntityMaxHealth(player)-100)*100)
		TriggerEvent('Hud:sendStatus')
        Citizen.Wait(500)
    end
end)

Citizen.CreateThread(function()
	while true do
		if not canFire then
			DisableControlAction(0, 25, true)
			DisablePlayerFiring(PlayerPedId(), true)
		end
		Citizen.Wait(500)
	end
end)

function CheckWeapon(newWeap)
	for i = 1, #weapons do
		if GetHashKey(weapons[i]) == newWeap then
			return true
		end
	end
	return false
end

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(500)
	end
end

RegisterNetEvent("notifySuccess:Client")
AddEventHandler("notifySuccess:Client", function(message)
    SendNUIMessage({
        showing = "success",
        newText = message,
    })
end)

RegisterNetEvent("notifyError:Client")
AddEventHandler("notifyError:Client", function(message)
    SendNUIMessage({
        showing = "error",
        newText = message,
    })
end)

RegisterNetEvent("notifyWarning:Client")
AddEventHandler("notifyWarning:Client", function(message)
    SendNUIMessage({
        showing = "warn",
        newText = message,
    })
end)


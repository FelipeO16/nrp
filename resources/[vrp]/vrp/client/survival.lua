-- api

function tvRP.varyHealth(variation)
	local ped = PlayerPedId()
  
	local n = math.floor(GetEntityHealth(ped)+variation)
	SetEntityHealth(ped,n)
end
  
function tvRP.getHealth()
	return GetEntityHealth(PlayerPedId())
end

function tvRP.getMaxHealth()
	return GetEntityMaxHealth(PlayerPedId())
end
  
function tvRP.setHealth(health)
	local n = math.floor(health)
	SetEntityHealth(PlayerPedId(),n)
end
  
function tvRP.setFriendlyFire(flag)
	NetworkSetFriendlyFireOption(flag)
	SetCanAttackFriendly(PlayerPedId(), flag, flag)
end
  
function tvRP.setPolice(flag)
	local player = PlayerId()
	SetPoliceIgnorePlayer(player, not flag)
	SetDispatchCopsForPlayer(player, flag)
end
  
local in_coma = false
local fake_coma = false

function tvRP.updateFakeComa(state)
	fake_coma = state
end

function tvRP.playerComaState(state)
	in_coma = state
end
  
Citizen.CreateThread(function()
	while true do
	  Citizen.Wait(5000)
  
	  if IsPlayerPlaying(PlayerId()) then
		local ped = PlayerPedId()
  
		local vthirst = 0
		local vhunger = 0
  
		if IsPedOnFoot(ped) then
		  local factor = math.min(tvRP.getSpeed(),10)
  
		  vthirst = vthirst+1*factor
		  vhunger = vhunger+0.5*factor
		end
  
		if IsPedInMeleeCombat(ped) then
		  vthirst = vthirst+10
		  vhunger = vhunger+5
		end
  
		if IsPedHurt(ped) or IsPedInjured(ped) then
		  vthirst = vthirst+2
		  vhunger = vhunger+1
		end
  
		if vthirst ~= 0 then
		  vRPserver._varyThirst(-vthirst/12.0)
		end
  
		if vhunger ~= 0 then
		  vRPserver._varyHunger(-vhunger/12.0)
		end
	  end
	end
end)

local deadEvents = {}
local c = 0

Citizen.CreateThread(function()
	local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
	SetEntityCoordsNoOffset(ped,x,y,z+100,0,0,0)
	while true do
		Citizen.Wait(100)
		local ped = PlayerPedId()
		local health = GetEntityHealth(PlayerPedId())
		if health <= 100 and not in_coma then
			c = 0
			SetPedToRagdoll(GetPlayerPed(-1), 2000, 2000, 0, 0, 0, 0)
			deadEvents[1] = GetPlayerServerId(NetworkGetPlayerIndexFromPed(GetPedSourceOfDeath(ped)))
			deadEvents[2] = GetPedCauseOfDeath(ped)
			tvRP.playerComaState(true)
			SetEntityHealth(ped,100)
			vRPserver._updateHealth(100)
			
			if IsPedInAnyVehicle(ped) then
				tvRP.ejectVehicle()
			end
			NetworkSetVoiceActive(false)
			DisableAllControlActions(0)
			DisableAllControlActions(1)
			DisableAllControlActions(2)
			
			SetEntityInvincible(ped, true)
		end
	end
end)

function tvRP.returnDeadEvents()
	return deadEvents
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local ped = PlayerPedId()
		if in_coma and not fake_coma then
			c = c+1
			if c >= (cfg.respawn_time or 600) and in_coma then
				tvRP.playerComaState(false)
				SetPedToRagdoll(GetPlayerPed(-1), 1000, 1000, 0, 0, 0, 0)
				GivePlayerRagdollControl(PlayerId(), true)
				if IsEntityDead(ped) then
					local x,y,z = tvRP.getPosition()
					NetworkResurrectLocalPlayer(x,y,z,true,true,false)
					Citizen.Wait(0)
				end
				SetEntityHealth(PlayerPedId(), 400)
				vRPserver._updateHealth(400)
				EnableAllControlActions(0)
				EnableAllControlActions(1)
				EnableAllControlActions(2)
				SetEntityInvincible(ped, false)
				c = 0
				if vRPserver.finishComa(true) then
					if IsEntityPlayingAnim(ped, "dead", "dead_e", 3) then
						ClearPedTasks(ped)
						SetPedToRagdoll(GetPlayerPed(-1), 1000, 1000, 0, 0, 0, 0)
						Citizen.Wait(5000)
					end
				end
			elseif c < cfg.respawn_time or 600 then
				SetEntityHealth(ped,100)
				vRPserver._updateHealth(100)
				vRPserver._varyThirst(0)
				vRPserver._varyHunger(0)
				RequestAnimDict("dead")
				while not HasAnimDictLoaded("dead") do
					Citizen.Wait(100)
				end
				if not IsEntityPlayingAnim(ped, "dead", "dead_e", 3) then
					if IsPedRagdoll(ped) then
						ClearPedTasksImmediately(ped)
					end
					TaskPlayAnim(ped, "dead", "dead_e", 1.0, 0.0, -1, 9, 9, 1, 1, 1)
				end
				GivePlayerRagdollControl(PlayerId(), false)
			else
				if IsEntityPlayingAnim(ped, "dead", "dead_e", 3) then
					ClearPedTasks(ped)
					SetPedToRagdoll(GetPlayerPed(-1), 1000, 1000, 0, 0, 0, 0)
					Citizen.Wait(5000)
				end
			end
		elseif not fake_coma then
			if IsEntityPlayingAnim(ped, "dead", "dead_e", 3) then
				ClearPedTasksImmediately(ped)
				SetPedToRagdoll(GetPlayerPed(-1), 1000, 1000, 0, 0, 0, 0)
				Citizen.Wait(5000)
			end
		end
	end
end)
  
function tvRP.isInComa()
	return in_coma
end
  
function tvRP.killGod()
	NetworkSetVoiceActive(true)
	SetEntityInvincible(PlayerPedId(),false)
	SetEntityHealth(PlayerPedId(),400)
	vRPserver._updateHealth(400)
	tvRP.playerComaState(false)
	vRPserver._varyThirst(100)
	vRPserver._varyHunger(100)
end
  
Citizen.CreateThread(function() 
	while true do
		Citizen.Wait(100)
		SetPlayerHealthRechargeMultiplier(PlayerId(), 0)
	end
end)
  
function DrawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end
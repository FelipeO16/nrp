local sBuffer = {}
local vBuffer = {}
local CintoSeguranca = false
local ExNoCarro = false
local inVehicle = false

Citizen.CreateThread(function()
	while true do
	local playerPed = PlayerPedId()
	--local playerVeh = GetVehiclePedIsIn(playerPed, false)
	
		if playerPed and cfg.radar then
			DisplayRadar(false)
			HideHudComponentThisFrame()
		end 
		
		if inVehicle and cfg.radar then
			DisplayRadar(true)
			ShowHudComponentThisFrame()
		end
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
    while true do
        inVehicle = IsPedSittingInAnyVehicle(PlayerPedId())
        Citizen.Wait(500)
    end
end)

IsCar = function(veh)
	local vc = GetVehicleClass(veh)
	return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end	

Fwv = function (entity)
	local hr = GetEntityHeading(entity) + 90.0
	if hr < 0.0 then
		hr = 360.0 + hr
	end
	hr = hr * 0.0174533
	return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end
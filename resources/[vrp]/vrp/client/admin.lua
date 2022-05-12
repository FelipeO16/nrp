
local noclip = false
local noclip_speed = 1.0

function tvRP.toggleNoclip()
    noclip = not noclip
    local ped = PlayerPedId()
    if noclip then
        -- set
        SetEntityInvincible(ped, true)
        SetEntityVisible(ped, false, false)
    else
        -- unset
        SetEntityInvincible(ped, false)
        SetEntityVisible(ped, true, false)
    end
end

function tvRP.isNoclip()
    return noclip
end

function tvRP.tpway()
	local ped = PlayerPedId()
	local veh = GetVehiclePedIsUsing(ped)
	if IsPedInAnyVehicle(ped) then
		ped = veh
    end
	local waypointBlip = GetFirstBlipInfoId(8)
	local x,y,z = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09,waypointBlip,Citizen.ResultAsVector()))
	local ground
	local groundFound = false
	local groundCheckHeights = { 0.0,50.0,100.0,150.0,200.0,250.0,300.0,350.0,400.0,450.0,500.0,550.0,600.0,650.0,700.0,750.0,800.0,850.0,900.0,950.0,1000.0,1050.0,1100.0 }
	for i,height in ipairs(groundCheckHeights) do
		SetEntityCoordsNoOffset(ped,x,y,height,0,0,1)

		RequestCollisionAtCoord(x,y,z)
		while not HasCollisionLoadedAroundEntity(ped) do
			RequestCollisionAtCoord(x,y,z)
			Citizen.Wait(1)
		end
		Citizen.Wait(20)

		ground,z = GetGroundZFor_3dCoord(x,y,height)
		if ground then
			z = z + 1.0
			groundFound = true
			break;
		end
	end
	if not groundFound then
		z = 1200
		GiveDelayedWeaponToPed(PlayerPedId(),0xFBAB5776,1,0)
	end
	RequestCollisionAtCoord(x,y,z)
	while not HasCollisionLoadedAroundEntity(ped) do
		RequestCollisionAtCoord(x,y,z)
		Citizen.Wait(1)
	end

	SetEntityCoordsNoOffset(ped,x,y,z,0,0,1)
end


function tvRP.SpawnCar(args)
	local mhash = GetHashKey(args)
	while not HasModelLoaded(mhash) do
		RequestModel(mhash)
		Citizen.Wait(10)
	end

	if HasModelLoaded(mhash) then
		local ped = PlayerPedId()
		local nveh = CreateVehicle(mhash,GetEntityCoords(ped),GetEntityHeading(ped),true,false)

		SetVehicleOnGroundProperly(nveh)
		SetEntityAsMissionEntity(nveh,true,true)
		TaskWarpPedIntoVehicle(ped,nveh,-1)

		SetModelAsNoLongerNeeded(mhash)
	end
end

-- noclip/invisibility
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local ped = PlayerPedId()
		if noclip then -- Control noclip
			local noclip_speed = 1.5
			local x,y,z = tvRP.getPosition()
			local dx,dy,dz = tvRP.getCamDirection()
			local speed = noclip_speed
			if IsControlPressed(0,21) then -- SHIFT
				speed = noclip_speed*3
			end
			
			if IsDisabledControlPressed(0,36) then -- CTRL
				speed = noclip_speed-0.9
			end
			
			if IsControlPressed(0,32) then -- MOVE UP
				x = x+speed*dx
				y = y+speed*dy
				z = z+speed*dz
			end
			
			if IsControlPressed(0,269) then -- MOVE DOWN
				x = x-speed*dx
				y = y-speed*dy
				z = z-speed*dz
			end
			
			if IsControlPressed(0,34) then -- A
				SetGameplayCamRelativeHeading(GetGameplayCamRelativeHeading()+0.5)
			end
			
			if IsControlPressed(0,35) then -- D
				SetGameplayCamRelativeHeading(GetGameplayCamRelativeHeading()-0.5)
			end
			
			SetEntityCoordsNoOffset(ped,x,y,z,true,true,true)
		else
			Citizen.Wait(200)
		end
	end
end)

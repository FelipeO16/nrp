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

function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function GetObjects()
	local objects = {}

	for object in EnumerateObjects() do
		table.insert(objects, object)
	end

	return objects
end

function aRequestModel(modelHash, cb)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

    local i = 0
    while not HasModelLoaded(modelHash) and i < 10000 do
    RequestModel(modelHash)
    Citizen.Wait(10)
    i = i+1
    end


	if cb ~= nil then
		cb()
	end
end

function tvRP.DeleteVehicle(vehicle)
	SetEntityAsMissionEntity(vehicle, false, true)
	DeleteVehicle(vehicle)
end


function tvRP.SpawnVehicle(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()
		aRequestModel(model)

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
		local id = NetworkGetNetworkIdFromEntity(vehicle)

		SetNetworkIdCanMigrate(id, true)
		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetModelAsNoLongerNeeded(model)

		RequestCollisionAtCoord(coords.x, coords.y, coords.z)

		while not HasCollisionLoadedAroundEntity(vehicle) do
			RequestCollisionAtCoord(coords.x, coords.y, coords.z)
			Citizen.Wait(0)
		end

		SetVehRadioStation(vehicle, 'OFF')

		if cb ~= nil then
			cb(vehicle)
		end
	end)
end

function tvRP.GetClosestObject(filter, coords)
	local objects         = GetObjects()
	local closestDistance = -1
	local closestObject   = -1
	local filter          = filter
	local coords          = coords

	if type(filter) == 'string' then
		if filter ~= '' then
			filter = {filter}
		end
	end

	if coords == nil then
		local playerPed = PlayerPedId()
		coords          = GetEntityCoords(playerPed)
	end

	for i=1, #objects, 1 do
		local foundObject = false

		if filter == nil or (type(filter) == 'table' and #filter == 0) then
			foundObject = true
		else
			local objectModel = GetEntityModel(objects[i])

			for j=1, #filter, 1 do
				if objectModel == GetHashKey(filter[j]) then
					foundObject = true
				end
			end
		end

		if foundObject then
			local objectCoords = GetEntityCoords(objects[i])
			local distance     = GetDistanceBetweenCoords(objectCoords, coords.x, coords.y, coords.z, true)

			if closestDistance == -1 or closestDistance > distance then
				closestObject   = objects[i]
				closestDistance = distance
			end
		end
	end

	return closestObject, closestDistance
end

function tvRP.screen2dToWorld3d(absoluteX, absoluteY)
    local camPos = GetGameplayCamCoord()
    local rX,rY = processCoordinates(absoluteX, absoluteY)
    local target = s2w(camPos, rX, rY)

    local dir = sub(target, camPos)
    local from = add(camPos, mul(dir, 0.5))
    local to = add(camPos, mul(dir, 300))

 
    local ray = StartShapeTestRay(from.x, from.y, from.z, to.x, to.y, to.z, 287, PlayerPedId(), 7)
    local a, b, c, d, e = GetShapeTestResult(ray)
	return b,c,e
end

function s2w(camPos, relX, relY)
    local camRot = GetGameplayCamRot()
    local camForward = rotationToDirection(camRot)

    local rotUp = add(camRot, vector3(10, 0, 0))
    local rotDown = add(camRot, vector3(-10, 0, 0))
    local rotLeft = add(camRot, vector3(0, 0, -10))
    local rotRight = add(camRot, vector3(0, 0, 10))
 
    local camRight = sub(rotationToDirection(rotRight), rotationToDirection(rotLeft))
    local camUp = sub(rotationToDirection(rotUp), rotationToDirection(rotDown))
 
    local rollRad = -degToRad(camRot.y)
 
    local camRightRoll = sub(mul(camRight, math.cos(rollRad)), mul(camUp, math.sin(rollRad)))
    local camUpRoll = add(mul(camRight, math.sin(rollRad)), mul(camUp, math.cos(rollRad)))
 
    local point3D = add(
        add(
            add(camPos, mul(camForward, 10.0)),
            camRightRoll
        ),
        camUpRoll)
 
    local point2D = w2s(point3D)
    if (not point2D or point2D == nil) then
        return add(camPos, mul(camForward, 10.0))
    end
 
    local point3DZero = add(camPos, mul(camForward, 10.0))
    local point2DZero = w2s(point3DZero)
    if (not point2DZero or point2DZero == nil) then
        return add(camPos, mul(camForward, 10.0))
	end
 
    local eps = 0.001
    if (math.abs(point2D.x - point2DZero.x) < eps or math.abs(point2D.y - point2DZero.y) < eps) then
        return add(camPos, mul(camForward, 10.0))
	end
 
    local scaleX = (relX - point2DZero.x) / (point2D.x - point2DZero.x)
    local scaleY = (relY - point2DZero.y) / (point2D.y - point2DZero.y)
    local point3Dret = add(
    add(
        add(camPos, mul(camForward, 10.0)),
        mul(camRightRoll, scaleX)
    ),
	mul(camUpRoll, scaleY))
	
    return point3Dret
end

function processCoordinates(x, y)
    local screenX, screenY = GetActiveScreenResolution()

    local relativeX = (1 - ((x / screenX) * 1.0) * 2)
    local relativeY = (1 - ((y / screenY) * 1.0) * 2)
 
    if (relativeX > 0.0) then
        relativeX = -relativeX
    else 
        relativeX = math.abs(relativeX)
	end
 
    if (relativeY > 0.0) then
        relativeY = -relativeY
    else
        relativeY = math.abs(relativeY)
	end
 
    return relativeX,relativeY
end

function w2s(position)
	local result, _x, _y = World3dToScreen2d(position.x, position.y, position.z)

    if (not _x or not _y) then
        return false
	end
 
    return vector3((_x - 0.5) * 2, (_y - 0.5) * 2, 0)
end

function rotationToDirection(rotation)
	local z = degToRad(rotation.z)
	local x = degToRad(rotation.x)
	local num = math.abs(math.cos(x))

	return vector3((-math.sin(z) * num), (math.cos(z) * num), math.sin(x))
end

function degToRad(deg)
	return deg * (math.pi / 180.0)
end

function add(vector1, vector2)
    return vector3(vector1.x + vector2.x, vector1.y + vector2.y, vector1.z + vector2.z)
end
 
function sub(vector1, vector2)
    return vector3(vector1.x - vector2.x, vector1.y - vector2.y, vector1.z - vector2.z)
end
 
function mul(vector1, value)
    return vector3(vector1.x * value, vector1.y * value, vector1.z * value)
end

function tvRP.DrawText3D(coords, text)
	local onScreen,_x,_y=World3dToScreen2d(coords.x, coords.y, coords.z)
	local camCoords      = GetGameplayCamCoords()
	local px,py,pz=table.unpack(GetGameplayCamCoords())

	if onScreen then
		SetTextScale(0.35, 0.35)
		SetTextFont(4)
		SetTextColour(255, 255, 255, 215)
		SetTextDropshadow(0, 0, 0, 0, 255)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry('STRING')
		SetTextCentre(1)

		AddTextComponentString(text)
		DrawText(_x,_y)
		local factor = (string.len(text)) / 370
		DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
	end
end
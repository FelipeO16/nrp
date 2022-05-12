local ajustModels = {
    ['sanchez01'] = 'sanchez'
}

function tvRP.getVehiclePedUsing()
    local ped = PlayerPedId()
    local veiculo = GetVehiclePedIsUsing(ped)
    if veiculo then
        local getPlate = GetVehicleNumberPlateText(veiculo)
        if getPlate then
            local placa = getPlate:gsub("%s+", "", 1)
            local entityModel = GetEntityModel(veiculo)
            local model = string.lower(GetDisplayNameFromVehicleModel(entityModel))
            return placa,model,veiculo
        end
    end
end

function tvRP.getVehicleAtRaycast(radius)
    local player = PlayerPedId()
    local pos = GetEntityCoords(player)
    local entityWorld = GetOffsetFromEntityInWorldCoords(player, radius+0.00001, radius+0.00001, radius+0.00001)
  
    local rayHandle = StartShapeTestCapsule( pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, radius+0.00001, 10, player, 7 )
    local a, b, c, d, vehicleHandle = GetShapeTestResult(rayHandle)

    local getPlate = GetVehicleNumberPlateText(vehicleHandle)
    if getPlate then
        local placa = getPlate:gsub("%s+", "", 1)
        local entityModel = GetEntityModel(vehicleHandle)
        local model = string.lower(GetDisplayNameFromVehicleModel(entityModel))

        if ajustModels[model] then
            model = ajustModels[model]
        end
        
        return placa,model,vehicleHandle
    end
end
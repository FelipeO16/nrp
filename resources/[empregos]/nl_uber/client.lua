local corridas = {}
local valorAtual = 0

local uix = 0.01135
local uiy = 0.002

RegisterNetEvent('Uber:atualizarCorridas')
AddEventHandler('Uber:atualizarCorridas', function(teste)
    corridas = teste
end)

RegisterNetEvent('Uber:resetarCorrida')
AddEventHandler('Uber:resetarCorrida', function(valor)
    valorAtual = valor
end)

Citizen.CreateThread(function()
    while true do
        if corridas then
            for k,v in pairs(corridas) do
                local player = GetPlayerFromServerId(v.motorista_source)
                local ped = GetPlayerPed(player)

                if ped == PlayerPedId() then -- é o motorista
                    local coords = GetEntityCoords(ped, 0) -- Pega a coords do motorista

                    local ply = GetPlayerFromServerId(v.passageiro_source)
                    local plyPed = GetPlayerPed(ply)
                    local plyCoords = GetEntityCoords(plyPed, 0) -- Pega a coords do motorista
                    if GetDistanceBetweenCoords(coords.x, coords.y, coords.z, plyCoords.x, plyCoords.y, plyCoords.z, true) <= 5 and not v.motorista_chegou then
                        local veiculo = GetVehiclePedIsUsing(ped)
                        local model = GetEntityModel(veiculo)
                        local modeloName = GetDisplayNameFromVehicleModel(model)
                        local getPlate = GetVehicleNumberPlateText(veiculo)
                        local str = getPlate:gsub("%s+", "")
                        local placa = getPlate.gsub(str, "%s+", "")
                        TriggerServerEvent('Uber:motoristaChegou', placa, modeloName)
                    end
                end
            end
            
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(1000)
        if corridas then
            for k,v in pairs(corridas) do
                local player = GetPlayerFromServerId(v.motorista_source)
                local ped = GetPlayerPed(player)
                if ped == PlayerPedId() then -- é o motorista
                    if v.corrida_andamento then
                        local motorista = GetPedInVehicleSeat(veh, -1)
                        if(IsPedInAnyVehicle(PlayerPedId(), -1) and motorista) then
                            local kmh = GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId(), false)) * 3.6
                            local velocidade = math.ceil(kmh)
                            if (velocidade > 1) then
                                valorAtual = valorAtual + 0.40
                            end
                        end
                        TriggerServerEvent('Uber:updateValor', valorAtual)
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(1)
        if corridas then
            for k,v in pairs(corridas) do
                local player = GetPlayerFromServerId(v.motorista_source)
                local ped = GetPlayerPed(player)
                if ped == PlayerPedId() then -- é o motorista
                    if v.corrida_andamento then
                        DrawAdvancedText(0.160 - uix, 0.800 - uiy, 0.005, 0.0028, 0.3, "Valor da Corrida: ~g~$"..valorAtual, 255, 255, 255, 160, 9, 1)
                    end
                end
            end
        end
    end
end)

function DrawAdvancedText(x,y ,w,h,sc, text, r,g,b,a,font,jus)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
    N_0x4e096588b13ffeca(jus)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - 0.1+w, y - 0.02+h)
end
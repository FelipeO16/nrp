local casa_slot = {}
local in_slot = {}

RegisterNetEvent('Homes:updateListaCasa')
AddEventHandler('Homes:updateListaCasa', function(casa)
    casa_slot = casa
end)

RegisterNetEvent('Homes:receberCasas')
AddEventHandler('Homes:receberCasas', function(casa)
    casa_slot = casa
end)

RegisterNetEvent('Homes:updateSlot')
AddEventHandler('Homes:updateSlot', function(id_casa)
    in_slot = id_casa
end)

RegisterNetEvent('Home:setRoupaSets')
AddEventHandler('Home:setRoupaSets', function(roupaSets)
    SetNuiFocus(true, true)
    SendNUIMessage({ guardaRoupa = true, roupaSets = roupaSets })
end)

RegisterNetEvent('Home:updateRoupaSets')
AddEventHandler('Home:updateRoupaSets', function(roupaSets)
	SendNUIMessage({ guardaRoupa = 2, roupaSets = roupaSets })
end)

RegisterNUICallback('removeSet', function(data, cb)
    TriggerServerEvent('Homes:removeRoupa', data.useSet)
end)

RegisterNUICallback('salvarRoupa', function(data, cb)
    TriggerServerEvent('Homes:salvarRoupa', data.nome)
end)

RegisterNUICallback('usarSet', function(data, cb)
    TriggerServerEvent('Homes:setarRoupa', data.useSet)
end)

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player, true)

        if casa_slot then
            for k,v in pairs(casa_slot) do
                local id_casa = v.id_casa
                local entrada = v.entrada
                local saida = v.saida
                local guardaRoupa,bau = v.guardaRoupa,v.bau.localizacao
                local nome,trancado = v.casa_nome,v.locked

                -- Entrada
                if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, entrada.x, entrada.y, entrada.z, true) <= 2 then
                    if (not trancado) then
                        DrawText3D(entrada.x, entrada.y, entrada.z+0.2, "~g~[E]~w~ Entrar", true)
                    else
                        DrawText3D(entrada.x, entrada.y, entrada.z+0.2, "Porta: ~r~Trancada", true)
                    end

                    -- Entrar/Sair Casa
                    if IsControlJustPressed(0, 38) then
                        if (not trancado) then
                            TriggerServerEvent('Homes:entrarCasa', nome, id_casa, trancado)
                        end
                    end
                    
                    -- Trancar/Destrancar Casa
                    if IsControlJustPressed(0, 74) then
                        TriggerServerEvent('Homes:alterarStatusCasa', nome, id_casa, trancado)
                    end
                end
                
                if (in_slot == id_casa) then
                    -- Sair
                    if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, saida.x, saida.y, saida.z, true) <= 1 then
                        if (not trancado) then
                            DrawText3D(saida.x, saida.y, saida.z+0.2, "~g~[E]~w~ Sair", true)
                        else
                            DrawText3D(saida.x, saida.y, saida.z+0.2, "Porta: ~r~Trancada", true)
                        end

                        if IsControlJustPressed(0, 38) then
                            if (not trancado) then
                                TriggerServerEvent('Homes:sairCasa', nome)
                            end
                        end

                        if IsControlJustPressed(0, 74) then
                            TriggerServerEvent('Homes:alterarStatusCasa', nome, id_casa, trancado)
                        end
                    end
                    -- Guarda-Roupa
                    if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, guardaRoupa.x, guardaRoupa.y, guardaRoupa.z, true) <= 1 then
                        DrawText3D(guardaRoupa.x, guardaRoupa.y, guardaRoupa.z+0.2, "~b~[Guarda Roupa]~w~\nPressione ~g~[E]", false)
                        if IsControlJustPressed(0, 38) then
                            TriggerServerEvent('Homes:receberSets', k)
                        end
                    end
                    
                    -- Bau
                    if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, bau.x, bau.y, bau.z, true) <= 1 then
                        DrawText3D(bau.x, bau.y, bau.z, "~b~[BAU]~w~\nPressione ~g~[E]", false)
                        if IsControlJustPressed(0, 38) then
                            TriggerServerEvent('Homes:abrirBau', k)
                        end
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)

RegisterNUICallback('fechar', function()
    SetNuiFocus(false, false)
end)

function DrawText3D(x,y,z, text,marker)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.28, 0.28)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    if marker then
        local factor = (string.len(text)) / 370
        DrawRect(_x,_y+0.0125, 0.005+ factor, 0.03, 41, 11, 41, 68)
    end
end
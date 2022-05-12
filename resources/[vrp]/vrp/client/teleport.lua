function LoadMarkers()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5)
            local plyCoords = GetEntityCoords(PlayerPedId())
            for location, val in pairs(teleport.teleport) do
                local entrar = val['entrar']
                local sair = val['sair']

                local ChecarEntrada, ChecarSaida = GetDistanceBetweenCoords(plyCoords, entrar['x'], entrar['y'], entrar['z'], true), GetDistanceBetweenCoords(plyCoords, sair['x'], sair['y'], sair['z'], true)

                if ChecarEntrada <= 7.5 then
                    if teleport then
                        DrawM(entrar['texto'], 27, entrar['x'], entrar['y'], entrar['z'])
                        if ChecarEntrada <= 1.2 then
                            if IsControlJustPressed(0, 38) then
                                Teleport(val, 'entrar')
                            end
                        end
                    else
                        DrawM(entrar['texto'], 27, sair['x'], sair['y'], sair['z'])
                        if ChecarEntrada <= 1.2 then
                            if IsControlJustPressed(0, 38) then
                                Teleport(val, 'entrar')
                            end
                        end
                    end
                end

                if ChecarSaida <= 7.5 then
                    if teleport then
                        DrawM(sair['texto'], 27, sair['x'], sair['y'], sair['z'])
                        if ChecarSaida <= 1.2 then
                            if IsControlJustPressed(0, 38) then
                                Teleport(val, 'sair')
                            end
                        end
                    else
                        DrawM(sair['texto'], 27, sair['x'], sair['y'], sair['z'])
                        if ChecarSaida <= 1.2 then
                            if IsControlJustPressed(0, 38) then
                                Teleport(val, 'sair')
                            end

                        end
                    end
                end
            end
        end
    end)
end

function Teleport(table, location)
    if location == 'entrar' then
        DoScreenFadeOut(100)
        Citizen.Wait(750)
        tvRP.teleport2(PlayerPedId(), table['sair'])
        DoScreenFadeIn(100)
    else
        DoScreenFadeOut(100)
        Citizen.Wait(750)
        tvRP.teleport2(PlayerPedId(), table['entrar'])
        DoScreenFadeIn(100)
    end
end

function DrawM(hint, type, x, y, z)
	tvRP.DrawText3D({x = x, y = y, z = z}, hint, 0.4)
end

Citizen.CreateThread(function()
    LoadMarkers()
end)
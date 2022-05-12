local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
SVjob = Tunnel.getInterface("vrp_pescador")

local in_pesca = false
local distanciaPescar = false
local distanciaVendedor = false

local peds = {
    --{x = -1603.890, y = -1171.571, z = 0.354, nome = "Celso Portioli", heading = 1000.01, hash = 0x62CC28E2, model = "s_m_y_armymech_01", tipo = "Vendedor"},
    {x = -1500.079, y = -933.594, z= 9.200, nome = "Carlos Milagres", heading = 129.00, hash = 0x4163A158, model = "s_m_y_factory_01", tipo = "Comprador"}
}

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        DrawMarker(27, -1850.357, -1249.398, 7.630, 0, 0, 0, 0, 0, 0, 1.0001,1.0001,1.0001, 0, 232, 255, 155, 0, true, 0, 0, 0, 0, 0)
        if distanciaPescar then
            if not in_pesca then
                DisplayHelpText("Aperte ~INPUT_CONTEXT~ para pescar")
                if (IsControlJustReleased(1, 51)) then
                    in_pesca = true
                    pegarVaraDePescar()
                end
            end
        end
        if distanciaVendedor then
            if (IsControlJustReleased(1, 51)) then         
                VenderPeixe()
            end
        end
        Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        distanciaPescar = GetDistanceBetweenCoords(coords, -1850.357, -1249.398, 8.615, true) <= 1
        distanciaVendedor = GetDistanceBetweenCoords(coords, -1500.470,-934.124,10.176, true) <= 0.4
        Citizen.Wait(500)
	end
end)

function criarPed()
    for _, v in pairs(peds) do
        RequestModel(GetHashKey(v.model))
        while not HasModelLoaded(GetHashKey(v.model)) do
            Wait(1)
        end
        Pescador = CreatePed(4, v.hash, v.x, v.y, v.z, 3374176, false, true)
        SetEntityHeading(Pescador, v.heading)
        FreezeEntityPosition(Pescador, true)
        SetEntityInvincible(Pescador, true)
        SetBlockingOfNonTemporaryEvents(Pescador, true)    
    end
end

Citizen.CreateThread(function()
    while true do
        local pos = GetEntityCoords(PlayerPedId(), true)
        for _,v in pairs(peds) do
            if (Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z) < 5.0) then
                DrawText3D(v.x,v.y,v.z+2.10, "~r~"..v.nome, 1.2, 4)
                DrawText3D(v.x,v.y,v.z+1.95, "~w~"..v.tipo, 0.5, 11)
            end
        end
        Citizen.Wait(0)
    end
end)

function pegarVaraDePescar()
    if SVjob.VaraDePescar() then 
        TriggerEvent("vrp_progress:client:progress", {
            name = "unique_action_name",
            duration = 10000,
            label = "Pescando...",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "amb@world_human_stand_fishing@idle_a",
                anim = "idle_c",
            },
            prop = {
                model = "prop_fishing_rod_01",
            }
        }, function(status)
            if not status then
                in_pesca = false
                SVjob.pescarPeixe()
                ClearPedTasks(PlayerPedId())
            end
        end)
    else
        vRP.notify("Você não tem possui uma vara de pescar")
    end
end

function VenderPeixe()
    if SVjob.Permissao() then
        RequestAnimDict("amb@prop_human_parking_meter@female@idle_a")
        while not HasAnimDictLoaded("amb@prop_human_parking_meter@female@idle_a") do
          Wait(1)
        end
        TaskPlayAnim(Pescador,"amb@prop_human_parking_meter@female@idle_a","idle_a_female", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
        TriggerEvent("vrp_progress:client:progress", {
            name = "unique_action_name",
            duration = 10000,
            label = "Vendendo...",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "anim@heists@box_carry@",
                anim = "idle",
            },
            prop = {
                model = "hei_prop_heist_box",
                bone =  "SKEL_R_Hand",
                coords = { x = -0.08, y = 0.28, z = 0.20 },
            },
        }, function(status)
            if not status then
                SVjob.VenderPeixeSV()
                StopAnimTask(Pescador,"amb@prop_human_parking_meter@female@idle_a","idle_a_female", 1.0)
            end
        end)
    end
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function DrawText3D(x,y,z, text, scl, font) 

    local onScreen,_x,_y = World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*scl
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
        SetTextScale(0.0*scale, 1.1*scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

Citizen.CreateThread(function()
    criarPed()
end)
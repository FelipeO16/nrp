Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")

vRPvd = {}
vRP = Proxy.getInterface("vRP")
VDserver = Tunnel.getInterface("nl_usados")
Tunnel.bindInterface("nl_usados",vRPvd)
Proxy.addInterface("nl_usados",vRPvd)

local vendas = {}

local lojas_usados = {
    { nome = "Venda de Usados", id_blip = 523, cor = 46, x = 268.263, y = -1155.298, z = 29.290 },
}

RegisterNetEvent('Usados:setVendas')
AddEventHandler('Usados:setVendas',function(v)
    vendas = v
end)

-- Retorna o modelo do carro em que o player está
function vRPvd.getModel()
    local ped = PlayerPedId()
    local currentVehicle = GetVehiclePedIsUsing(ped)
    local model = GetEntityModel(currentVehicle)
    local name = GetDisplayNameFromVehicleModel(model)
    return name
end

-- Spawna o veiculo com a customização
RegisterNetEvent('Usados:spawnVeiculo')
AddEventHandler('Usados:spawnVeiculo',function(custom, v)
    -- carrega o modelo do veiculo
    local mhash = GetHashKey(v.modelo)

    RequestModel(mhash)
    while not HasModelLoaded(mhash) do
        Citizen.Wait(1)
    end

    local nveh = CreateVehicle(mhash, vendas[v.slot].x,vendas[v.slot].y,vendas[v.slot].z-1, vendas[v.slot].h, true, false)
    
    SetVehicleNumberPlateText(nveh, " "..v.placa)
    SetEntityAsMissionEntity(nveh, true, true)
    SetModelAsNoLongerNeeded(mhash)
    
    -- proteção
    FreezeEntityPosition(nveh,true)
    SetVehicleUndriveable(nveh,true)
    SetEntityInvincible(nveh,true)

    -- Coloca a modificação no carro
    if custom and nveh then
        SetVehicleColours(nveh,custom.cor[1],custom.cor[2])
		SetVehicleExtraColours(nveh,custom.extra_cores[1],custom.extra_cores[2])
    end
end)

RegisterNetEvent('Usados:LiberarVeh')
AddEventHandler('Usados:LiberarVeh',function(veh)
    FreezeEntityPosition(veh,false)
    SetVehicleUndriveable(veh,false)
    SetEntityInvincible(veh,false)
end)

-- Retira o veiculo
function vRPvd.despawnVeiculo()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsUsing(ped)
    -- deleta o veiculo
    SetVehicleHasBeenOwnedByPlayer(veh,false)
    Citizen.InvokeNative(0xAD738C3085FE7E11, veh, false, true)
    SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(veh))
    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
end

-- Retira o veiculo
function vRPvd.despawnAllVeiculo(v)
    -- carrega o modelo do veiculo
    local mhash = GetHashKey(v.modelo)
    -- deleta o veiculo
    SetVehicleHasBeenOwnedByPlayer(mhash,false)
    Citizen.InvokeNative(0xAD738C3085FE7E11, mhash, false, true)
    SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(mhash))
    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(mhash))
end

-- Texto 3D
function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end

-- Blips
Citizen.CreateThread(function()
    for _, item in pairs(lojas_usados) do
        item.blip = AddBlipForCoord(item.x, item.y, item.z)
        SetBlipSprite(item.blip, item.id_blip)
        SetBlipColour(item.blip, item.cor)
        SetBlipScale(item.blip, 0.6)
        SetBlipAsShortRange(item.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("~o~Loja~w~ " ..item.nome)
        EndTextCommandSetBlipName(item.blip)
    end
end)

-- Marcações
local entrou = nil
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(vendas) do
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), vendas[k].x, vendas[k].y, vendas[k].z, true ) < 10 then
                if vendas[k].ocupado then
                    DrawText3D(vendas[k].x, vendas[k].y, vendas[k].z, "Modelo: "..vendas[k].modelo.. "\nPreço: ~g~R$"..addComma(vendas[k].preco).."\n~y~/comprar")
                else
                    DrawText3Ds(vendas[k].x, vendas[k].y, vendas[k].z, vendas[k].mensagem)
                end
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), vendas[k].x, vendas[k].y, vendas[k].z, true ) < 1 then
                    if vendas[k].ocupado then
                        if type(entrou) == 'nil' and DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId())) then -- se existe um veiculo que o player esta tentando entrar (peguei do vrp_nocarjack)
                            entrou = k
                            VDserver.entrarVenda(k)
                        end
                    else
                        if IsControlJustPressed(0, 38) then
                            VDserver.colocarVenda(k)
                        end
                    end
                else
                    if entrou == k then
                        entrou = nil
                        VDserver.sairVenda(k)
                    end
                end
            end
        end
    end
end)

function addComma(amount)
    local formatted = amount
    while true do  
      formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
      if (k==0) then
        break
      end
    end
    return formatted
end
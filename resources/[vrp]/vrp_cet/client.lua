local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPct = {}
vRP = Proxy.getInterface("vRP")
CTserver = Tunnel.getInterface("vrp_cet")
Tunnel.bindInterface("vrp_cet",vRPct)
Proxy.addInterface("vrp_cet",vRPct)

local vagas = {}

local patio = {
    { nome = "Pátio", id_blip = 523, cor = 46, x = 401.414, y = -1648.040, z = 29.292 }
}

RegisterNetEvent('CET:setApreendido')
AddEventHandler('CET:setApreendido',function(v)
    vagas = v
end)

-- Retorna o modelo do carro em que o player está
function vRPct.getModel()
    local ped = PlayerPedId()
    local currentVehicle = GetVehiclePedIsUsing(ped)
    local model = GetEntityModel(currentVehicle)
    local name = GetDisplayNameFromVehicleModel(model)
    return name
end

-- Checa se o player está em um veiculo
function vRPct.IsInVehicle()
    local ply = PlayerPedId()
    if IsPedSittingInAnyVehicle(ply) then
      return true
    else
      return false
    end
end

-- Spawna o veiculo com a customização
RegisterNetEvent('CET:spawnVeiculo')
AddEventHandler('CET:spawnVeiculo',function(custom, v)
    print(custom, v.modelo)
    -- carrega o modelo do veiculo
    local mhash = GetHashKey(v.modelo)

    RequestModel(mhash)
    while not HasModelLoaded(mhash) do
        Citizen.Wait(0)
    end
    -- spawna o carro
    if HasModelLoaded(mhash) then
        local nveh = CreateVehicle(mhash, vagas[v.slot].x,vagas[v.slot].y,vagas[v.slot].z-1, vagas[v.slot].h, true, false)

        SetVehicleNumberPlateText(nveh, v.placa)
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
        return true
    end
    return false
end)

RegisterNetEvent('CET:LiberarVeh')
AddEventHandler('CET:LiberarVeh',function(veh)
    FreezeEntityPosition(veh,false)
    SetVehicleUndriveable(veh,false)
    SetEntityInvincible(veh,false)
end)

function DrawText3D(x,y,z,text,show)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.30, 0.30)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    if show then
        local factor = (string.len(text)) / 370
        DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
    end
end

-- Blips
Citizen.CreateThread(function()
    for _, item in pairs(patio) do
        item.blip = AddBlipForCoord(item.x, item.y, item.z)
        SetBlipSprite(item.blip, item.id_blip)
        SetBlipColour(item.blip, item.cor)
        SetBlipScale(item.blip, 0.6)
        SetBlipAsShortRange(item.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("~o~CET~w~ " ..item.nome)
        EndTextCommandSetBlipName(item.blip)
    end
end)

-- Marcações
local entrou = nil
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(vagas) do
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), vagas[k].x, vagas[k].y, vagas[k].z, true ) < 10 then
                if vagas[k].ocupado then
                    DrawText3D(vagas[k].x, vagas[k].y, vagas[k].z, "~y~[Pátio]~w~\nStatus: ~r~Apreendido~w~\nDono: "..vagas[k].dono_nome.."\nModelo: "..vagas[k].modelo.. "\nValor Retirada: ~g~R$"..addComma(vagas[k].valor), false)
                end
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), vagas[k].x, vagas[k].y, vagas[k].z, true ) < 1 then
                    if vagas[k].ocupado then
                        if type(entrou) == 'nil' and DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId())) then -- se existe um veiculo que o player esta tentando entrar (peguei do vrp_nocarjack)
                            entrou = k
                            CTserver.entrarApreendido(k)
                        end
                    end
                else
                    if entrou == k then
                        entrou = nil
                        CTserver.sairApreendido(k)
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
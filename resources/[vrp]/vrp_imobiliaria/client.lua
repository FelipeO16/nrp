local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPim = {}
vRP = Proxy.getInterface("vRP")
IMserver = Tunnel.getInterface("vrp_imobiliaria")
Tunnel.bindInterface("vrp_imobiliaria",vRPim)
Proxy.addInterface("vrp_imobiliaria",vRPim)

local onMenu = false

local imobiliaria = {
	{name="Imobiliária", id = 375, colour = 2, x = -139.045, y = -632.166, z = 168.820},
}

function criarBlip()
    for _, item in pairs(imobiliaria) do
        item.blip = AddBlipForCoord(item.x, item.y, item.z)
        SetBlipSprite(item.blip, item.id)
        SetBlipColour(item.blip, item.colour)
        SetBlipScale(item.blip, 0.6)
        SetBlipAsShortRange(item.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(item.name)
        EndTextCommandSetBlipName(item.blip)
    end
end

function criarPed()
    RequestModel(GetHashKey("cs_debra"))
    while not HasModelLoaded(GetHashKey("cs_debra")) do
        Wait(1)
    end
    local imobiliaria = CreatePed(4, 0xECD04FE9, -138.854, -633.860, 167.820, 90.404, false, true)
    SetEntityHeading(imobiliaria, 14.516)
    FreezeEntityPosition(imobiliaria, true)
    SetEntityInvincible(imobiliaria, true)
    SetBlockingOfNonTemporaryEvents(imobiliaria, true)
end

RegisterNetEvent('Imobiliaria:receberCasasVenda')
AddEventHandler('Imobiliaria:receberCasasVenda', function(casas, quantidade)
    onMenu = true
	SetNuiFocus(true, true)
	SendNUIMessage({
        show = true,
        stream = IMserver.PermStreamer(),
        vip = IMserver.PermVip(),
        casas = casas,
        quantidade = quantidade
    })
end)

RegisterNetEvent("Imobiliaria:Notificacao")
AddEventHandler("Imobiliaria:Notificacao", function(text, time)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(text)
  Citizen.InvokeNative(0x1E6611149DB3DB6B, "CHAR_ANTONIA", "CHAR_ANTONIA", true, 1, "Imobiliária", "Atendente Debra", time)
  DrawNotification_4(false, true)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)

RegisterNUICallback('visitar', function(data, cb)
	SetNuiFocus(false, false)
    local info = data.info
    TriggerServerEvent('Imobiliaria:visitarCasas', info)
    onMenu = false
end)

RegisterNUICallback('comprar', function(data, cb)
	SetNuiFocus(false, false)
    local casa = data.casa
    TriggerServerEvent('Imobiliaria:comprarCasa', casa)
    onMenu = false
end)

RegisterNUICallback('fechar', function()
    SetNuiFocus(false, false)
    onMenu = false
end)

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player, true)
        if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, -139.200,-631.850,168.820, true) <= 1 then
            if not onMenu then
                TriggerEvent("Imobiliaria:Notificacao", "Pressione ~g~E~w~ para acessar a imobiliária.", 0.150)
            end

            onMenu = true

            if IsControlJustPressed(0, 38) then
                TriggerServerEvent('Imobiliaria:enviarCasasVenda')
            end
        else
            onMenu = false
        end
        Wait(0)
    end
end)

Citizen.CreateThread(function()
    criarPed()
    criarBlip()
end)

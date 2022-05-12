local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
JBserver = Tunnel.getInterface("vrp_playerlist","vrp_playerlist")

RegisterNetEvent('abrir:scoreCL')
AddEventHandler('abrir:scoreCL', function(nome, foto, phone, register, age, level, adm, players)
    TransitionToBlurred(1000)
	SetNuiFocus(true, true)
	SendNUIMessage({
        show = true,
        nome = nome,
        foto = foto,
        phone = phone,
        register = register,
        age = age,
        lvl = level,
        adm = adm,
        text = table.concat(players)
    })
end)

RegisterNUICallback('changeFoto', function(data, cb)
    JBserver.changeFoto(data.img)
end)


RegisterNUICallback('fechar', function()
    TransitionFromBlurred(1000)
    SetNuiFocus(false, false)
end)

local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPjb = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_actions",vRPjb)

local lspd = false

local teste = {
    [1] = {group = 'LSPD'},
    [2] = {group = 'EMS'},
    [3] = {group = 'admin'}
}

RegisterServerEvent('Actions:ReceberCoordsEntity')
AddEventHandler('Actions:ReceberCoordsEntity', function(coords)
    local source = source
    local user_id = vRP.getUserId(source)
    local nplayer = vRPclient.getNearestPlayerByCoords(source,coords)
    if nplayer then
        nuser_id = vRP.getUserId(nplayer)
        if nuser_id then
            local algemado = vRPclient.isHandcuffed(source)
            if not algemado then
                local identity = vRP.getUserIdentity(nuser_id)
                if vRP.hasPermission(user_id, "policia.perm") then
                    lspd = true
                else
                    lspd = false
                end
                TriggerClientEvent('Actions:enviarActions', source, nuser_id, identity.name.." "..identity.firstname, lspd)
            end
        end
    end
end)

RegisterServerEvent('Actions:carMenu')
AddEventHandler('Actions:carMenu', function()
    TriggerClientEvent('Actions:carMenuCl', source)
end)

RegisterServerEvent('Actions:PuxarAct')
AddEventHandler('Actions:PuxarAct', function()
    local nplayer = vRP.getUserSource(nuser_id)
    vRPclient._killGod(nplayer)
	vRPclient._setHealth(nplayer,400)
end)
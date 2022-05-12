local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPjb = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_playerlist",vRPjb)

RegisterServerEvent('abrir:scoreSV')
AddEventHandler('abrir:scoreSV', function()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local identity = vRP.getUserIdentity(user_id)
        local nome = identity.name.." "..identity.firstname
        local foto = identity.foto
        local phone = identity.phone
        local register = identity.registration
        local age = identity.age
        local level = math.floor(vRP.expToLevel(vRP.getExp(user_id, "exp", "level")))

        local adm = "membro"
        if vRP.hasPermission(user_id, "adm.perm") then
            adm = "aministrador"
        end

        local players = {}
        local ptable = GetPlayers()
        for _, i in ipairs(ptable) do
            local id = vRP.getUserId(i)
            if id then
                local identidade = vRP.getUserIdentity(id)
                table.insert(players, 
                '<tr><td><div class="xablau"><div class="score-avatar" style="background-image: url('..identidade.foto..');"></div><div class="name">' .. identidade.name.." "..identidade.firstname ..'<br> <span>Online</span></div></div></td><td>breve#0000</td><td style="text-align: center;">'.. id ..'</td></tr>'
                )
            end
        end

        TriggerClientEvent('abrir:scoreCL', source, nome, foto, phone, register, age, level, adm, players)
    end
end)

function vRPjb.changeFoto(foto) 
    local source = source
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    vRP.execute("vRP/update_user_identity", {
        user_id = user_id,
        age = identity.age,
        name = identity.name,
        firstname = identity.firstname,
        carma = identity.carma,
        phone = identity.phone,
        registration = identity.registration,
        foto = foto
    })
end

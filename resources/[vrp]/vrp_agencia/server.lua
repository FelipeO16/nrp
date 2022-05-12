local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPjb = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_agencia",vRPjb)

local cfg = module("cfg/groups")
local groups = cfg.groups

RegisterServerEvent('Agencia:enviarEmpregos')
AddEventHandler('Agencia:enviarEmpregos', function()
    local empregos = {}
    local source = source
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    local level = math.floor(vRP.expToLevel(vRP.getExp(user_id, "exp", "level")))
    for k,v in pairs(groups) do
        local emprego = groups[k]
        if emprego._config and emprego._config.gtype and emprego._config.gtype == "job" and emprego._config.lvl then
            if not emprego._config.whitelist then
                table.insert(empregos, {
                    ['id'] = emprego._config.id,
                    ['job'] = k,
                    ['nome'] = k,
                    ['lvl'] = emprego._config.lvl,
                    ['cash'] = emprego._config.salario,
                    ['requer'] = emprego._config.requerimento,
                    ['descricao'] = emprego._config.descricao,
                    ['img1'] = emprego._imagens.img1,
                    ['img2'] = emprego._imagens.img2,
                    ['img3'] = emprego._imagens.img3,
                    ['img4'] = emprego._imagens.img4,
                    ['img5'] = emprego._imagens.img5
                })
            end
        end
      end
    TriggerClientEvent('Agencia:receberEmpregos', source, empregos, identity.name.." "..identity.firstname, level)
end)

RegisterServerEvent('Agencia:setarEmprego')
AddEventHandler('Agencia:setarEmprego', function(emprego,xp)
    local source = source
    local user_id = vRP.getUserId(source)
    local level = math.floor(vRP.expToLevel(vRP.getExp(user_id, "exp", "level")))
    if tonumber(level) == tonumber(xp) then
        vRP.addUserGroup(user_id, emprego)
        vRPclient._notify(source, "Agora você é um " .. emprego)
    else
        vRPclient._notify(source, "Você não tem level para trabalhar como " .. emprego)
    end
end)
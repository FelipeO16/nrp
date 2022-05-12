local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local cfg = module("cfg/groups")
local groups = cfg.groups

RegisterServerEvent('Salario:EnviarSalario')
AddEventHandler('Salario:EnviarSalario', function()
    local users = vRP.getUsers()
    for _, i in pairs(users) do
        local user_id = vRP.getUserId(i)
        local player = vRP.getUserSource(user_id)
        local user_groups = vRP.getUserGroups(user_id)
        for k,v in pairs(user_groups) do
            local emprego = groups[k]
            if emprego._config and emprego._config.gtype and emprego._config.gtype == "job" then
                local salario = emprego._config.salario
                local data = vRP.getUserDataTable(user_id)
                local servico = data.emServico
                if servico == k then
                    if salario ~= nil and salario > 0 then
                        vRP.giveBankMoney(user_id, salario)
                        vRPclient._notify(player, "Você recebeu seu salário!")
                    end
                end
            end
        end
    end
end)
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local corridas = {}

RegisterServerEvent('Uber:motoristaChegou')
AddEventHandler('Uber:motoristaChegou', function(placa, modelo)
    local source = source
    local user_id = vRP.getUserId(source)
    -- Verifica se você é o motorista
    if corridas[user_id..'-'..source] then
        local player = vRP.getUserSource(corridas[user_id..'-'..source].id_passageiro)
        corridas[user_id..'-'..source].motorista_chegou = true
        vRPclient._notify(player, '[Uber-Central]: Seu uber chegou! Placa: '..placa..', Modelo: '..modelo)
        TriggerClientEvent('Uber:atualizarCorridas', -1, corridas)
    end
end)

RegisterServerEvent('Uber:updateValor')
AddEventHandler('Uber:updateValor', function(valor)
    local source = source
    local user_id = vRP.getUserId(source)
    -- Verifica se você é o motorista
    if corridas[user_id..'-'..source] then
        local player = vRP.getUserSource(corridas[user_id..'-'..source].id_passageiro)
        corridas[user_id..'-'..source].valor_corrida = valor
    end
end)

RegisterCommand('uber',function(source,args,rawCommand)
    local source = source
    local user_id = vRP.getUserId(source)
    local atendido = false
    if user_id then
        local motorista = vRP.index_filter(corridas, function(o) 
            return o.id_passageiro == user_id 
        end)
        if not motorista then
            local users = vRP.getUsers()
            for _,i in pairs(users) do
                local id = vRP.getUserId(i)
                local player = vRP.getUserSource(id)
                local user_groups = vRP.getUserGroups(id)
                for k,v in pairs(user_groups) do
                    if k == "Uber" then
                        async(function()
                            if user_id ~= id then
                                local data = vRP.getUserDataTable(id)
                                if data.emServico == "Uber" then
                                    if not corridas[id..'-'..player] then
                                        local identidade = vRP.getUserIdentity(user_id)
                                        local ok = vRP.request(player, "[Uber-Central]: "..identidade.name.." "..identidade.firstname.." está chamando um uber, você deseja aceitar a corrida?", 60)
                                        if ok then
                                            if not corridas[id..'-'..player] then
                                                if not atendido then
                                                    local identidade = vRP.getUserIdentity(id)
                                                    local motoristaBlip = vRPclient.addBlipToEntity(source, player, 56, 0, "Uber", 0.8)
                                                    local passageiroBlip = vRPclient.addBlipToEntity(player, source, 280, 0, "Passageiro", 0.8)
                                                    atendido = true
                                                    corridas[id..'-'..player] = {
                                                        ['motoristaBlip'] = motoristaBlip,
                                                        ['passageiroBlip'] = passageiroBlip,
                                                        ['id_motorista'] = id,
                                                        ['id_passageiro'] = user_id,
                                                        ['motorista_source'] = player,
                                                        ['passageiro_source'] = source,
                                                        ['motorista_chegou'] = false,
                                                        ['corrida_andamento'] = false,
                                                        ['valor_corrida'] = 0
                                                    }
                                                    vRPclient.setBlipRoute(player, passageiroBlip)
                                                    vRPclient._notify(source, '[Uber-Central]: '..identidade.name..' '..identidade.firstname..' aceitou seu chamado!')
                                                    TriggerClientEvent('Uber:atualizarCorridas', -1, corridas)
                                                else
                                                    vRPclient._notify(player, '[Uber-Central]: Esta chamada já foi atendida!')
                                                end
                                            else
                                                vRPclient._notify(player, '[Uber-Central]: Você já está em uma corrida!')
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        else
            vRPclient._notify(source, "[Uber-Central]: Você já está em uma corrida!")
        end
    end
end)

RegisterCommand('iniciarCorrida',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    local data = vRP.getUserDataTable(user_id)
    if data.emServico == "Uber" then
        if corridas[user_id..'-'..source] then -- Se eu for o motorista
            local motoristaChegou = corridas[user_id..'-'..source].motorista_chegou
            if motoristaChegou then
                local player = vRP.getUserSource(corridas[user_id..'-'..source].id_passageiro)
                vRPclient._notify(player, '[Uber-Central]: Corrida iniciada!')
                corridas[user_id..'-'..source].corrida_andamento = true
                TriggerClientEvent('Uber:atualizarCorridas', -1, corridas)
            end
        end
    end
end)

RegisterCommand('terminarCorrida',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    local data = vRP.getUserDataTable(user_id)
    if data.emServico == "Uber" then -- Se estiver no serviço do uber
        if corridas[user_id..'-'..source] then -- Se for o motorista
            local motoristaChegou = corridas[user_id..'-'..source].motorista_chegou
            local valor = corridas[user_id..'-'..source].valor_corrida

            if motoristaChegou and valor > 0 then
                local id = corridas[user_id..'-'..source].id_passageiro
                local player = vRP.getUserSource(id)
                local ok = vRP.request(player, "[Uber-Central]: Sua corrida terminou, valor a pagar ao motorista: $"..valor, 60)

                if ok then
                    if vRP.tryPayment(id, valor) then
                        vRP.giveMoney(user_id, valor)
                        vRPclient._notify(source, '[Uber-Central]: Você finalizou uma corrida e recebeu: $'..valor)
                        
                        vRPclient.removeBlip(player, corridas[user_id..'-'..source].motoristaBlip)
                        vRPclient.removeBlip(source, corridas[user_id..'-'..source].passageiroBlip)
                        corridas[user_id..'-'..source] = nil

                        -- Dar xp
                        local xp = math.random(1, 5)
                        vRP.varyExp(user_id, "exp", "level", xp)
                        TriggerClientEvent('Uber:resetarCorrida', source, 0)
                    else
                        vRPclient._notify(source, '[Uber-Central]: Ocorreu um erro com o pagamento do passageiro!')
                        vRPclient._notify(player, 'Você não possui dinheiro suficiente!')
                    end
                end

            end

        end
    end
    TriggerClientEvent('Uber:atualizarCorridas', -1, corridas)
end)
 
RegisterCommand('iniciarUber',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    local data = vRP.getUserDataTable(user_id)
    if data.emServico == "Nenhum" then
        if vRP.hasGroup(user_id, "Uber") then
            vRP._updateServico(user_id, "Uber")
            vRPclient._notify(source, '[Uber-Central]: Você entrou em serviço, já pode receber chamadas do APP!')
        end
    end
end)

RegisterCommand('terminarUber',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    local data = vRP.getUserDataTable(user_id)
    if data.emServico == "Uber" then
        if vRP.hasGroup(user_id, "Uber") then
            vRP._updateServico(user_id, "Nenhum")
            vRPclient._notify(source, '[Uber-Central]: Você saiu do APP e não irá mais receber chamadas!')
        end
    end
end)

RegisterCommand('cancelar',function(source,args,rawCommand)
    local source = source
    local user_id = vRP.getUserId(source)

    local motorista = vRP.index_filter(corridas, function(o) 
        return o.id_passageiro == user_id
    end)

    if corridas[user_id..'-'..source] then -- Você é o motorista
        local identidade = vRP.getUserIdentity(user_id)
        local player = vRP.getUserSource(corridas[user_id..'-'..source].id_passageiro)

        vRPclient.removeBlip(player, corridas[user_id..'-'..source].motoristaBlip)
        vRPclient.removeBlip(source, corridas[user_id..'-'..source].passageiroBlip)
        vRPclient._notify(source, "[Uber-Central]: Você cancelou a corrida!")
        vRPclient._notify(player, "[Uber-Central]: "..identidade.name.." "..identidade.firstname.." cancelou a corrida!")
        corridas[user_id..'-'..source] = nil
        TriggerClientEvent('Uber:resetarCorrida', source, 0)
    elseif motorista then -- Você é o passageiro
        local id = corridas[motorista].id_motorista
        local identidade = vRP.getUserIdentity(user_id)
        local player = vRP.getUserSource(corridas[motorista].id_motorista)

        vRPclient.removeBlip(source, corridas[motorista].motoristaBlip)
        vRPclient.removeBlip(player, corridas[motorista].passageiroBlip)
        vRPclient._notify(source, "[Uber-Central]: Você cancelou a corrida!")

        vRPclient._notify(player, "[Uber-Central]: "..identidade.name.." "..identidade.firstname.." cancelou a corrida!")
        corridas[motorista] = nil
        TriggerClientEvent('Uber:resetarCorrida', player, 0)
    end
    TriggerClientEvent('Uber:atualizarCorridas', -1, corridas)
end)


AddEventHandler("vRP:playerLeave", function(user_id, source)
    local motorista = vRP.index_filter(corridas, function(o) 
        return o.id_passageiro == user_id 
    end)
    if motorista then
        local player = vRP.getUserSource(corridas[motorista].id_motorista)
        vRPclient._notify(player, "[Uber-Central]: Ocorreu um problema e a corrida teve que ser cancelada!")
        corridas[motorista] = nil

    elseif corridas[user_id..'-'..source] then
        local player = corridas[user_id..'-'..source].passageiro_source
        vRPclient._notify(player, "[Uber-Central]: Ocorreu um problema e a corrida teve que ser cancelada!")
        corridas[user_id..'-'..source] = nil
    end
    TriggerClientEvent('Uber:atualizarCorridas', -1, corridas)
end)
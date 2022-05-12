local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local cfg = module("vrp_ems", "cfg/config")

local htmlEntities = module("lib/htmlEntities")

vRPjob = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_ems",vRPjob)
Proxy.addInterface("vrp_ems",vRPjob)

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- GARAGEM
----------------------------------------------------------------------------------------------------------------------------------------------------------
exports['GHMattiMySQL']:QueryAsync([[
    CREATE TABLE IF NOT EXISTS garagem_ems(
        id BIGINT(20) NOT NULL AUTO_INCREMENT,
        modelo VARCHAR(255) DEFAULT NULL,
        nome VARCHAR(255) DEFAULT NULL,
        veh_tipo VARCHAR(255) NOT NULL,
        placa VARCHAR(255) DEFAULT NULL,
        quantidade INT(2),
        img text(255),
        CONSTRAINT pk_garagem PRIMARY KEY(id)
    )
]])

Citizen.CreateThread(function()
    vRP.prepare("NL/inserir_veh_ems","INSERT INTO garagem_ems(modelo, nome, veh_tipo, placa, quantidade, img) VALUES(@modelo, @nome, @veh_tipo, @placa, @quantidade, @img)")
    vRP.prepare("NL/selecionar_veh_ems","SELECT * FROM garagem_ems")
    vRP.prepare("NL/selecionar_by_model","SELECT * FROM garagem_ems WHERE modelo = @modelo")
    vRP.prepare("NL/update_estoque_lspd","UPDATE garagem_ems SET quantidade = @quantidade WHERE modelo = @modelo")
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- INIT GARAGEM
----------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    local data = vRP.getSData("ems:init")
    local init = json.decode(data)
    if not init then
        criarGaragem()
        vRP.setSData("ems:init", json.encode(true))
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------------------------------------------------------------------------------------------------
local dp = cfg.ems
local org = cfg.veiculos
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
----------------------------------------------------------------------------------------------------------------------------------------------------------
local chamadaEMS = {}
local chamadas = {
    tempo = function()
        local em_servico = emServico()
        if em_servico >= 1 and em_servico < 5 then
            return 60*1000*2
        elseif em_servico >= 5 then
            return 60*1000*5
        end
    end
}
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
----------------------------------------------------------------------------------------------------------------------------------------------------------
function vRPjob.Permissao()
    local user_id = vRP.getUserId(source)
    return vRP.hasPermission(user_id, "ems.perm")
end

function emServico()
    local emServico = {}
    for _,i in pairs(vRP.getUsers()) do
        local id = vRP.getUserId(i)
        local player = vRP.getUserSource(id)
        local user_groups = vRP.getUserGroups(id)
        for k,v in pairs(user_groups) do
            if k == "EMS" then
                local data = vRP.getUserDataTable(id)
                if data.emServico == "EMS" then
                    emServico[id] = true
                end
            end
        end
    end
    local servico = vRP.table_size(vRP.table_filter(emServico, function(v, k, t) return v end))
    return servico
end

function reviverPlayer(user_id, source)
    local data = vRP.getUserDataTable(user_id)
    if user_id then
        local nplayer = vRPclient.getNearestPlayer(source,10)
        local nuser_id = vRP.getUserId(nplayer)
        if nuser_id then
            if data.emServico == "EMS" then
                vRPclient._playAnim(source,false,{{"amb@medic@standing@tendtodead@base","base"},{"mini@cpr@char_a@cpr_str","cpr_pumpchest"}},true)
                SetTimeout(15000, function()
                    vRPclient._varyHealth(nplayer,400)
                    vRP.updateComa(nuser_id,nplayer,false)
                    vRPclient.playerComaState(nplayer,false)
                    vRPclient._stopAnim(source,false)
                end)
            else
                vRPclient._notify(source,"Não está em coma!")
            end
        else
            vRPclient._notify(source,"Nenhum player próximo!")
        end
    end
end

function chamarEmergencia(user_id,source,msg)
    local atendido = false
    if user_id then
        local in_ocorrencia = vRP.index_filter(chamadaEMS, function(o) 
            return o.id_player == user_id 
        end)
        if not in_ocorrencia then
            for _,i in pairs(vRP.getUsers()) do
                local id = vRP.getUserId(i)
                local player = vRP.getUserSource(id)
                local user_groups = vRP.getUserGroups(id)
                for k,v in pairs(user_groups) do
                    if k == "EMS" then
                        async(function()
                            if user_id ~= id then
                                local x,y,z = vRPclient.getPosition(source)
                                local data = vRP.getUserDataTable(id)
                                if data.emServico == "EMS" then
                                    if not chamadaEMS[id..'-'..player] then
                                        local identidade = vRP.getUserIdentity(user_id)
                                        if msg then
                                            local ok = vRP.request(player, "[Hospital-Central]: "..identidade.name.." está solicitando uma ambulancia, motivo: "..htmlEntities.encode(msg), 60)
                                            if ok then
                                                if not chamadaEMS[id..'-'..player] then
                                                    if not atendido then
                                                        atendido = true
                                                        local bid = vRPclient.addBlip(player,x,y,z,153,1, "Paciente")
                                                        vRPclient.setGPS(player,x,y)
                                                        chamadaEMS[id..'-'..player] = {
                                                            ['id_blip'] = bid,
                                                            ['id_policial'] = id,
                                                            ['id_player'] = user_id
                                                        }
                                                        print(chamadas.tempo())
                                                        SetTimeout(chamadas.tempo(),function()
                                                            if bid then
                                                                vRPclient._removeBlip(player,bid)
                                                                chamadaEMS[id..'-'..player] = nil
                                                            end
                                                        end)

                                                        vRPclient._notify(source, '[Hospital-Central]: Uma ambulancia está a caminho!')
                                                    else
                                                        vRPclient._notify(player, '[Hospital-Central]: Esta chamada já foi atendida!')
                                                    end
                                                else
                                                    vRPclient._notify(player, '[Hospital-Central] Você já está em um chamado!')
                                                end
                                            end
                                        else
                                            vRPclient._notify(source, '[Hospital-Central]: Digite o motivo da chamada!')
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        else
            vRPclient._notify(source, '[Hospital-Central]: Você já possui um chamado em aberto!')
        end
    end
end

function criarGaragem()
    local rows = vRP.query("NL/selecionar_veh_ems")
    for k,v in pairs(org) do
        if #rows == 0 then
            for l,w in pairs(v) do
                vRP.execute("NL/inserir_veh_ems", {
                    ["modelo"] = w.modelo,
                    ["nome"] = w.nome,
                    ["veh_tipo"] = w.tipo,
                    ["placa"] = "NL-LSPD",
                    ["quantidade"] = w.quantidade,
                    ["img"] = w.img
                })
            end
        end
    end
    return false
end

RegisterServerEvent('Emergencia:EnviarCarros')
AddEventHandler('Emergencia:EnviarCarros', function()
    local veiculos = {}
    local source = source
    local user_id = vRP.getUserId(source)
    local veh = vRP.query("NL/selecionar_veh_ems")
    for i=1, #veh, 1 do
        table.insert(veiculos, {
            ["id"] = veh[i].id,
            ["modelo"] = veh[i].modelo,
            ["nome"] = veh[i].nome,
            ["veh_tipo"] = veh[i].veh_tipo,
            ["placa"] = veh[i].placa,
            ["quantidade"] = veh[i].quantidade,
            ["img"] = veh[i].img
        })
    end
    TriggerClientEvent('Emergencia:ReceberCarros', source, veiculos)
end)

RegisterServerEvent('Emergencia:EntrarServico')
AddEventHandler('Emergencia:EntrarServico', function()
    local player = source
    local user_id = vRP.getUserId(player)
    local data = vRP.getUserDataTable(user_id)
    local old_custom = vRPclient.getCustomization(player)
    local vida = vRPclient.getHealth(player)
    local users = vRP.getUsers()
    if data.emServico == "Nenhum" then
        for k,v in pairs(dp) do
            local idle_copy = {}
            local servico = dp[k].servico
            local uniforme = servico.uniforme
            if old_custom.modelhash == 1885233650 then
                if not data.cloakroom_idle then
                    idle_copy = vRP.save_idle_custom(player, old_custom)
                end
                
                for l,w in pairs(uniforme["mp_m_freemode_01"]) do
                    idle_copy[l] = w
                end

                vRPclient._setCustomization(player, idle_copy)
                SetTimeout(1000, function()
                    vRPclient.setHealth(player, data.health)
                end)
            else
                if not data.cloakroom_idle then
                    idle_copy = vRP.save_idle_custom(player, old_custom)
                end
                
                for l,w in pairs(uniforme["mp_f_freemode_01"]) do
                    idle_copy[l] = w
                end

                vRPclient._setCustomization(player, idle_copy)
                SetTimeout(1000, function()
                    vRPclient.setHealth(player, data.health)
                end)
            end
        end
        
        vRP._updateServico(user_id, "EMS")
        vRPclient._notify(player, "Você entrou em serviço!")
    else
        vRP._updateServico(user_id, "Nenhum")
        vRP.removeCloak(player)
        SetTimeout(1000, function()
            vRPclient.setHealth(player,data.health)
        end)
        vRPclient._notify(player, "Você saiu do serviço!")
    end
end)

RegisterServerEvent('Emergencia:AtualizarEstoque')
AddEventHandler('Emergencia:AtualizarEstoque', function(veh)
    local source = source
    local user_id = vRP.getUserId(source)
    local rows = vRP.query("NL/selecionar_by_model", {modelo = veh})
    if #rows > 0 then
        local veiculo = rows[1]
        local quantidade = veiculo.quantidade
        quantidade = quantidade - 1
        vRP.execute("NL/update_estoque_lspd", {modelo = veh, quantidade = quantidade})
    end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMANDOS
----------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("ems", function(source,args,rawCommand)
    local servico = emServico()
    vRPclient._notify(source, "Médicos em serviço: "..servico)
end)

RegisterCommand("192", function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if user_id then
        if args[1] then
            local msg = table.concat(args, " ")
            chamarEmergencia(user_id, source, msg)
        else
            vRPclient._notify(source, "Use /192 mensagem")
        end
    end
end)

RegisterCommand("rv", function(source,args,rawCommand)
	if not vRPclient.isHandcuffed(player) then
		local user_id = vRP.getUserId(source)
		reviverPlayer(user_id, source)
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id, source)
    local data = vRP.getUserDataTable(user_id)
    if data.emServico == "EMS" then
        vRP.updateServico(user_id, "Nenhum")
    end
end)
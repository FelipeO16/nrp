local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local cfg = module("vrp_cet", "cfg/config")

vRPct = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
CTclient = Tunnel.getInterface("vrp_cet")
GNclient = Tunnel.getInterface("vrp_garagem")
Tunnel.bindInterface("vrp_cet", vRPct)
Proxy.addInterface("vrp_cet", vRPct)

-- vRP
-- exports['ghmattimysql']:QueryAsync([[
--     CREATE TABLE IF NOT EXISTS vrp_cet(
--         id INTEGER AUTO_INCREMENT,
--         dono INTEGER,
--         dono_nome VARCHAR(255),
--         modelo VARCHAR(255),
--         placa VARCHAR(20),
--         valor INTEGER,
--         slot INTEGER,
--         CONSTRAINT pk_cet PRIMARY KEY(id)
--     )
-- ]])

vRP._prepare("NL/inserir_apreensao",
             "INSERT INTO vrp_cet(dono, dono_nome, modelo, placa, valor, slot) VALUES(@dono, @dono_nome, @modelo, @placa, @valor, @slot)")
vRP._prepare("NL/get_apreendidos", "SELECT * FROM vrp_cet")
vRP._prepare("NL/remover_apreensao", "DELETE FROM vrp_cet WHERE slot = @slot")

Citizen.CreateThread(function() carregarApreendidos() end)

local spawn_veh = false
local vagas = cfg.vagas
local retirar = {}
local categoria = {a = 1000, b = 2000, c = 3500}

function updateTable(t1, t2) for k, v in pairs(t2) do t1[k] = v end end

function vagaVazia()
    for k, v in pairs(vagas) do if not v.ocupado then return k end end
    return nil
end

function carregarApreendidos()
    local Svagas = vRP.query('NL/get_apreendidos')
    for k, v in pairs(Svagas) do
        vagas[v.slot].ocupado = true
        updateTable(vagas[v.slot], v)
    end
end

function vRPct.entrarApreendido(k) retirar[source] = k end

function vRPct.sairApreendido(k) retirar[source] = nil end

function spawnarCarro(user_id, veiculo)
    if user_id then
        local player = vRP.getUserSource(user_id)
        local rows = vRP.query("vRP/selecionar_veh_placa",
                               {placa = veiculo.placa})
        if rows then
            local custom = json.decode(rows[1].custom)
            TriggerClientEvent("CET:spawnVeiculo", player, custom, veiculo)
        end
    end
end

function spawnPatio(user_id)
    for k, v in pairs(vagas) do
        if v.ocupado then
            local placa, veh, player = getVehicleProximity(1000000000)
            if not placa then
                SetTimeout(1000, function()
                    spawnarCarro(user_id, v)
                    spawn_veh = true
                end)
            end
        end
    end
end

RegisterCommand('apreender', function(player, choice)
    if not vRPclient.isHandcuffed(player) then
        local k = vagaVazia()
        if type(k) ~= 'nil' then
            local user_id = vRP.getUserId(player)
            local data = vRP.getUserDataTable(user_id)
            if vRP.hasGroup(user_id, "CET") then
                local placa, modelo, veh =
                    vRPclient.getVehicleAtRaycast(player, 1)
                if placa then
                    local rows = vRP.query("vRP/selecionar_veh_placa",
                                           {placa = placa})
                    if #rows > 0 then
                        print("Aqui", rows[1].user_id, rows[1].placa,
                              rows[1].tipo)
                        local id = rows[1].user_id
                        if id then
                            print("ID: " .. id)
                            local a_venda =
                                vRP.query("NL/get_venda_by_placa",
                                          {placa = placa})
                            if #a_venda <= 0 then
                                local identidade = vRP.getUserIdentity(id)
                                local Svagas = vRP.query('NL/get_apreendidos')
                                local apreendido =
                                    vRP.index_filter(Svagas, function(o)
                                        local placa1 = o.placa
                                        return
                                            (placa:gsub("%s+", "") ==
                                                placa1:gsub("%s+", ""))
                                    end)
                                if not apreendido then
                                    local valor = vRP.prompt(player,
                                                             "Digite a categoria da multa",
                                                             "")
                                    local final = tostring(valor)
                                    if categoria[final] then

                                        local veiculo = {
                                            ['dono'] = id,
                                            ['dono_nome'] = identidade.name ..
                                                " " .. identidade.firstname,
                                            ['telefone'] = identidade.phone,
                                            ['modelo'] = modelo,
                                            ['valor'] = categoria[final],
                                            ['slot'] = k,
                                            ['placa'] = rows[1].placa
                                        }

                                        vRP.execute("NL/inserir_apreensao",
                                                    veiculo)

                                        vagas[k].ocupado = true

                                        updateTable(vagas[k], veiculo)

                                        TriggerClientEvent("CET:setApreendido",
                                                           -1, vagas)

                                        --[[ for uid,src in pairs(vRP.getUsers()) do
											CTclient.setApreendido(src, vagas)
										end ]]

                                        local carros =
                                            json.decode(vRP.getSData(
                                                            "apreendido:u" .. id))
                                        if not carros then
                                            carros = {}
                                        end
                                        carros[modelo] = true
                                        vRP.setSData("apreendido:u" .. id,
                                                     json.encode(carros))
                                        print("Id: " .. id,
                                              "Player: " .. player,
                                              "Veh: " .. veh)
                                        -- Deleta o veiculo
                                        TriggerClientEvent("deletarveiculo",
                                                           player, veh)
                                        -- Spawna o carro
                                        spawnarCarro(user_id, veiculo)
                                        -- Notify
                                        vRPclient._notify(player,
                                                          "[Pátio] Veiculo apreendido com sucesso!")
                                    else
                                        vRPclient._notify(player,
                                                          "[Pátio] Essa categoria não existe!")
                                    end
                                else
                                    vRPclient._notify(player,
                                                      "[Pátio] Esse veiculo já está apreendido")
                                end
                            else
                                vRPclient._notify(player,
                                                  "[Pátio] Não é possivel apreender esse veiculo!")
                            end
                        end
                    end
                else
                    vRPclient._notify(player,
                                      "Não existe nenhum veiculo proximo")
                end
            else
                vRPclient._notify(player, "Você não tem permissão!")
            end
        else
            vRPclient._notify(player, "[Pátio] Já está cheio!")
        end
    end
end)

RegisterCommand('retirar', function(player, choice)
    if not vRPclient.isHandcuffed(player) then
        if type(retirar[player]) ~= 'nil' then
            local k = retirar[player]
            local user_id = vRP.getUserId(player)
            local id_dono = vagas[k].dono
            local modelo_db = vagas[k].modelo
            local valor = vagas[k].valor
            if user_id == id_dono then
                if vRP.tryPayment(user_id, valor) then

                    local placa, modelo, veh =
                        vRPclient.getVehiclePedUsing(player)
                    vRP.execute("NL/remover_apreensao", {slot = k})
                    vagas[k].ocupado = false

                    --[[ for uid,src in pairs(vRP.getUsers()) do
						CTclient.setApreendido(src, vagas)
					end ]]

                    TriggerClientEvent("CET:setApreendido", -1, vagas)

                    TriggerClientEvent("CET:LiberarVeh", player, veh)

                    vRPclient._notify(player,
                                      "[Pátio] Você pagou: $" .. valor ..
                                          " e seu veiculo foi liberado!")
                    local apreendido = json.decode(vRP.getSData(
                                                       "apreendido:u" .. id_dono))
                    apreendido[string.lower(modelo_db)] = nil
                    vRP.setSData("apreendido:u" .. id_dono,
                                 json.encode(apreendido))
                else
                    vRPclient._notify(player,
                                      "[Pátio] Você não possui dinheiro suficiente!")
                end
            else
                vRPclient._notify(player,
                                  "[Pátio] Este veiculo não pertence a você!")
            end
        end
    end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    if user_id then
        --[[ for uid,src in pairs(vRP.getUsers()) do
            CTclient.setApreendido(src, vagas)
        end ]]

        TriggerClientEvent("CET:setApreendido", -1, vagas)

        if not spawn_veh then
            spawnPatio(user_id)
        else
            local onlinePlayers = GetNumPlayerIndices()
            if onlinePlayers <= 1 then spawnPatio(user_id) end
        end
    end
end)

function getVehicleProximity(radius)
    local users = vRP.getUsers()
    for uid, src in pairs(vRP.getUsers()) do
        local placa, modelo, veh = vRPclient.getVehicleAtRaycast(src, radius)
        if placa then

            local Svagas = vRP.query('NL/get_apreendidos')
            local apreendido = vRP.index_filter(Svagas, function(o)
                local placa1 = o.placa
                return (placa:gsub("%s+", "") == placa1:gsub("%s+", ""))
            end)

            if apreendido then return placa, veh, src end

        end
    end
end

function stringsplit(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {};
    i = 1
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

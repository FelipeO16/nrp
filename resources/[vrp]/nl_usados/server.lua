local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local cfg = module("nl_usados", "cfg/config")

vRPvd = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
VDclient = Tunnel.getInterface("nl_usados")
Tunnel.bindInterface("nl_usados", vRPvd)
Proxy.addInterface("nl_usados", vRPvd)

-- vRP
exports['ghmattimysql']:QueryAsync([[
    CREATE TABLE IF NOT EXISTS nl_usados(
        id INTEGER AUTO_INCREMENT,
        dono INTEGER,
        dono_nome VARCHAR(255),
        telefone VARCHAR(20),
        modelo VARCHAR(255),
        placa VARCHAR(20),
        preco INTEGER,
        slot INTEGER,
        CONSTRAINT pk_vendas PRIMARY KEY(id)
    )
]])

vRP._prepare("NL/inserir_venda",
             "INSERT INTO nl_usados(dono, dono_nome, telefone, modelo, placa, preco, slot) VALUES(@dono, @dono_nome, @telefone, @modelo, @placa, @preco, @slot)")
vRP._prepare("NL/get_venda", "SELECT * FROM nl_usados WHERE dono = @dono")
vRP._prepare("NL/get_vendas", "SELECT * FROM nl_usados")

vRP._prepare("NL/get_venda_by_placa",
             "SELECT * FROM nl_usados WHERE placa = @placa") -- Seleciona o veiculo apreendido pela placa

vRP._prepare("NL/remover_venda", "DELETE FROM nl_usados WHERE slot = @slot")
vRP._prepare("NL/mover_veiculo",
             "UPDATE vrp_user_vehicles SET user_id = @tuser_id WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("NL/get_dinheiro",
             "SELECT bank FROM vrp_user_moneys WHERE user_id = @user_id")
vRP._prepare("NL/set_banco",
             "UPDATE vrp_user_moneys SET bank = @bank WHERE user_id = @user_id")

Citizen.CreateThread(function() vRPvd.carregarVendas() end)

local vendas = cfg.vendas
local comprador = {}
local spawn_veh = false

function updateTable(t1, t2) for k, v in pairs(t2) do t1[k] = v end end

function vRPvd.carregarVendas()
    local Svendas = vRP.query('NL/get_vendas')
    for k, v in pairs(Svendas) do
        vendas[v.slot].ocupado = true
        updateTable(vendas[v.slot], v)
    end
end

-- Function para spawnar o carro
function spawnarCarro(user_id, veiculo)
    if user_id then
        local player = vRP.getUserSource(user_id)
        local rows = vRP.query("vRP/selecionar_veh_placa",
                               {placa = veiculo.placa})
        if rows then
            local custom = json.decode(rows[1].custom)
            TriggerClientEvent("Usados:spawnVeiculo", player, custom, veiculo)
        end
    end
end

function spawnVenda(user_id)
    for k, v in pairs(vendas) do
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

-- Function para colocar o carro a venda
function vRPvd.colocarVenda(k)
    local source = source
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    local verificar_possui = vRP.query("NL/get_venda", {dono = user_id})
    if #verificar_possui < cfg.limite_venda then

        local placa, modelo, veh = vRPclient.getVehiclePedUsing(source)
        if veh then
            local dono = vRP.query("vRP/get_veh_by_plate",
                                   {user_id = user_id, placa = placa})
            if #dono > 0 then
                local amount = vRP.prompt(source,
                                          "Preço que você quer colocar o veiculo a venda",
                                          "")
                local valor = parseInt(amount)
                if valor > 0 then
                    local ok = vRP.request(source,
                                           "Você tem certeza que quer colocar seu carro a venda por <b>$" ..
                                               valor .. "</b> ?", 60)
                    if ok then

                        local veiculo = {
                            ['dono'] = user_id,
                            ['dono_nome'] = identity.name .. " " ..
                                identity.firstname,
                            ['telefone'] = identity.phone,
                            ['modelo'] = modelo,
                            ['preco'] = valor,
                            ['slot'] = k,
                            ['placa'] = placa
                        }

                        vRP.execute("NL/inserir_venda", veiculo)

                        vendas[k].ocupado = true

                        updateTable(vendas[k], veiculo)

                        TriggerClientEvent("Usados:setVendas", -1, vendas)

                        --[[ for uid,src in pairs(vRP.getUsers()) do
                            VDclient.setVendas(src, vendas)
                        end ]]

                        -- Seta a venda
                        local a_venda = json.decode(
                                            vRP.getSData("a_venda:u" .. user_id))
                        if not a_venda then a_venda = {} end
                        a_venda[modelo] = true
                        vRP.setSData("a_venda:u" .. user_id,
                                     json.encode(a_venda))
                        -- Deleta o veiculo
                        TriggerClientEvent("deletarveiculo", source, veh)
                        -- Spawna o carro
                        spawnarCarro(user_id, veiculo)
                        -- Notify
                        vRPclient._notify(source, "Seu veiculo está a venda!")
                    end
                else
                    vRPclient._notify(source, "Valor inválido!")
                end
            else
                vRPclient._notify(source, "Este veiculo não pertence a você!")
            end

        else
            vRPclient._notify(source, "Você precisa estar em um veiculo!")
        end
    else
        vRPclient._notify(source, "Você já possui 2 veiculos a venda!")
    end
end

function vRPvd.entrarVenda(k) comprador[source] = k end

function vRPvd.sairVenda(k) comprador[source] = nil end

-- Comando chat
RegisterCommand('comprar', function(player, choice)
    if type(comprador[player]) ~= 'nil' then
        local k = comprador[player]
        local tuser_id = vRP.getUserId(player)
        local id_dono = vendas[k].dono
        local preco_db = vendas[k].preco
        local modelo_db = vendas[k].modelo
        local online = vRP.getUserSource(id_dono)
        if tuser_id ~= id_dono then

            local veiculos = vRP.query('vRP/get_vehicles', {user_id = tuser_id})

            local possui = vRP.index_filter(veiculos, function(o)
                return (o.vehicle == modelo_db)
            end)

            if not possui then
                if vRP.tryPayment(tuser_id, preco_db) then
                    vendas[k].ocupado = false

                    --[[ for uid,src in pairs(vRP.getUsers()) do
                        VDclient.setVendas(src, vendas)
                    end ]]

                    TriggerClientEvent("Usados:setVendas", -1, vendas)

                    -- Seta o veiculo para player
                    vRP.execute('NL/mover_veiculo', {
                        user_id = id_dono,
                        tuser_id = tuser_id,
                        vehicle = modelo_db
                    })
                    vRP.execute('NL/remover_venda', {slot = k})
                    if online then
                        local banco = vRP.getBankMoney(id_dono)
                        vRP.setBankMoney(id_dono, preco_db + tonumber(banco))
                        vRPclient._notify(online,
                                          "[Loja de Usados] Seu veiculo foi vendido!")
                    else
                        local bank = vRP.scalar('NL/get_dinheiro',
                                                {user_id = id_dono})
                        vRP.execute('NL/set_banco', {
                            user_id = id_dono,
                            bank = preco_db + tonumber(bank)
                        })
                    end

                    TriggerClientEvent("Usados:LiberarVeh", player, modelo_db)
                    vRPclient._notify(player, "Veiculo comprado com sucesso!")

                    local a_venda = json.decode(
                                        vRP.getSData("a_venda:u" .. id_dono))
                    a_venda[string.lower(modelo_db)] = nil
                    vRP.setSData("a_venda:u" .. id_dono, json.encode(a_venda))
                else
                    vRPclient._notify(player, "Dinheiro insuficiente!")
                end
            else
                vRPclient._notify(player,
                                  "Você já possui um veiculo desse modelo!")
            end
        else
            vRPclient._notify(player, "Este veiculo pertence a você!")
        end
    end
end)

RegisterCommand('remover', function(player, choice)
    if type(comprador[player]) ~= 'nil' then
        -- Remover
        local k = comprador[player]
        local user_id = vRP.getUserId(player)
        local id_dono = vendas[k].dono
        local modelo_db = vendas[k].modelo
        if user_id == id_dono then

            local placa, modelo, veh = vRPclient.getVehiclePedUsing(player)
            vRP.execute("NL/remover_venda", {slot = k})
            vendas[k].ocupado = false

            --[[ for uid,src in pairs(vRP.getUsers()) do
                VDclient.setVendas(src, vendas)
            end ]]

            TriggerClientEvent("Usados:setVendas", -1, vendas)

            TriggerClientEvent("Usados:LiberarVeh", player, veh)
            vRPclient._notify(player, "Veiculo retirado com sucesso!")

            local a_venda = json.decode(vRP.getSData("a_venda:u" .. id_dono))
            a_venda[string.lower(modelo_db)] = nil
            vRP.setSData("a_venda:u" .. id_dono, json.encode(a_venda))
        else
            vRPclient._notify(player, "Este veiculo não pertence a você!")
        end
    end
end)

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    if user_id then

        --[[ for uid,src in pairs(vRP.getUsers()) do
            VDclient.setVendas(src, vendas)
        end ]]

        TriggerClientEvent("Usados:setVendas", -1, vendas)

        if not spawn_veh then
            spawnVenda(user_id)
        else
            local onlinePlayers = GetNumPlayerIndices()
            if onlinePlayers <= 1 then spawnVenda(user_id) end
        end
    end
end)

function getVehicleProximity(radius)
    local users = vRP.getUsers()
    for uid, src in pairs(vRP.getUsers()) do
        local placa, modelo, veh = vRPclient.getVehicleAtRaycast(src, radius)
        if placa then

            local Svendas = vRP.query('NL/get_vendas')
            local a_venda = vRP.index_filter(Svendas, function(o)
                local placa1 = o.placa
                return (placa:gsub("%s+", "") == placa1:gsub("%s+", ""))
            end)

            if a_venda then return placa, veh, src end

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

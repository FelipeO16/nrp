local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local cfg = module("vrp_gunshop", "cfg/config")

vRPnui = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_gunshop", vRPnui)
Proxy.addInterface("vrp_gunshop", vRPnui)

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

exports['ghmattimysql']:QueryAsync([[
    CREATE TABLE IF NOT EXISTS vrp_gunshop(
        id int(11) NOT NULL AUTO_INCREMENT,
        id_dono int(11) DEFAULT NULL,
        nome VARCHAR(255) DEFAULT NULL,
        preco INTEGER DEFAULT NULL,
        a_venda BOOLEAN DEFAULT NULL,
        estoque TEXT,
        cofre INTEGER,
        cofreLimite INTEGER,
        CONSTRAINT pk_gunshop PRIMARY KEY(id)
    )
]])

vRP._prepare("NL/inserir_gunshops",
             "INSERT INTO vrp_gunshop(id_dono, nome, preco, a_venda, estoque, cofre, cofreLimite) VALUES(@id_dono, @nome, @preco, @a_venda, @estoque, @cofre, @cofreLimite)")
vRP._prepare("NL/set_quantidade",
             "UPDATE vrp_gunshop SET quantidade = @quantidade WHERE id = @id")
vRP._prepare("NL/get_estoque_gunshop",
             "SELECT estoque FROM vrp_gunshop WHERE nome = @nome")
vRP._prepare("NL/set_estoque",
             "UPDATE vrp_gunshop SET estoque = @estoque WHERE nome = @nome")
vRP._prepare("NL/get_cofre", "SELECT cofre FROM vrp_gunshop WHERE nome = @nome")
vRP._prepare("NL/set_cofre",
             "UPDATE vrp_gunshop SET cofre = @cofre WHERE nome = @nome")
vRP._prepare("NL/comprar_loja",
             "UPDATE vrp_gunshop SET id_dono = @id_dono, a_venda = @a_venda WHERE nome = @nome")
vRP._prepare("NL/selecionar_loja_arma", "SELECT * FROM vrp_gunshop")
vRP._prepare("NL/selecionar_loja_arma_nome",
             "SELECT * FROM vrp_gunshop WHERE nome = @nome")

Citizen.CreateThread(function() criarArmas() end)

local gunshop = cfg.gunshop

function getEstoque(nome)
    local rows = vRP.query("NL/get_estoque_gunshop", {nome = nome})
    if #rows > 0 then
        return json.decode(rows[1].estoque)
    else
        return {}
    end
end

function setEstoque(nome, estoque)
    vRP.execute("NL/set_estoque", {nome = nome, estoque = json.encode(estoque)})
end

function getCofre(nome)
    local rows = vRP.query("NL/get_cofre", {nome = nome})
    if #rows > 0 then
        return json.decode(rows[1].cofre)
    else
        return {}
    end
end

function setCofre(nome, cofre)
    vRP.execute("NL/set_cofre", {nome = nome, cofre = json.encode(cofre)})
    enviarLojas()
end

function criarArmas()
    local rows = vRP.query("NL/selecionar_loja_arma")
    for k, v in pairs(gunshop) do
        if #rows == 0 then
            vRP.execute("NL/inserir_gunshops", {
                ['id_dono'] = 0,
                ['nome'] = k,
                ['preco'] = v.preco,
                ['a_venda'] = v.a_venda,
                ['estoque'] = json.encode(v.estoque),
                ['cofre'] = 0,
                ['cofreLimite'] = v.cofre.limite
            })
        end
    end
    return false
end

function enviarLojas()
    local lojas = {}
    local rows = vRP.query("NL/selecionar_loja_arma")
    for k, v in pairs(rows) do lojas[v.nome] = v end
    TriggerClientEvent('Gunshop:receberLojas', -1, lojas)
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

RegisterServerEvent('Gunshop:EnviarArmas')
AddEventHandler('Gunshop:EnviarArmas', function(nome)
    local loja = {}
    local source = source
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    local data = getEstoque(nome)
    for k, v in pairs(data) do
        loja[k] = {
            ['nomeLoja'] = nome,
            ['modelo'] = v.nome,
            ['preco'] = v.preco,
            ['img'] = v.img,
            ['descricao'] = v.descricao,
            ['quantidade'] = v.quantidade
        }
    end
    TriggerClientEvent('Gunshop:ReceberArmas', source, loja)
end)

RegisterServerEvent('Gunshop:comprarArma')
AddEventHandler('Gunshop:comprarArma', function(loja, arma)
    local source = source
    local user_id = vRP.getUserId(source)
    local estoque = getEstoque(loja)
    local cofre = getCofre(loja)
    local rows = vRP.query("NL/selecionar_loja_arma_nome", {nome = loja})
    local weapon = stringsplit(arma, ",")
    for k, v in pairs(weapon) do
        if estoque[v].quantidade > 0 then
            local preco = estoque[v].preco
            if ((vRP.getInventoryWeight(user_id) +
                vRP.getItemWeight("wbody|" .. v)) <=
                vRP.getInventoryMaxWeight(user_id)) then

                if vRP.tryPayment(user_id, tonumber(preco)) then

                    vRP.giveInventoryItem(user_id, "wbody|" .. v, 1, true)
                    vRP.giveInventoryItem(user_id, "wammo|" .. v, 250, false)
                    vRPclient._notify(source, "Você comprou uma <b>" ..
                                          estoque[v].nome .. "<b>")

                    estoque[v].quantidade = estoque[v].quantidade - 1
                    setEstoque(loja, estoque)

                    local id_dono = rows[1].id_dono
                    if id_dono ~= 0 then
                        if cofre ~= nil then
                            local dinheiro = {
                                ["dinheiro"] = {
                                    amount = cofre["dinheiro"].amount +
                                        tonumber(preco)
                                }
                            }
                            setCofre(loja, dinheiro)
                        else
                            local dinheiro = {
                                ["dinheiro"] = {amount = tonumber(preco)}
                            }
                            setCofre(loja, dinheiro)
                        end
                    end
                else
                    vRPclient._notify(source,
                                      "Você não tem dinheiro suficiente!")
                end
            else
                vRPclient._notify(source, "Seu inventário está cheio!")
            end
        else
            vRPclient._notify(source, "Sem estoque!")
        end
    end
end)

RegisterServerEvent('Gunshop:retirarDinheiro')
AddEventHandler('Gunshop:retirarDinheiro', function(nome)
    local source = source
    local user_id = vRP.getUserId(source)
    local rows = vRP.query("NL/selecionar_loja_arma_nome", {nome = nome})
    if user_id == rows[1].id_dono then
        if rows[1].cofre > 0 then
            vRP.giveInventoryItem(user_id, "dinheiro", rows[1].cofre)
            setCofre(nome, 0, source)
        end
    end
end)

RegisterServerEvent('Gunshop:comprarLoja')
AddEventHandler('Gunshop:comprarLoja', function(loja, preco)
    local source = source
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    if vRP.tryPayment(user_id, tonumber(preco)) then
        vRP.execute("NL/comprar_loja", {
            ['nome'] = loja,
            ['id_dono'] = user_id,
            ['a_venda'] = false
        })
        enviarLojas()
        vRPclient._notify(source,
                          "Parabéns! Você comprou a Ammunation: " .. loja)
    else
        vRPclient._notify(source, "Você não tem dinheiro suficiente!")
    end
end)

RegisterServerEvent('NUI:ComprarWeapon')
AddEventHandler('NUI:ComprarWeapon',
                function() vRP.giveWeapons(weapons, clear_before) end)

---------------------------------------------------------------------------------------------------------------------------
-- EVENTOS VRP
---------------------------------------------------------------------------------------------------------------------------
AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    if user_id then
        enviarLojas()
        for uid, src in pairs(vRP.getUsers()) do
            TriggerClientEvent("Gunshop:InserirUsers", source, uid, src)
        end
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id, source)
    for uid, src in pairs(vRP.getUsers()) do
        TriggerClientEvent("Gunshop:RemoverUsers", source, uid)
    end
end)

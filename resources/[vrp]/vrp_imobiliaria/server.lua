local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local cfg = module("cfg/homes")

vRPjb = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_imobiliaria",vRPjb)
Proxy.addInterface("vrp_imobiliaria",vRPjb)

exports['GHMattiMySQL']:QueryAsync([[
    CREATE TABLE IF NOT EXISTS vrp_imobiliaria(
        id int(11) NOT NULL AUTO_INCREMENT,
        nome VARCHAR(255) DEFAULT NULL,
        preco INTEGER DEFAULT NULL,
        img text(255),
        categoria text(255),
        a_venda BOOLEAN DEFAULT NULL,
        CONSTRAINT pk_imobiliaria PRIMARY KEY(id)
    )
]])

vRP._prepare("sRP/inserir_casa","INSERT INTO vrp_imobiliaria(nome, preco, img, categoria, a_venda) VALUES(@nome, @preco, @img, @categoria, @a_venda)")
vRP._prepare("sRP/set_venda","UPDATE vrp_imobiliaria SET a_venda = @a_venda WHERE nome = @nome")
vRP._prepare("sRP/selecionar_casa","SELECT * FROM vrp_imobiliaria")
vRP._prepare("sRP/obter_casa","SELECT * FROM vrp_imobiliaria WHERE nome = @nome")

local casa = cfg.casas
local em_visita = {}

function vRPjb.PermStreamer()
    local user_id = vRP.getUserId(source)
    return vRP.hasPermission(user_id, "streamer.perm")
end

function vRPjb.PermVip()
    local user_id = vRP.getUserId(source)
    return vRP.hasPermission(user_id, "imobiliaria.vip")
end


function criarCasa()
    local rows = vRP.query("sRP/selecionar_casa")
    for k,v in pairs(casa) do
        if #rows == 0 then
            vRP.execute("sRP/inserir_casa", {
                ['nome'] = k,
                ['preco'] = casa[k].preco,
                ['a_venda'] = casa[k].a_venda,
                ['img'] = casa[k].img,
                ['categoria'] = casa[k].categoria,                    
            })
        end
    end
    return false
end

function quantidadeCasa()
    local rows = vRP.query("sRP/selecionar_casa")
    local vendas = vRP.table_size(vRP.table_filter(rows, function(v, k, t) return v.a_venda end))
    return vendas
end

RegisterServerEvent('Imobiliaria:enviarCasasVenda')
AddEventHandler('Imobiliaria:enviarCasasVenda', function()
    local casas = {}
    local source = source
    local quantidade = quantidadeCasa()
    local rows = vRP.query("sRP/selecionar_casa")
    for k,v in pairs(rows) do
        local a_venda = rows[k].a_venda
        if a_venda then
            local id = rows[k].id
            local nome = rows[k].nome
            local preco = rows[k].preco
            local tipoCasa = rows[k].tipoCasa
            local img = rows[k].img
            local categoria = rows[k].categoria
            local localizacao = json.encode(casa[nome].saida)
            table.insert(casas, {
                ["id"] = id,
                ["nome"] = nome,
                ["preco"] = preco,
                ["img"] = img,
                ["categoria"] = categoria,
                ["localizacao"] = localizacao
            })
        end
    end
    TriggerClientEvent('Imobiliaria:receberCasasVenda', source, casas, quantidade)
end)

RegisterServerEvent('Imobiliaria:comprarCasa')
AddEventHandler('Imobiliaria:comprarCasa', function(info)
    local source = source
    local user_id = vRP.getUserId(source)
    local player = vRP.getUserSource(user_id)
    local str = stringsplit(info, ",")
    local nome = str[1]
    local preco = tonumber(str[2])

    if vRP.tryFullPayment(user_id, preco) then
        vRP.execute("sRP/set_venda", {nome = nome, a_venda = false})
        vRPclient._notifyPicture(source, "CHAR_ANTONIA", 9, "Imobiliária", "Atendente Debora", "Parabéns pela conquista, você comprou sua casa!")
        TriggerEvent('Homes:comprarCasa', user_id, nome)
    else
        vRPclient._notifyPicture(source, "CHAR_ANTONIA", 1, "Imobiliária", "Atendente Debora", "Você não possui dinheiro suficiente!")
    end
    
end)

RegisterServerEvent('Imobiliaria:visitarCasas')
AddEventHandler('Imobiliaria:visitarCasas', function(info)
    local user_id = vRP.getUserId(source)
    local source = vRP.getUserSource(user_id)
    local str = stringsplit(info, ",")
    local x,y,z = str[1], str[2], str[3]
    local id = str[4]
    
    if user_id then
        if not em_visita[id] then

            em_visita[id] = {
                ['visita'] = true
            }

            vRPclient._teleport(source, x, y, z)
            vRPclient._notifyPicture(source, "CHAR_ANTONIA", 1, "Imobiliária", "Atendente Debora", "Você tem apenas ~g~1 minuto~w~ de visista")

            SetTimeout(60000, function()
                vRPclient._notifyPicture(source, "CHAR_ANTONIA", 1, "Imobiliária", "Atendente Debora", "Seu tempo de visita acabou!")
                vRPclient._teleport(source, -139.200, -631.850, 168.820)
                em_visita[id] = nil
            end)

        elseif em_visita[id].visita then
            vRPclient._notifyPicture(source, "CHAR_ANTONIA", 1, "Imobiliária", "Atendente Debora", "Já possui uma pessoa visitando essa casa, aguarde!")
        end
    end

end)

function stringsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

Citizen.CreateThread(function() 
    criarCasa()
    quantidadeCasa()
end)
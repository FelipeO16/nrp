local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local cfg = module("vrp_concessionaria", "cfg/config")

vRPc = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
CNclient = Tunnel.getInterface("vrp_concessionaria", "vrp_concessionaria")
Tunnel.bindInterface("vrp_concessionaria", vRPc)
Proxy.addInterface("vrp_concessionaria", vRPc)

vRP._prepare("sRP/concessionaria", [[
    CREATE TABLE IF NOT EXISTS vrp_concessionaria(
        id INTEGER UNIQUE AUTO_INCREMENT,
        modelo VARCHAR(255),
        nome VARCHAR(255),
        preco INTEGER,
        quantidade INTEGER,
        descricao text(255),
        tipo text(255),
        img text(255)
    )
]])

vRP._prepare("sRP/inserir_veh",
             "INSERT INTO vrp_concessionaria(modelo,nome,tipo,preco,quantidade,descricao,img) VALUES(@modelo,@nome,@tipo,@preco,@quantidade,@descricao,@img)")
vRP._prepare("sRP/set_quantidade",
             "UPDATE vrp_concessionaria SET quantidade = @quantidade WHERE modelo = @modelo")
vRP._prepare("sRP/selecionar_veh", "SELECT * FROM vrp_concessionaria")
vRP._prepare("sRP/get_veh_by_nome",
             "SELECT * FROM vrp_concessionaria WHERE modelo = @nome")
vRP._prepare("sRP/get_quantidade",
             "SELECT quantidade FROM vrp_concessionaria WHERE modelo = @modelo")

local cars = {}

async(function() vRP.execute("sRP/concessionaria") end)

local conce = cfg.concessionaria

function vRPc.PermVip()
    local user_id = vRP.getUserId(source)
    return vRP.hasPermission(user_id, "vipconce.perm")
end

function vRPc.PermGroup()
    local user_id = vRP.getUserId(source)
    return vRP.hasPermission(user_id, "pesca.perm")
end

function criarCarros()
    for k, v in pairs(conce) do
        for x, y in pairs(v.estoque) do
            if y.show then
                local rows = vRP.query("sRP/get_veh_by_nome", {nome = x})
                if #rows == 0 then
                    vRP.execute("sRP/inserir_veh", {
                        modelo = x,
                        nome = y.nome,
                        preco = y.precocarro,
                        quantidade = y.quantidade or 500,
                        descricao = y.descricao or "",
                        tipo = y.tipo,
                        img = "http://177.67.83.244/static/veiculos_filadelfia/" ..
                            x .. ".png"
                    })
                end
            end
            if not cars[tostring(x)] then cars[tostring(x)] = y end
            Citizen.Wait(20)
        end
    end
    return false
end

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        for k, v in pairs(conce) do
            for x, y in pairs(v.estoque) do
                vRPclient._registerVehicle(source, x, y.precocarro)
                Citizen.Wait(50)
            end
        end
    end
end)

function vRPc.getCarImage(model)
    return "http://177.67.83.244/static/veiculos_filadelfia/" .. model .. ".png"
end

function vRPc.getCarInfo(model)
    if not cars[tostring(model)] then
        print("Não foi possível obter o carro: " .. model)
    end
    return cars[tostring(model)] or nil
end

RegisterServerEvent('Concessionaria:enviarVeiculos')
AddEventHandler('Concessionaria:enviarVeiculos', function()
    local veiculos = {}
    local garagem = {}
    local source = source
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    local gah = vRP.query("vRP/get_vehicles_by_states",
                          {user_id = user_id, state = false})
    local veh = vRP.query("sRP/selecionar_veh")
    for k, v in pairs(veh) do
        table.insert(veiculos, {
            modelo = v.modelo,
            nome = v.nome,
            valor = v.preco,
            quantidade = v.quantidade,
            descricao = v.descricao,
            tipo = v.tipo,
            img = v.img
        })
    end
    for i = 1, #gah, 1 do
        table.insert(garagem, {
            modelo = gah[i].vehicle,
            nome = gah[i].nome,
            placa = gah[i].placa
        })
    end
    TriggerClientEvent('Concessionaria:receberVeiculos', source, veiculos,
                       garagem, identity.name .. " " .. identity.firstname)
end)

function criarPlaca()
    local generatePlaca
    generatePlaca = "P" .. math.random(10000, 99999)
    local veiculos = vRP.query('vRP/selecionar_veh_placa',
                               {placa = generatePlaca})
    if #veiculos == 0 then
        return generatePlaca
    else
        return criarPlaca()
    end
end

function vRPc.criarPlaca() return criarPlaca() end
RegisterServerEvent('Concessionaria:comprarCarro')
AddEventHandler('Concessionaria:comprarCarro', function(veh)
    local source = source
    local user_id = vRP.getUserId(source)
    local rows = vRP.query("vRP/get_vehicles", {user_id = user_id})
    local maxcars = 3
    if vRP.hasPermission(user_id, "vip.permissao") then maxcars = maxcars + 4 end
    if count(rows) < maxcars then
        local veiculo = cars[tostring(veh)]
        local modelo = veh
        local valor = veiculo.precocarro
        local nome = veiculo.nome
        local tipo = veiculo.tipo
        local imagem =
            "http://177.67.83.244/static/veiculos_filadelfia/" .. veh .. ".png"
        local peso = veiculo.pesocarro
        local rows = vRP.query("sRP/get_quantidade", {modelo = veh})
        local quantidade
        if #rows > 0 then quantidade = rows[1].quantidade end
        local get_veh = vRP.query("vRP/get_vehicle",
                                  {user_id = user_id, vehicle = veh})
        if count(get_veh) <= 0 then
            if quantidade > 0 then
                local generatePlaca = criarPlaca()
                if vRP.tryFullPayment(user_id, valor) then
                    TriggerEvent("whook:sendhook", 10,
                                 tostring(tostring(GetPlayerName(source))) ..
                                     " [" .. user_id .. "]" .. " Pagou:  " ..
                                     tostring(valor) .. " em um " ..
                                     tostring(nome))
                    quantidade = quantidade - 1
                    -- Seta a quantidade atualizada na concessionaria
                    vRP.execute("sRP/set_quantidade",
                                {modelo = veh, quantidade = quantidade})
                    -- Teste
                    -- Spawna o veiculo e seta o blip nele
                    local createVehicle = {
                        ['user_id'] = user_id,
                        ['vehicle'] = modelo,
                        ['nome'] = nome,
                        ['state'] = 0,
                        ['placa'] = generatePlaca,
                        ['img'] = "http://177.67.83.244/static/veiculos_filadelfia/" ..
                            modelo .. ".png",
                        ['tipo'] = tipo,
                        ['motor'] = 1000,
                        ['lataria'] = 1000,
                        ['gasolina'] = 100,
                        ['bau'] = json.encode({}),
                        ['bauLimite'] = peso,
                        ipva = os.time()

                    }
                    local custom = CNclient.spawnVeiculo(source, createVehicle)
                    -- Seta as cores no banco de dados
                    createVehicle["custom"] = json.encode(custom)
                    -- Adiciona o veiculo no banco de dados
                    vRP.execute("vRP/add_vehicle", createVehicle)
                    if vRP.getSData("concessionaria:dono") ~= nil then
                        vRP.setSData("concessionaria:banco", (tonumber(
                                         vRP.getSData("concessionaria:banco")) or
                                         0) + valor * 0.15)
                    end
                    TriggerClientEvent("Notify", source, "sucesso",
                                       "Parabéns, você comprou um <b>" .. nome ..
                                           "</b>,Modelo: " .. modelo ..
                                           ", Placa: " .. generatePlaca)
                else
                    TriggerClientEvent("Notify", source, "negado",
                                       "Você não tem dinheiro suficiente!")
                end
            else
                TriggerClientEvent("Notify", source, "negado", "Sem estoque!")
            end
        else
            TriggerClientEvent("Notify", source, "negado",
                               "Você já possui este veiculo!")
        end
    else
        TriggerClientEvent("Notify", source, "negado",
                           "Sua garagem está lotada!")
    end
end)

RegisterServerEvent('Concessionaria:anunciarVeiculo')
AddEventHandler('Concessionaria:anunciarVeiculo',
                function(veh, nome, tipo, qtd, desc, img)
    local source = source
    local user_id = vRP.getUserId(source)
    vRP.execute("vRP/remove_vehicle", {user_id = user_id, vehicle = veh})
    vRP.execute("sRP/inserir_veh", {
        ['modelo'] = veh,
        ['nome'] = nome,
        ['tipo'] = tipo,
        ['preco'] = qtd,
        ['quantidade'] = 1,
        ['descricao'] = desc,
        ['img'] = img
    })
end)

Citizen.CreateThread(function() criarCarros() end)

RegisterCommand('givecar', function(source, args, rawCommand)
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "adm.perm") then
        local uid = args[1]
        local car = args[2]
        if uid and car then
            -- Spawna o veiculo e seta o blip nele
            local info = vRPc.getCarInfo(car)
            if info then
                local createVehicle = {
                    ['user_id'] = uid,
                    ['vehicle'] = car,
                    ['nome'] = info.nome,
                    ['state'] = 0,
                    ['placa'] = criarPlaca(),
                    ['img'] = "http://177.67.83.244/static/veiculos_filadelfia/" ..
                        car .. ".png",
                    ['tipo'] = info.tipo,
                    ['motor'] = 1000,
                    ['lataria'] = 1000,
                    ['gasolina'] = 100,
                    ['bau'] = json.encode({}),
                    ['bauLimite'] = info.pesocarro,
                    ipva = os.time()

                }
                local custom = CNclient.spawnVeiculo(source, createVehicle)
                -- Seta as cores no banco de dados
                createVehicle["custom"] = json.encode(custom)
                -- Adiciona o veiculo no banco de dados
                vRP.execute("vRP/add_vehicle", createVehicle)
                TriggerClientEvent("Notify", source, "sucesso",
                                   "Você deu o carro " .. car .. " para o ID " ..
                                       uid)
            else
                TriggerClientEvent("Notify", source, "negado",
                                   "Nome do carro invalido")
            end
        else
            TriggerClientEvent("Notify", source, "negado",
                               "Utilize /givecar id carro")
        end
    end
end)

function count(tbl)
    local a = 0
    if type(tbl) == "table" then for k, v in pairs(tbl) do a = a + 1 end end
    return a
end

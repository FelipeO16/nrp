local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local cfg = module("vrp_policia", "cfg/config")

local htmlEntities = module("lib/htmlEntities")

vRPjob = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_policia",vRPjob)
Proxy.addInterface("vrp_policia",vRPjob)

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- GARAGEM
----------------------------------------------------------------------------------------------------------------------------------------------------------
exports['GHMattiMySQL']:QueryAsync([[
    CREATE TABLE IF NOT EXISTS garagem_lspd(
        id BIGINT(20) NOT NULL AUTO_INCREMENT,
        modelo VARCHAR(255) DEFAULT NULL,
        nome VARCHAR(255) DEFAULT NULL,
        veh_tipo VARCHAR(255) NOT NULL,
        placa VARCHAR(255) DEFAULT NULL,
        quantidade INT(2),
        img text(255),
        CONSTRAINT pk_garagem PRIMARY KEY(id)
    );
	
	CREATE TABLE IF NOT EXISTS lspd (
		id INTEGER NOT NULL,
		police_id INTEGER NOT NULL,
		data TEXT NOT NULL,
		timer TIMESTAMP NOT NULL,
		`type` TINYINT NOT NULL
	);
]])

--[[
	LSPD TYPES
	1 = Revista (Sem Apreensão)
	2 = Revista (Com Apreensão)
	3 = Prisões
]]

Citizen.CreateThread(function()
    vRP.prepare("NL/inserir_veh_lspd","INSERT INTO garagem_lspd(modelo, nome, veh_tipo, placa, quantidade, img) VALUES(@modelo, @nome, @veh_tipo, @placa, @quantidade, @img)")
    vRP.prepare("NL/selecionar_veh_lspd","SELECT * FROM garagem_lspd")
    vRP.prepare("NL/selecionar_by_model","SELECT * FROM garagem_lspd WHERE modelo = @modelo")
    vRP.prepare("NL/update_estoque_lspd","UPDATE garagem_lspd SET quantidade = @quantidade WHERE modelo = @modelo")
    vRP.prepare("NL/delete_veh","DELETE FROM garagem_lspd")
	vRP.prepare("NL/send_inspect","INSERT INTO lspd(id, police_id, data, timer, `type`) VALUES (@id, @pid, @data, FROM_UNIXTIME(@timer), @type)")
	vRP.prepare("NL/delete_inspect","DELETE FROM lspd WHERE id = @id AND timer = FROM_UNIXTIME(@timer)")
	vRP.prepare("NL/update_inspect","UPDATE lspd SET `type` = '2' WHERE id = @id AND timer = FROM_UNIXTIME(@timer)")
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- ARSENAL
----------------------------------------------------------------------------------------------------------------------------------------------------------
exports['GHMattiMySQL']:QueryAsync([[
    CREATE TABLE IF NOT EXISTS arsenal_lspd(
        id BIGINT(20) NOT NULL AUTO_INCREMENT,
        modelo VARCHAR(255) DEFAULT NULL,
        nome VARCHAR(255) DEFAULT NULL,
        tipo VARCHAR(255) NOT NULL,
        quantidade INT(2),
        img text(255),
        CONSTRAINT pk_garagem PRIMARY KEY(id)
    )
]])

Citizen.CreateThread(function() 
    vRP.prepare("NL/selecionar_arsenal","SELECT * FROM arsenal_lspd")
    vRP.prepare("NL/selecionar_arma_model","SELECT * FROM arsenal_lspd WHERE modelo = @modelo")
    vRP.prepare("NL/inserir_arsenal","INSERT INTO arsenal_lspd(modelo, nome, tipo, quantidade, img) VALUES(@modelo, @nome, @tipo, @quantidade, @img)")
    vRP.prepare("NL/update_estoque_arma_lspd","UPDATE arsenal_lspd SET quantidade = @quantidade WHERE modelo = @modelo")
    vRP.prepare("NL/delete_arsenal","DELETE FROM arsenal_lspd")
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------------------------------------------------------------------------------------------------
local dp = cfg.policia
local prisao = cfg.prisao
local org = cfg.veiculos
local c4gather = false -- Se colocar true, vai coletar itens quando apreender
local revista_algema = false
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
----------------------------------------------------------------------------------------------------------------------------------------------------------
local preso = {}
local chamadaPolicia = {}
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
-- INIT ARSENAL E GARAGEM
----------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    local data = vRP.getSData("policia:init")
    local init = json.decode(data)
    if not init then
        criarGaragem()
        criarArsenal()
        vRP.setSData("policia:init", json.encode(true))
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
----------------------------------------------------------------------------------------------------------------------------------------------------------
function vRPjob.Permissao()
    local user_id = vRP.getUserId(source)
    return vRP.hasPermission(user_id, "policia.perm")
end

function emServico()
    local emServico = {}
    for _,i in pairs(vRP.getUsers()) do
        local id = vRP.getUserId(i)
        local player = vRP.getUserSource(id)
        local user_groups = vRP.getUserGroups(id)
        for k,v in pairs(user_groups) do
            if k == "LSPD" then
                local data = vRP.getUserDataTable(id)
                if data.emServico == "LSPD" then
                    emServico[id] = true
                end
            end
        end
    end
    local servico = vRP.table_size(vRP.table_filter(emServico, function(v, k, t) return v end))
    return servico
end
  
function chamarPolicia(user_id,source,msg)
    local atendido = false
    if user_id then
        local in_ocorrencia = vRP.index_filter(chamadaPolicia, function(o) 
            return o.id_player == user_id 
        end)
        if not in_ocorrencia then
            for _,i in pairs(vRP.getUsers()) do
                local id = vRP.getUserId(i)
                local player = vRP.getUserSource(id)
                local user_groups = vRP.getUserGroups(id)
                for k,v in pairs(user_groups) do
                    if k == "LSPD" then
                        async(function()
                            if user_id == id then
                                local x,y,z = vRPclient.getPosition(source)
                                local data = vRP.getUserDataTable(id)
                                if data.emServico == "LSPD" then
                                    if not chamadaPolicia[id..'-'..player] then
                                        local identidade = vRP.getUserIdentity(user_id)
                                        if msg then
                                            local ok = vRP.request(player, "[Policia-Central]: "..identidade.name.." está solicitando uma viatura, motivo: "..htmlEntities.encode(msg), 60)
                                            if ok then
                                                if not chamadaPolicia[id..'-'..player] then
                                                    if not atendido then
                                                        atendido = true
                                                        local bid = vRPclient.addBlip(player,x,y,z,304,30, "Ocorrência")
                                                        vRPclient.setGPS(player,x,y)
                                                        chamadaPolicia[id..'-'..player] = {
                                                            ['id_blip'] = bid,
                                                            ['id_policial'] = id,
                                                            ['id_player'] = user_id
                                                        }
                                                        SetTimeout(chamadas.tempo(),function()
                                                            if bid then
                                                                vRPclient._removeBlip(player,bid)
                                                                chamadaPolicia[id..'-'..player] = nil
                                                            end
                                                        end)
                                                        vRPclient._notify(source, '[Policia-Central]: Uma viatura está a caminho!')
                                                    else
                                                        vRPclient._notify(player, '[Policia-Central]: Esta chamada já foi atendida!')
                                                    end
                                                else
                                                    vRPclient._notify(player, '[Policia-Central] Você já está em uma ocorrência')
                                                end
                                            end
                                        else
                                            vRPclient._notify(source, '[Policia-Central]: Digite o motivo da chamada!')
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        else
            vRPclient._notify(source, '[Policia-Central]: Você já possui um chamado em aberto!')
        end
    end
end
  
function cancelarPolicia(user_id, source)
    local player = vRP.index_filter(chamadaPolicia, function(o)
        return o.id_player == user_id
    end)
    if chamadaPolicia[player] then
        local id = chamadaPolicia[player].id_policial
        local playerSource = vRP.getUserSource(chamadaPolicia[player].id_policial)
        vRPclient.removeBlip(playerSource, chamadaPolicia[player].id_blip)
        vRPclient._notify(playerSource, "[Policia-Central]: O cidadão cancelou o chamado!")
        vRPclient._notify(source, "[Policia-Central]: Você cancelou o chamado!")
        chamadaPolicia[player] = nil
    end
end

function criarGaragem()
    local rows = vRP.query("NL/selecionar_veh_lspd")
    for k,v in pairs(org) do
        if #rows == 0 then
            for l,w in pairs(v) do
                vRP.execute("NL/inserir_veh_lspd", {
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

function criarArsenal()
    local rows = vRP.query("NL/selecionar_arsenal")
    for k,v in pairs(dp) do
        if #rows == 0 then
            local arsenal = dp[k].arsenal
            local equipamentos = arsenal.equipamentos
            for l,w in pairs(equipamentos) do
                vRP.execute("NL/inserir_arsenal", {
                    ["modelo"] = l,
                    ["nome"] = w.nome,
                    ["tipo"] = w.tipo,
                    ["quantidade"] = w.quantidade,
                    ["img"] = w.img
                })
            end
        end
    end
    return false
end

function pegarArmaDoJogador(player,arma)
    local armas = vRPclient.getWeapons(player)
    for k,v in pairs(armas) do
        if arma == k then
            return k
        end
    end
    return false
end

function prison_clock(target)
	local player = vRP.getUserSource(target)
	if player then
        SetTimeout(10000,function()
			local value = vRP.getUData(target,"vRP:prisao")
			local tempo = json.decode(value) or 0
            if parseInt(tempo) >= 1 then
                if tempo == 1 then
                    vRPclient._notify(player,"Você ainda vai passar <b>"..parseInt(tempo).." mes</b> preso.")
                else
                    vRPclient._notify(player,"Você ainda vai passar <b>"..parseInt(tempo).." meses</b> preso.")
                end
				vRP.setUData(target,"vRP:prisao",json.encode(parseInt(tempo)-1))
				prison_clock(target)
            elseif parseInt(tempo) == 0 then
                TriggerClientEvent('Polcia:sairPrisao',player)
                TriggerClientEvent('Polcia:Prisioneiro',player,false)
                vRP.setUData(target,"vRP:prisao",json.encode(-1))
				vRPclient._notify(player,"Sua sentença terminou, esperamos não ve-lo novamente.")
            end
            vRP.setHunger(target, 0)
            vRP.setThirst(target, 0)
			vRPclient.killGod(player)
			vRPclient.setHealth(player,400)
		end)
	end
end

function prisaoUniforme(target)
    local idle_copy = {}
    local player = vRP.getUserSource(target)
    local old_custom = vRPclient.getCustomization(player)
    local data = vRP.getUserDataTable(target)
    local uniforme = prisao.uniforme
    if old_custom.modelhash == 1885233650 then
        if not data.cloakroom_idle then
            idle_copy = vRP.save_idle_custom(player, old_custom)
        end
        
        for l,w in pairs(uniforme["mp_m_freemode_01"]) do
            idle_copy[l] = w
        end

        vRPclient._setCustomization(player, idle_copy)
        SetTimeout(1000, function()
            vRPclient.setHealth(player, 400)
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
            vRPclient.setHealth(player, 400)
        end)
    end
end

function removerUniforme(target)
    local player = vRP.getUserSource(target)
    vRP.removeCloak(player)
    SetTimeout(1000, function()
        vRPclient.setHealth(player,400)
    end)
end

function salvarPertences(target)
    local inventario = {}
    for k,v in pairs(vRP.getInventory(target)) do
        inventario[k] = {
            amount=v.amount,
        }
        vRP.tryGetInventoryItem(target,k,v.amount,false) 
    end
    vRP.setUData(target,"vRP:prisao:pertences",json.encode(inventario))
end

function pegarPertences(target)
    local data = vRP.getUData(target,"vRP:prisao:pertences")
    local pertences = json.decode(data)
    for k,v in pairs(pertences) do
        vRP.giveInventoryItem(target,k,v.amount,true)
        vRP.setUData(target,"vRP:prisao:pertences",json.encode({}))
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- EVENTOS
----------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent('Policia:procurarVeiculo')
AddEventHandler('Policia:procurarVeiculo', function(placa)
    local infoVeh = {}
    local source = source
    local user_id = vRP.getUserId(source)
    local rows = vRP.query("vRP/selecionar_veh_placa", {placa = placa})
    if #rows > 0 then
        for k,v in pairs(rows) do
            local id = v.user_id
            local identidade = vRP.getUserIdentity(id)
            local dono = identidade.name..' '..identidade.firstname
            table.insert(infoVeh, {
                ["Situação"] = "Normal"
            })
            TriggerClientEvent("Policia:infoVeh", source, dono, v.placa, v.img)
        end
    else
        vRPclient._notify(source, "[Policia] Esse veiculo não está registrado!")
    end
end)

RegisterServerEvent('Policia:procurarPlayer')
AddEventHandler('Policia:procurarPlayer', function(rg)
    local infoPlayer = {}
    local source = source
    local player = vRP.getUserByRegistration(rg)
    if player then
        local identidade = vRP.getUserIdentity(player)
        table.insert(infoPlayer, {
            ["Pessoa"] = identidade.name..' '..identidade.firstname
        })
        TriggerClientEvent("Policia:infoPlayer", source, identidade.name..' '..identidade.firstname, identidade.foto, identidade.age)
    else
        vRPclient._notify(source, "[Policia] Pessoa não encontrada!")
    end
end)

RegisterServerEvent('Policia:EnviarArsenal')
AddEventHandler('Policia:EnviarArsenal', function()
    local arsenal = {}
    local source = source
    local user_id = vRP.getUserId(source)
    local arsenal = vRP.query("NL/selecionar_arsenal")
    for i=1, #arsenal, 1 do
        table.insert(arsenal, {
            ["id"] = arsenal[i].id,
            ["modelo"] = arsenal[i].modelo,
            ["nome"] = arsenal[i].nome,
            ["tipo"] = arsenal[i].tipo,
            ["quantidade"] = arsenal[i].quantidade,
            ["img"] = arsenal[i].img
        })
    end
    TriggerClientEvent('Policia:ReceberArsenal', source, arsenal)
end)

RegisterServerEvent('Policia:EnviarCarros')
AddEventHandler('Policia:EnviarCarros', function()
    local veiculos = {}
    local source = source
    local user_id = vRP.getUserId(source)
    local veh = vRP.query("NL/selecionar_veh_lspd")
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
    TriggerClientEvent('Policia:ReceberCarros', source, veiculos)
end)

RegisterServerEvent('Policia:EntrarServico')
AddEventHandler('Policia:EntrarServico', function()
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
        
        vRP._updateServico(user_id, "LSPD")
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

RegisterServerEvent('Policia:DevolverArmaArsenal')
AddEventHandler('Policia:DevolverArmaArsenal', function(arma)
    local source = source
    local user_id = vRP.getUserId(source)
    local player = vRP.getUserSource(user_id)
    local rows = vRP.query("NL/selecionar_arma_model", {modelo = arma})
    if #rows > 0 then
        local armaPlayer = pegarArmaDoJogador(player, arma)
        if armaPlayer then
            local armaDB = rows[1]
            local quantidade = armaDB.quantidade
            if quantidade < 99 then
                quantidade = quantidade + 1
                vRPclient._removeWeaponByModel(player, arma)
                vRP.execute("NL/update_estoque_arma_lspd", {modelo = arma, quantidade = quantidade})
                vRPclient._notify(player, "Arma devolvida com sucesso!")
            else
                vRPclient._notify(player, "Estoque dessa arma ja esta cheio")
            end
        else
            vRPclient._notify(player, "Você não possui essa arma equipada!")
        end
    end
end)

RegisterServerEvent('Policia:ReceberArmaArsenal')
AddEventHandler('Policia:ReceberArmaArsenal', function(arma)
    local source = source
    local user_id = vRP.getUserId(source)
    local player = vRP.getUserSource(user_id)
    local weapons = {}
    local rows = vRP.query("NL/selecionar_arma_model", {modelo = arma})
    if #rows > 0 then
        local armaPlayer = pegarArmaDoJogador(player, arma)
        if not armaPlayer then
            local armaDB = rows[1]
            local quantidade = armaDB.quantidade
            weapons[arma] = {ammo = 250}
            vRPclient._giveWeapons(player, weapons)
            quantidade = quantidade - 1
            vRP.execute("NL/update_estoque_arma_lspd", {modelo = arma, quantidade = quantidade})
            vRPclient._notify(player, "Você retirou uma arma do arsenal!")
        else
            vRP.giveInventoryItem(user_id, "wammo|"..arma, 250, true)
        end
    end
end)

RegisterServerEvent('Policia:AtualizarEstoque')
AddEventHandler('Policia:AtualizarEstoque', function(veh, tipo)
    local source = source
    local user_id = vRP.getUserId(source)
    local rows = vRP.query("NL/selecionar_by_model", {modelo = veh})
    if tipo then
        if #rows > 0 then
            --[[ local veiculo = rows[1]
            local quantidade = veiculo.quantidade
            quantidade = quantidade - 1 ]]
            vRP.execute("NL/update_estoque_lspd", {modelo = veh, quantidade = 99})
        end
    else
        if #rows > 0 then
            local veiculo = rows[1]
            local quantidade = veiculo.quantidade
            quantidade = quantidade + 1
            vRP.execute("NL/update_estoque_lspd", {modelo = veh, quantidade = quantidade})
        end
    end
end)

RegisterServerEvent('Policia:AlgemarPlayer')
AddEventHandler('Policia:AlgemarPlayer', function()
    local source = source
    local user_id = vRP.getUserId(source)
    local algemado = vRPclient.isHandcuffed(source)
    if vRP.hasGroup(user_id, "LSPD") then
        if not algemado then
            local nplayer = vRPclient.getNearestPlayer(source,2)
            if nplayer then
                local plyAlgemado = vRPclient.isHandcuffed(nplayer)
                if not plyAlgemado then
                    vRPclient._playAnim(source,false,{{"mp_arrest_paired","cop_p2_back_left"}},false)
                    vRPclient._playAnim(nplayer,false,{{"mp_arrest_paired","crook_p2_back_left"}},false)
                    SetTimeout(3000, function() 
                        vRPclient._toggleHandcuff(nplayer)
                    end)
                    TriggerClientEvent("Policia:Algemar", nplayer, source)
                else
                    vRPclient._toggleHandcuff(nplayer)
                end
            end
        end
    end

end)

RegisterServerEvent('Policia:ArrastarPlayer')
AddEventHandler('Policia:ArrastarPlayer', function()
    local source = source
    local user_id = vRP.getUserId(source)
    local algemado = vRPclient.isHandcuffed(source)
    if vRP.hasGroup(user_id, "LSPD") or vRP.hasGroup(user_id, "EMS") then
        if not algemado then
            local nplayer = vRPclient.getNearestPlayer(source,2)
            if nplayer then
                TriggerClientEvent("Policia:Arrastar", nplayer, source)
            end
        end
	end
end)

RegisterServerEvent('Policia:pegarPertences')
AddEventHandler('Policia:pegarPertences', function()
    local source = source
    local user_id = vRP.getUserId(source)
    vRPclient._notify(source, "Você pegou seus pertences!")
    removerUniforme(user_id)
    pegarPertences(user_id)
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMANDOS
----------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("policia", function(source,args,rawCommand)
	if not vRPclient.isHandcuffed(source) then
		local servico = emServico()
		vRPclient._notify(source, "Policiais em serviço: "..servico)
	end
end)

RegisterCommand("190", function(source,args,rawCommand)
	if not vRPclient.isHandcuffed(source) then
		local user_id = vRP.getUserId(source)
		if user_id then
			if args[1] then
				local msg = table.concat(args, " ")
				chamarPolicia(user_id, source, msg)
			else
				vRPclient._notify(source, "Use /190 mensagem")
			end
		end
	end
end)

RegisterCommand("190c",function(source,args,rawCommand)
	if not vRPclient.isHandcuffed(source) then
		local user_id = vRP.getUserId(source)
		cancelarPolicia(user_id, source)
	end
end)

RegisterCommand('cv',function(source,args,rawCommand)
	if not vRPclient.isHandcuffed(source) then
		local user_id = vRP.getUserId(source)
		local data = vRP.getUserDataTable(user_id)
		if data.emServico == "LSPD" then
			local nplayer = vRPclient.getNearestPlayer(source,3)
			if nplayer then
				vRPclient.putInNearestVehicleAsPassenger(nplayer,4)
			end
		end
	end
end)

RegisterCommand('rv',function(source,args,rawCommand)
	if not vRPclient.isHandcuffed(source) then
		local user_id = vRP.getUserId(source)
		local data = vRP.getUserDataTable(user_id)
		if data.emServico == "LSPD" then
			local nplayer = vRPclient.getNearestPlayer(source,3)
			if nplayer then
				vRPclient.ejectVehicle(nplayer)
			end
		end
	end
end)

RegisterCommand('prender',function(source,args,rawCommand)
	if not vRPclient.isHandcuffed(source) then
		local user_id = vRP.getUserId(source)
		local data = vRP.getUserDataTable(user_id)
		if data.emServico == "LSPD" then
			local id,tempo = parseInt(args[1]),parseInt(args[2])
			if id and tempo then
				local player = vRP.getUserSource(id)
				local algemado = vRPclient.isHandcuffed(player)
				if algemado then
					if tempo > 0 then
						vRP.setUData(id,"vRP:prisao",json.encode(tempo))
						vRPclient.teleport(player,1680.1,2513.0,45.5)
						vRPclient.setHandcuffed(player,false)
						TriggerClientEvent('Polcia:Prisioneiro',player,true)
						salvarPertences(id)
						prisaoUniforme(id)
						prison_clock(id)
					else
						vRPclient._notify(source, "Tempo inválido!")
					end
				else
					vRPclient._notify(source, "O meliante precisa estar algemado!")
				end
			else
				vRPclient._notify(source, "Use /prender id tempo")
			end
		end
	end
end)

local onRevista = {}
RegisterCommand('revistar',function(source,args,rawCommand)
	local rList = {}
	if not vRPclient.isHandcuffed(source) then
		local user_id = vRP.getUserId(source)
		local data = vRP.getUserDataTable(user_id)
		if data.emServico == "LSPD" then
			local user_id = vRP.getUserId(source)
			local nplayer = vRPclient.getNearestPlayer(source,2)
			if nplayer then
				local nuser_id = vRP.getUserId(nplayer)
				if nuser_id then
					local algemado = vRPclient.isHandcuffed(nplayer)
					if algemado and revista_algema then
						local inv = vRP.getInventory(nuser_id)
						for k,v in pairs(inv) do
							if cfg.ilegais[k] then
								table.insert(rList, {k, vRP.getItemName(k), v.amount})
							end
						end
						vRPclient._notify(nplayer, "Você está sendo revistado")
						if #rList > 0 then
							local tm = os.time(os.date("!*t"))
							vRP.execute("NL/send_inspect", {
								id = nuser_id,
								pid = user_id,
								data = json.encode(rList),
								timer = tm,
								type = '1'
							})
							TriggerClientEvent("vrp_policia:FoundItems", source, json.encode(rList), tm, nuser_id)
						else
							vRPclient._notify(source, "Não há itens ilegais")
						end
					else
						vRPclient._notify(source, "O meliante precisa estar algemado!")
					end
				end
			end
		else
			vRPclient._notify(source, "Você precisa estar em serviço.")
		end
	end
end)

RegisterServerEvent('vrp_policia:apagarRegistro')
AddEventHandler('vrp_policia:apagarRegistro', function(id, nuser_id)
	vRP.execute("NL/delete_inspect", {id = nuser_id, timer = id})
end)

RegisterServerEvent('vrp_policia:apreenderRegistro')
AddEventHandler('vrp_policia:apreenderRegistro', function(id, items, nuserid)
	local source = source
	local user_id = vRP.getUserId(source)
	vRP.execute("NL/update_inspect", {id = nuserid, timer = id})
	for k, v in pairs(json.decode(items)) do
		if vRP.tryGetInventoryItem(parseInt(nuserid), v[1], v[3]) then
			if c4gather then vRP.giveInventoryItem(user_id, v[1], v[3]) end
			vRPclient._notify(source, "Você apreendeu "..v[2].." x"..v[3])
		end
	end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------
-- VRP EVENTOS
----------------------------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
	local player = vRP.getUserSource(user_id)
	if player then
		SetTimeout(15000,function()
			local value = vRP.getUData(user_id,"vRP:prisao")
			local tempo = json.decode(value) or 0

			if tempo == -1 then
				return
			end

            if tempo > 0 then
                TriggerClientEvent('Polcia:Prisioneiro',player,true)
				vRPclient.teleport(player,1680.1,2513.0,46.5)
                prison_clock(user_id)
                prisaoUniforme(user_id)
			end
		end)
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id, source)
    local data = vRP.getUserDataTable(user_id)
    if data.emServico == "LSPD" then
        vRP.updateServico(user_id, "Nenhum")
    end
end)
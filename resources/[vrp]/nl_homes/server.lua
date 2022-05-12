local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local cfg = module("cfg/homes")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

-- Altera o vrp_user_homes para ter mais de uma casa por ID
vRP._prepare("sRP/fix_home_index",[[
	CREATE TABLE IF NOT EXISTS vrp_user_homes(
    user_id INTEGER,
    home VARCHAR(255) NOT NULL AFTER `user_id`,
    number INTEGER,
	`locked` BOOLEAN,
    `guardaRoupa` TEXT,
    `bau` TEXT,
    `bauLimite` INTEGER,
    CONSTRAINT pk_user_homes PRIMARY KEY(user_id),
    CONSTRAINT fk_user_homes_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE,
    UNIQUE(home,number)
  );
  ALTER TABLE `vrp_user_homes`
    CHANGE COLUMN `home` `home` VARCHAR(255) NOT NULL AFTER `user_id`,
    ADD `locked` BOOLEAN,
    ADD `guardaRoupa` TEXT,
    ADD `bau` TEXT,
    ADD `bauLimite` INTEGER,
	DROP INDEX `home`,
	DROP PRIMARY KEY,
	ADD PRIMARY KEY (`user_id`, `home`);
]])

vRP._prepare("sRP/obter_todos_enderecos","SELECT * FROM vrp_user_homes")
vRP._prepare("sRP/update_lock","UPDATE vrp_user_homes SET locked = @locked WHERE home = @home")
vRP._prepare("sRP/obter_endereco_pelo_nome","SELECT * FROM vrp_user_homes WHERE home = @home")
vRP._prepare("sRP/obter_endereco","SELECT user_id, home, number, locked FROM vrp_user_homes WHERE user_id = @user_id")
vRP._prepare("sRP/obter_dono_casa","SELECT user_id FROM vrp_user_homes WHERE home = @home AND number = @number")
vRP._prepare("sRP/rm_endereco","DELETE FROM vrp_user_homes WHERE user_id = @user_id")
vRP._prepare("sRP/novo_rm_endereco","DELETE FROM vrp_user_homes WHERE user_id = @user_id AND home = @home")
vRP._prepare("NL/set_endereco","INSERT INTO vrp_user_homes(user_id,home,number,locked,guardaRoupa,bau,bauLimite) VALUES(@user_id,@home,@number,@locked,@guardaRoupa,@bau,@bauLimite)")
-- Bau
vRP._prepare("NL/set_bau","UPDATE vrp_user_homes SET bau = @bau WHERE home = @home")
vRP._prepare("NL/get_casa","SELECT * FROM vrp_user_homes WHERE home = @home")
-- Guarda-Roupa
vRP._prepare("NL/set_roupas","UPDATE vrp_user_homes SET guardaRoupa = @guardaRoupa WHERE home = @home")
vRP._prepare("NL/get_roupas","SELECT guardaRoupa FROM vrp_user_homes WHERE home = @home")

--[[
async(function()
    local data = vRP.getSData("homes:init")
    local init = json.decode(data)
    if not init then
        vRP.execute("sRP/fix_home_index")
        vRP.setSData("homes:init", json.encode(true))
    end
end)]]

local casa = cfg.casas
local casa_slot = {}
local in_slot = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- Functions
-----------------------------------------------------------------------------------------------------------------------------------------
function getBauCasa(home)
    local rows = vRP.query("NL/get_casa", {home = home})
    if #rows > 0 then
        return json.decode(rows[1].bau), rows[1].bauLimite
    else
        return {}
    end
end

function setBauCasa(home,b)
    vRP.execute("NL/set_bau", {home = home, bau = json.encode(b)})
end

function getGuardaRoupa(home)
    local rows = vRP.query("NL/get_roupas", {home = home})
    if #rows > 0 then
        return json.decode(rows[1].guardaRoupa)
    else
        return {}
    end
end

function setGuardaRoupa(home,roupa)
    vRP.execute("NL/set_roupas", {
        ['home'] = home, 
        ['guardaRoupa'] = json.encode(roupa)
    })
end

function criarBlipCasa(user_id,source)
    local endereco = vRP.getUserAddresses(user_id)
    for k,v in pairs(endereco) do
        if #endereco > 0 then
			print(v.home)
            local entrada = casa[v.home].entrada
            vRPclient._addBlipProperty(source, entrada.x, entrada.y, entrada.z, 40, 3, v.home, 0.6)
        end
    end
end

function sair_slot(user_id, player, stype)
    local casa = casa_slot[stype]
    local entrada = casa.entrada

    local data = vRP.getUData(user_id, "homes:inside")
    local dentro = json.decode(data)
    if dentro or dentro.casa_stype then
        in_slot[user_id] = nil
        vRPclient.teleport(player, entrada.x, entrada.y, entrada.z)
        vRP.setUData(user_id, "homes:inside", json.encode({casa_stype = nil}))
    end

end

function entrar_slot(stype, id_casa, status)
    local user_id = vRP.getUserId(source)
    local player = vRP.getUserSource(user_id)
    local casa = casa_slot[stype]
    local saida = casa.saida

    local data = vRP.getUData(user_id, "homes:inside")
    local dentro = json.decode(data)
    if not dentro or not dentro.casa_stype then
        in_slot[user_id] = {
            ['casa'] = casa
        }
        vRP.setUData(user_id, "homes:inside", json.encode({casa_stype = stype}))
        vRPclient.teleport(player, saida.x, saida.y, saida.z)
        TriggerClientEvent('Homes:updateSlot', player, id_casa)
    end
end

function updateCasas(source)
    local user_id = vRP.getUserId(source)
    local endereco = vRP.query("sRP/obter_todos_enderecos")
    for k,v in pairs(endereco) do
        if #endereco > 0 then
            local nome = v.home
            local entrada = casa[nome].entrada
            local saida = casa[nome].saida
            local bau = casa[nome].bau
            local guardaRoupa = casa[nome].guardaRoupa
            local id = v.user_id
            local locked = v.locked
            casa_slot[nome] = {
                ['casa_nome'] = nome, 
                ['id_casa'] = id, 
                ['locked'] = locked, 
                ['entrada'] = entrada, 
                ['saida'] = saida, 
                ['bau'] = bau, 
				bau = casa[nome].bau,
                ['guardaRoupa'] = guardaRoupa
            }
        end
    end
    TriggerClientEvent('Homes:receberCasas', -1, casa_slot)
end

function updateBau(user_id,source,casa)
    local bauItems = {}
    if user_id then
        if casa then
            local data = getBauCasa(casa)
            for k,v in pairs(data) do
                bauItems[k] = {
                    amount=v.amount,
                    name=vRP.getItemName(k),
                    iweight=vRP.getItemWeight(k)*v.amount
                }
            end
            TriggerClientEvent('Inventario:inventarioSecundario', source, bauItems)
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Eventos
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('Homes:comprarCasa')
AddEventHandler('Homes:comprarCasa', function(user_id, nome)
    local player = vRP.getUserSource(user_id)
    local bau = casa[nome].bau
    print(user_id, nome, 1, true, bau.limite)
    vRP.setUserAddress(user_id, nome, 1, true, bau.limite)
    -- Seta o blip quando comprar a casa
    local rows = vRP.query("sRP/obter_casa", {nome = nome})
    if #rows > 0 then
        -- Atualiza a casa para o client
        local endereco = vRP.query("sRP/obter_endereco_pelo_nome", {home = nome})
        casa_slot[nome] = {
            ['casa_nome'] = nome, 
            ['id_casa'] = endereco[1].user_id, 
            ['locked'] = endereco[1].locked, 
            ['entrada'] = casa[nome].entrada, 
            ['saida'] = casa[nome].saida, 
            ['guardaRoupa'] = casa[nome].guardaRoupa,
			bau = v.bau,
            ['bau'] = casa[nome].bau
        }
        vRPclient._addBlipProperty(player, casa[nome].entrada.x, casa[nome].entrada.y, casa[nome].entrada.z, 40, 3, nome, 0.6)
    end

    -- Envia a casa atualizada para o client
    TriggerClientEvent('Homes:receberCasas', -1, casa_slot)
end)

RegisterNetEvent('Homes:entrarCasa')
AddEventHandler('Homes:entrarCasa', function(stype, id_casa, status)
    entrar_slot(stype, id_casa, status)
end)

RegisterNetEvent('Homes:sairCasa')
AddEventHandler('Homes:sairCasa', function(stype)
    local source = source
    local user_id = vRP.getUserId(source)
    sair_slot(user_id, source, stype)
end)

RegisterNetEvent('Homes:alterarStatusCasa')
AddEventHandler('Homes:alterarStatusCasa', function(casa_nome, id_casa, status)
    local source = source
    local user_id = vRP.getUserId(source)
    local rows = vRP.query("sRP/obter_casa", {nome = casa_nome})

    if #rows > 0 then
        local nome = casa_nome
        local entrada = casa[nome].entrada
        local saida = casa[nome].saida
        local bau = casa[nome].bau
        local guardaRoupa = casa[nome].guardaRoupa
        local locked = status

        if (id_casa == user_id) then
            
            if not locked then
                locked = true
            else
                locked = false
            end
			
			vRP.execute("sRP/update_lock", {home = nome, locked = locked})

            casa_slot[nome].locked = locked
		end
    end

    TriggerClientEvent('Homes:updateListaCasa', -1, casa_slot)
end)

-- Bau das casas
RegisterServerEvent('Homes:abrirBau')
AddEventHandler('Homes:abrirBau', function(casa)
    local bauItems = {}
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if casa_slot[casa].id_casa == user_id then
            local data = getBauCasa(casa)
            for k,v in pairs(data) do
                bauItems[k] = {
                    amount=v.amount,
                    name=vRP.getItemName(k),
                    iweight=vRP.getItemWeight(k)*v.amount
                }
            end
            TriggerClientEvent('Inventario:inventarioSecundario', source, bauItems)
        end
    end
end)

RegisterServerEvent('Homes:guardarNoBau')
AddEventHandler('Homes:guardarNoBau', function(idname, quantidade)
    local source = source
    local user_id = vRP.getUserId(source)
    local amount = vRP.getInventoryItemAmount(user_id, idname)
    local quantidade = tonumber(quantidade)

    if in_slot[user_id] then
        if amount >= quantidade then
            local casa = in_slot[user_id].casa

            local pegarBau, bauLimite = getBauCasa(casa.casa_nome)
            local novo_peso = vRP.computeItemsWeight(pegarBau)+vRP.getItemWeight(idname)*quantidade

            if novo_peso <= bauLimite then
                if pegarBau[idname] then -- Se o item existe então aumenta a quantidade
                    if pegarBau[idname].amount > 0 then
                        pegarBau[idname].amount = pegarBau[idname].amount + quantidade
                        setBauCasa(casa.casa_nome, pegarBau)
                        vRP.tryGetInventoryItem(user_id, idname, quantidade, false)
                    end
                else -- Se não cria ele com a quantidade
                    pegarBau[idname] = {amount = quantidade}
                    setBauCasa(casa.casa_nome, pegarBau)
                    vRP.tryGetInventoryItem(user_id, idname, quantidade, false)
                end
            else
                vRPclient._notify(source, "[Casa] Peso excedeu o limite do baú!")
            end

            updateBau(user_id, source, casa.casa_nome)
        else
            vRPclient._notify(source, "[Casa] Você não tem essa quantidade no inventário!")
        end
    end

end)

RegisterServerEvent('Homes:retirarDoBau')
AddEventHandler('Homes:retirarDoBau', function(idname, quantidade)
    local source = source
    local user_id = vRP.getUserId(source)
    local amount = tonumber(quantidade)
    if in_slot[user_id] then
        local casa = in_slot[user_id].casa

        local pegarBau = getBauCasa(casa.casa_nome)
        if pegarBau[idname] then
            if pegarBau[idname].amount >= amount then
                if ((vRP.getInventoryWeight(user_id)+vRP.getItemWeight(idname)*amount) <= vRP.getInventoryMaxWeight(user_id)) then
                    pegarBau[idname].amount = pegarBau[idname].amount - amount

                    if pegarBau[idname].amount <= 0 then
                        pegarBau[idname] = nil 
                    end

                    setBauCasa(casa.casa_nome, pegarBau)
                    vRP.giveInventoryItem(user_id,idname,amount,true)
                    updateBau(user_id, source, casa.casa_nome)
                else
                    vRPclient._notify(source, "[Casa] Peso excedeu o limite do inventário!")
                end
            end
        end
    end
end)

-- Guarda Roupa
RegisterNetEvent('Homes:salvarRoupa')
AddEventHandler('Homes:salvarRoupa', function(nome)
    local salvarRoupa = {}
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if nome then
            local roupa = vRPclient.getCustomization(source)
            if in_slot[user_id] then
                local casa = in_slot[user_id].casa
                local pegarRoupa = getGuardaRoupa(casa.casa_nome)
                pegarRoupa[nome] = roupa
                setGuardaRoupa(casa.casa_nome, pegarRoupa)
				TriggerEvent("Homes:updateSets", source, casa.casa_nome)
            end
        end
    end
end)

RegisterServerEvent('Homes:receberSets')
AddEventHandler('Homes:receberSets', function(casa)
    local roupaSets = {}
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if casa_slot[casa].id_casa == user_id then
            local data = getGuardaRoupa(casa)
            for k,v in pairs(data) do
                roupaSets[k] = {
                    ['nomeSet'] = k
                }
            end
            TriggerClientEvent('Home:setRoupaSets', source, roupaSets)
        end
    end
end)

AddEventHandler('Homes:updateSets', function(source, casa)
    local roupaSets = {}
    local user_id = vRP.getUserId(source)
    if user_id then
        if casa_slot[casa].id_casa == user_id then
            local data = getGuardaRoupa(casa)
            for k,v in pairs(data) do
                roupaSets[k] = {
                    ['nomeSet'] = k
                }
            end
            TriggerClientEvent('Home:updateRoupaSets', source, roupaSets)
        end
    end
end)

RegisterServerEvent('Homes:setarRoupa')
AddEventHandler('Homes:setarRoupa', function(nome)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if in_slot[user_id] then
            local casa = in_slot[user_id].casa
            local pegarRoupa = getGuardaRoupa(casa.casa_nome)
            if pegarRoupa[nome] then
                vRPclient.setCustomization(source,pegarRoupa[nome])
            end
        end
    end
end)

RegisterServerEvent('Homes:removeRoupa')
AddEventHandler('Homes:removeRoupa', function(nome)
    local salvarRoupa = {}
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if nome then
            if in_slot[user_id] then
                local casa = in_slot[user_id].casa
                local pegarRoupa = getGuardaRoupa(casa.casa_nome)
                pegarRoupa[nome] = nil
				setGuardaRoupa(casa.casa_nome, pegarRoupa)
				TriggerEvent("Homes:updateSets", source, casa.casa_nome)
			end
        end
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- vRP Eventos
-----------------------------------------------------------------------------------------------------------------------------------------
local criarBlip = {}
AddEventHandler('vRP:playerSpawn', function(user_id, source, first_spawn) 
    if user_id then
        if not criarBlip[user_id] then
            criarBlipCasa(user_id,source)
            criarBlip[user_id] = true
        end
        updateCasas(source)
        local data = vRP.getUData(user_id, "homes:inside")
        local dentro = json.decode(data)
        if dentro and dentro.casa_stype then
            SetTimeout(5000, function()
                sair_slot(user_id, source, dentro.casa_stype)
            end)
        end
    end
end)

Citizen.CreateThread(function()
	Citizen.Wait(100)
	for uid, src in pairs(vRP.getUsers()) do
		if uid then
			if not criarBlip[uid] then
				criarBlipCasa(uid,src)
				criarBlip[uid] = true
			end
			local data = vRP.getUData(uid, "homes:inside")
			local dentro = json.decode(data)
			if dentro and dentro.casa_stype then
				SetTimeout(5000, function()
					sair_slot(uid, src, dentro.casa_stype)
				end)
			end
		end
	end
	updateCasas(src)
end)

AddEventHandler('vRP:playerLeave', function(user_id, source) 
    if user_id then
        if criarBlip[user_id] then
            criarBlip[user_id] = nil
        end
    end
end)
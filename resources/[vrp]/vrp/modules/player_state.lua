local cfg = module("cfg/player_state")
local lang = vRP.lang

-- client -> server events
AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
	local user_id = vRP.getUserId(source)
	local data = vRP.getUserDataTable(user_id)
	local tmpdata = vRP.getUserTmpTable(user_id)
	
	if first_spawn then
		
		if data.customization == nil then
			data.customization = cfg.default_customization
		end
		
		if data.in_coma == nil then
			data.in_coma = false
		end
		
		if data.health == nil then
			vRPclient.setHealth(source,400)
		end
		
		if data.emServico == nil then
			data.emServico = "Nenhum"
		end
		
		-- Teleporta o player para a posição salva
		if data.position then
			--local x,y,z = cfg.spawn_position[1], cfg.spawn_position[2], cfg.spawn_position[3]
			--vRPclient.teleport(source,x,y,z)
			vRPclient.teleport(source,data.position.x,data.position.y,data.position.z)
		end
		
		-- Seta o colete
		if data.armor then
			vRPclient.setArmour(source,data.armor)
		end
		
		if data.customization then
			
			if data.cloakroom_idle then
				vRP.removeCloak(source)
			else
				-- Seta a customização
				vRPclient.setCustomization(source,data.customization)
			end
			-- Seta as armas
			if data.weapons then
				vRPclient.giveWeapons(source,data.weapons,true)
			end
			-- Seta a vida
			if data.health then
				vRPclient.setHealth(source,data.health)
			end
			-- Seta o status do coma
			if data.in_coma then
				vRPclient._playerComaState(source,data.in_coma)
			end
			
		else
			
			if data.weapons then
				vRPclient.giveWeapons(source,data.weapons,true)
			end
			
			if data.health then
				vRPclient.setHealth(source,data.health)
			end
			
			vRPclient.teleport(source,data.position.x,data.position.y,data.position.z)
		end		
	end
	vRPclient._playerStateReady(source,true)
end)

-- updates
function tvRP.updatePos(x,y,z)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		local tmp = vRP.getUserTmpTable(user_id)
		if data and (not tmp or not tmp.home_stype) then -- don't save position if inside home slot
			data.position = {x = tonumber(x), y = tonumber(y), z = tonumber(z)}
		end
	end
end

function tvRP.updateWeapons(weapons)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		if data then
			data.weapons = weapons
		end
	end
end

function tvRP.updateCustomization(customization)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		if data then
			data.customization = customization
		end
	end
end

function tvRP.updateHealth(health)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		if data then
			data.health = health
		end
	end
end

function tvRP.updateComaClient(coma)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		if data then
			data.in_coma = coma
			vRPclient._playerComaState(source, coma)
		end
	end
end

function vRP.updateComa(user_id,source,coma)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		if data then
			data.in_coma = coma
			vRPclient._playerComaState(source, coma)
		end
	end
end

function vRP.updateServico(user_id,servico)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		if data then
			data.emServico = servico
		end
	end
end

function tvRP.updateArmor(armor)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		if data then
			data.armor = armor
		end
	end
end
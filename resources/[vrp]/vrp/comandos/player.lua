----------------------------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER
----------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("rg", function(player, choice)
	if not vRPclient.isHandcuffed(player) then
		local user_id = vRP.getUserId(player)
		local level = math.floor(vRP.expToLevel(vRP.getExp(user_id, "exp", "level")))
		local exp = vRP.getExp(user_id, "exp", "level")
		local next_level = math.floor(vRP.expToLevel(exp))+1
		local next_exp = vRP.levelToExp(next_level)-exp
		local identity = vRP.getUserIdentity(user_id)
		if user_id then
			vRPclient._notify(player, "Nome: "..identity.name.." "..identity.firstname.. " | Idade: "..identity.age.." | Telefone: "..identity.phone.." | RG: "..identity.registration.." | Seu Lvl: "..level.." | Seu XP: "..exp.." | XP necessário o próximo level: "..next_exp)
		end
	end
end)

local guardando = {}
RegisterCommand("guardar", function(player, choice)
	if not vRPclient.isHandcuffed(player) then
		local user_id = vRP.getUserId(player)
		if user_id then
			local weapons = vRPclient.getWeapons(player)
			for k,v in pairs(weapons) do
				if not guardando[k] then
					guardando[k] = true
					if guardando[k] then
						SetTimeout(1500,function()
							vRP.giveInventoryItem(user_id, "wbody|"..k, 1, true)
							if v.ammo > 0 then
								vRP.giveInventoryItem(user_id, "wammo|"..k, v.ammo, true)
							end
							vRPclient.giveWeapons(player,{},true)
						end)
						guardando[k] = nil
					end
				end
			end
		end
	end
end)
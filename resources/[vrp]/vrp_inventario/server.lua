local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPinv = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_inventario",vRPinv)
Proxy.addInterface("vrp_inventario",vRPinv)
local cfg = module("vrp_inventario", "cfg/config")

Citizen.CreateThread(function()
	for k, v in pairs(cfg.items) do
		if not vRP.getItemDefinition(k) then
			vRP.defInventoryItem(k, k, "", v.weight)
		end
	end
end)

function getItemType(idname)
	-- idname = {ftype: bebida ou comida, vary_hunger, vary_thirst}
	-- o idname fica em: cfg/item/food.lua
	-- Exemplo: ["water"] = {"Garrafa de Agua","", gen("drink",0,-25),0.5}
	-- ["water"] é o idname
	
	if cfg.items[idname] then
		return cfg.items[idname]
	else
		print("Erro ao encontrar item: "..idname)
		return false
	end
end

function maybeDrink(player, user_id, idname, idqtd)
	if getItemType(idname).ftype == "bebida" then
		if vRP.tryGetInventoryItem(user_id,idname,tonumber(idqtd),true) then
			if vary_hunger ~= 0 then vRP.varyHunger(user_id, getItemType(idname).vary_hunger * idqtd) end
			if vary_thirst ~= 0 then vRP.varyThirst(user_id, getItemType(idname).vary_thirst * idqtd) end
			play_drink(player)
			return true
		end
	end
	return false
end

function maybeEat(player, user_id, idname, idqtd)
	if getItemType(idname).ftype == "comida" then
		if vRP.tryGetInventoryItem(user_id,idname,tonumber(idqtd),false) then
			if vary_hunger ~= 0 then vRP.varyHunger(user_id, getItemType(idname).vary_hunger * idqtd) end
			if vary_thirst ~= 0 then vRP.varyThirst(user_id, getItemType(idname).vary_thirst * idqtd) end
			play_eat(player)
			return true
		end
	end
	return false
end

function maybeDrugs(player, user_id, idname, idqtd)
	if getItemType(idname).ftype == "drogas" then
		if vRP.tryGetInventoryItem(user_id,idname,tonumber(idqtd),false) then
			vRPclient._varyHealth(player, getItemType(idname).vary_health)
			play_drink(player)
			return true
		end
	end
	return false
end

function maybeGiveMoney(player, user_id, idname, idqtd)
	if idname == "dinheiro" then
		local amount = vRP.getInventoryItemAmount(user_id, idname)
		local ramount = tonumber(idqtd)
		if vRP.tryGetInventoryItem(user_id, idname, ramount, true) then
			vRP.giveMoney(user_id, ramount)
			return true
		end
	end
	return false
end

function maybeGiveWeapons(player, user_id, idname, idqtd)
	local wbody = splitString(idname, "|")
	if wbody[2] then
		if idname == "wbody|"..wbody[2] then
			local uweapons = vRPclient.getWeapons(player)
			if not uweapons[wbody[2]] then
				if vRP.tryGetInventoryItem(user_id, "wbody|"..wbody[2], tonumber(idqtd), true) then
					local weapons = {}
					weapons[wbody[2]] = {ammo = 0}
					vRPclient._giveWeapons(player, weapons)
					return true
				end
			end
		end
	end
	return false
end

function maybeGiveBullets(player, user_id, idname, idqtd)
	local wammo = splitString(idname, "|")
	if wammo[2] then
		if idname == "wammo|"..wammo[2] then
			local amount = vRP.getInventoryItemAmount(user_id, "wammo|"..wammo[2])
			local ramount = tonumber(idqtd)
			
			local uweapons = vRPclient.getWeapons(player)
			if uweapons[wammo[2]] then
				if vRP.tryGetInventoryItem(user_id, "wammo|"..wammo[2], ramount, true) then
					local weapons = {}
					weapons[wammo[2]] = {ammo = ramount}
					vRPclient._giveWeapons(player, weapons,false)
					return true
				end
			end
		end
	end
	return false
end

function notifyUnusable(player, user_id, idname)
	vRPclient._notifyError(player, "Não utilizável")
end

function play_eat(player)
	local seq = {
		{"mp_player_inteat@burger", "mp_player_int_eat_burger_enter",1},
		{"mp_player_inteat@burger", "mp_player_int_eat_burger",1},
		{"mp_player_inteat@burger", "mp_player_int_eat_burger_fp",1},
		{"mp_player_inteat@burger", "mp_player_int_eat_exit_burger",1}
	}
	
	vRPclient._playAnim(player,true,seq,false)
end

function play_drink(player)
	local seq = {
		{"mp_player_intdrink","intro_bottle",1},
		{"mp_player_intdrink","loop_bottle",1},
		{"mp_player_intdrink","outro_bottle",1}
	}
	
	vRPclient._playAnim(player,true,seq,false)
end

RegisterServerEvent('Inventario:pegarInventario')
AddEventHandler('Inventario:pegarInventario', function()
	local inventario = {}
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local dinheiro = addComma(math.floor(vRP.getMoney(user_id)))
		local weight = vRP.getInventoryWeight(user_id)
		local max_weight = vRP.getInventoryMaxWeight(user_id)
		local hue = string.format("%.2f",weight/max_weight)
		local identity = vRP.getUserIdentity(user_id)
		for k,v in pairs(vRP.getInventory(user_id)) do
			inventario[k] = {
				amount=v.amount,
				name=vRP.getItemName(k),
				iweight=vRP.getItemWeight(k)*v.amount
			}
		end
		TriggerClientEvent('Inventario:enviarInventario', source, inventario, dinheiro, weight, max_weight, hue, identity.name.." "..identity.firstname)
	end
end)

RegisterServerEvent('Inventario:pegarInventarioNuser')
AddEventHandler('Inventario:pegarInventarioNuser', function()
	local inventario = {}
	local source = source
	local user_id = vRP.getUserId(source)
	
	local nplayer = vRPclient.getNearestPlayer(source, 3)
	local nuser_id = vRP.getUserId(nplayer)
	
	if nuser_id and vRPclient.isInComa(nuser_id) then
		local dinheiro = addComma(math.floor(vRP.getMoney(nuser_id)))
		local weight = vRP.getInventoryWeight(nuser_id)
		local max_weight = vRP.getInventoryMaxWeight(nuser_id)
		local hue = string.format("%.2f",weight/max_weight)
		local identity = vRP.getUserIdentity(nuser_id)
		
		for k,v in pairs(vRP.getInventory(nuser_id)) do
			inventario[k] = {
				amount=v.amount,
				name=vRP.getItemName(k),
				iweight=vRP.getItemWeight(k)*v.amount
			}
		end
		TriggerClientEvent('Inventario:enviarInventarioNuser', source, inventario, dinheiro, weight, max_weight, hue, identity.name.." "..identity.firstname)
	end
end)

RegisterServerEvent('Inventario:usar')
AddEventHandler('Inventario:usar', function(idname, idqtd)
	local player = source
	local name = vRP.getItemName(idname)
	local user_id = vRP.getUserId(player)
	if user_id ~= nil then
		local p = {player, user_id, idname, tonumber(idqtd)}
		local t = table.unpack
		local handcuffed = vRPclient.isHandcuffed(player)
		updateInventario(user_id, source)
		if not vRPclient.isInComa(player) and not handcuffed then
			local result = maybeDrink(t(p)) or maybeEat(t(p)) or maybeDrugs(t(p)) or maybeGiveMoney(t(p)) or maybeGiveWeapons(t(p)) or maybeGiveBullets(t(p)) or notifyUnusable(t(p))
		end
	end
	
end)

RegisterServerEvent('Inventario:dropar')
AddEventHandler('Inventario:dropar', function(idname, idqtd)
	local player = source
	local user_id = vRP.getUserId(player)
	local amount = tonumber(idqtd)
	local handcuffed = vRPclient.isHandcuffed(player)
	if not vRPclient.isInComa(player) and not handcuffed then
		if vRP.tryGetInventoryItem(user_id,idname,amount,false) then
			vRPclient._notify(player, "Você dropou: "..amount.." "..vRP.getItemName(idname))
			vRPclient._playAnim(player,true,{{"pickup_object","pickup_low",1}},false)
			updateInventario(user_id, source)
			TriggerClientEvent("DropSystem:drop", player, idname, amount)
		else
			vRPclient._notify(player, "Valor inválido")
		end
	end
end)

function splitString(str, sep)
	if sep == nil then sep = "%s" end
	
	local t={}
	local i=1
	
	for str in string.gmatch(str, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	
	return t
end

function addComma(amount)
	local formatted = amount
	while true do 
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

function updateInventario(user_id, source)
	local inventario = {}
	if user_id then
		local dinheiro = addComma(math.floor(vRP.getMoney(user_id)))
		local weight = vRP.getInventoryWeight(user_id)
		local max_weight = vRP.getInventoryMaxWeight(user_id)
		local hue = string.format("%.2f",weight/max_weight)
		local identity = vRP.getUserIdentity(user_id)
		
		for k,v in pairs(vRP.getInventory(user_id)) do
			inventario[k] = {
				amount=v.amount,
				name=vRP.getItemName(k),
				iweight=vRP.getItemWeight(k)*v.amount
			}
		end
		TriggerClientEvent('Inventario:enviarInventario', source, inventario, dinheiro, weight, max_weight, hue, identity.name.." "..identity.firstname)
	end
end

function getBauCar(placa)
	local rows = vRP.query("NL/get_bauCar", {placa = placa})
	if count(rows[1]) > 0 then
		rows = rows[1]
		return json.decode(rows.bau), rows.bauLimite
	else
		return {}, 0
	end
end

function setBauCar(placa, b)
	vRP.execute("NL/set_bauCars", {placa = placa, bau = json.encode(b)})
end

function updateBau(user_id, placa, source)
	local bauItemsCar = {}
	if user_id then
		local data = getBauCar(placa)
		for k,v in pairs(data) do
			bauItemsCar[k] = {
				amount=v.amount,
				name=vRP.getItemName(k),
				iweight=vRP.getItemWeight(k)*v.amount
			}
		end
		TriggerClientEvent('Inventario:inventarioSecundarioCar', source, bauItemsCar)
	end
end

RegisterServerEvent('Inventario:abrirBauCar')
AddEventHandler('Inventario:abrirBauCar', function()
	local bauItemsCar = {}
	local source = source
	local user_id = vRP.getUserId(source)
	local placa,model,veh = vRPclient.getVehicleAtRaycast(source, 15)
	if user_id then
		local pegarBau, bauLimite = getBauCar(placa)
		for k,v in pairs(pegarBau) do
			bauItemsCar[k] = {
				amount = v.amount,
				name = vRP.getItemName(k),
				iweight = vRP.getItemWeight(k)*v.amount
			}
		end
		TriggerClientEvent('Inventario:inventarioSecundarioCar', source, bauItemsCar)
	end
end)

RegisterServerEvent('Inventario:guardarNoBauCar')
AddEventHandler('Inventario:guardarNoBauCar', function(idname, quantidade)
	local source = source
	local user_id = vRP.getUserId(source)
	local amount = vRP.getInventoryItemAmount(user_id, idname)
	local quantidade = tonumber(quantidade)
	local placa,model,veh = vRPclient.getVehicleAtRaycast(source, 15)
	if amount >= quantidade then
		local pegarBau, bauLimite = getBauCar(placa)
		local novo_peso = vRP.computeItemsWeight(pegarBau)+vRP.getItemWeight(idname)*quantidade
		if novo_peso <= bauLimite then
			if pegarBau[idname] then 
				if pegarBau[idname].amount > 0 then
					pegarBau[idname].amount = pegarBau[idname].amount + quantidade
					setBauCar(placa, pegarBau)
					vRP.tryGetInventoryItem(user_id, idname, quantidade, false)
				end
			else 
				pegarBau[idname] = {amount = quantidade}
				setBauCar(placa, pegarBau)
				vRP.tryGetInventoryItem(user_id, idname, quantidade, false)
			end
		else
			vRPclient._notify(source, "[Veiculo] Peso excedeu o limite do baú!")
		end
		updateBau(user_id, placa, source)
	else
		vRPclient._notify(source, "[Veiculo] Você não tem essa quantidade no inventário!")
	end
end)

RegisterServerEvent('Inventario:retirarDoBauCar')
AddEventHandler('Inventario:retirarDoBauCar', function(idname, quantidade)
	local source = source
	local user_id = vRP.getUserId(source)
	local amount = tonumber(quantidade)
	local placa,model,veh = vRPclient.getVehicleAtRaycast(source, 15)
	local pegarBau, bauLimite = getBauCar(placa)
	if pegarBau[idname] then
		if pegarBau[idname].amount >= amount then
			if ((vRP.getInventoryWeight(user_id)+vRP.getItemWeight(idname)*amount) <= vRP.getInventoryMaxWeight(user_id)) then
				pegarBau[idname].amount = pegarBau[idname].amount - amount
				if pegarBau[idname].amount <= 0 then
					pegarBau[idname] = nil 
				end
				setBauCar(placa, pegarBau)
				vRP.giveInventoryItem(user_id,idname,amount,true)
				updateBau(user_id, placa, source)
			else
				vRPclient._notify(source, "[Veiculo] Peso excedeu o limite do inventário!")
			end
		end
	end
end)
--[[


BAU DO USUARIO ASSALTADO


]]
RegisterServerEvent('Inventario:guardarNoBauUser')
AddEventHandler('Inventario:guardarNoBauUser', function(idname, quantidade)
	local player = source
	local user_id = vRP.getUserId(player)
	local quantidade = tonumber(quantidade)
	
	local nplayer = vRPclient.getNearestPlayer(source, 3)
	local nuser_id = vRP.getUserId(nplayer)
	
	local handcuffed = vRPclient.isHandcuffed(player)
	if not vRPclient.isInComa(player) and not handcuffed then
		if vRP.tryGetInventoryItem(user_id, idname, quantidade, false) then
			vRP.giveInventoryItem(nuser_id, idname, quantidade, true)
			updateInventario(nuser_id, source)
			updateInventario(user_id, source)
		else
			vRPclient._notify(player, "Valor inválido")
		end
	end
end)

RegisterServerEvent('Inventario:retirarDoBauUser')
AddEventHandler('Inventario:retirarDoBauUser', function(idname, quantidade)
	local player = source
	local user_id = vRP.getUserId(player)
	local quantidade = tonumber(quantidade)
	
	local nplayer = vRPclient.getNearestPlayer(source, 3)
	local nuser_id = vRP.getUserId(nplayer)
	
	local handcuffed = vRPclient.isHandcuffed(player)
	if not vRPclient.isInComa(player) and not handcuffed then
		if vRP.tryGetInventoryItem(nuser_id, idname, quantidade, false) then
			vRP.giveInventoryItem(user_id, idname, quantidade, true)
			updateInventario(user_id, source)
			updateInventario(nuser_id, source)
		else
			vRPclient._notify(player, "Valor inválido")
		end
	end
end)
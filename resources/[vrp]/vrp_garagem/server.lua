local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local cfg = module("vrp_garagem", "cfg/config")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
GNclient = Tunnel.getInterface("vrp_garagem","vrp_garagem")
vConceS = Proxy.getInterface("vrp_concessionaria","vrp_garagem")
vGRGS = {}
Tunnel.bindInterface("vrp_garagem",vGRGS)
Proxy.addInterface("vrp_garagem",vGRGS)

vRP._prepare("NL/selecionar_veiculos","SELECT * FROM vrp_user_vehicles")
vRP._prepare("NL/get_user_by_plate","SELECT user_id FROM vrp_user_vehicles WHERE placa = @placa")
vRP._prepare("NL/update_state_veh","UPDATE vrp_user_vehicles SET state = @state WHERE user_id = @user_id AND vehicle = @veh AND state IN (0,1)")
vRP._prepare("NL/update_state_veh_all","UPDATE vrp_user_vehicles SET state = 0 WHERE state = 1")
vRP._prepare("NL/update_state_veh_all_user","UPDATE vrp_user_vehicles SET state = 0 WHERE user_id = @user_id AND state = 1")
vRP._prepare("vRP/remove_vehicle","DELETE FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("vRP/get_vehicles","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id")
vRP._prepare("vRP/get_vehicle_by_model","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id and vehicle = @vehicle")

vRP._prepare("vRP/get_veh_by_plate","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id AND placa = @placa")
vRP._prepare("vRP/selecionar_veh_placa","SELECT * FROM vrp_user_vehicles WHERE placa = @placa")

vRP._prepare("vRP/get_vehicles_by_state","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id AND state = @state")
vRP._prepare("vRP/get_vehicles_by_states","SELECT * FROM vrp_user_vehicles WHERE user_id = @user_id AND state >= @state")
vRP._prepare("vRP/get_vehicle","SELECT vehicle FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("vRP/set_vehstatus","UPDATE vrp_user_vehicles SET motor = @motor, lataria = @lataria, gasolina = @gasolina WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("vRP/get_veh_custom", "SELECT custom FROM vrp_user_vehicles WHERE placa = @placa and vehicle = @vehicle")
vRP._prepare("vRP/set_veh_custom", "UPDATE vrp_user_vehicles SET custom = @custom WHERE placa = @placa and vehicle = @vehicle")
vRP._prepare("vRP/set_ipva","UPDATE vrp_user_vehicles SET ipva = @ipva WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("vRP/get_veh_state","SELECT state FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("vRP/set_veh_state","UPDATE vrp_user_vehicles SET state = @state WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("creative/rem_vehicle","DELETE FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
vRP._prepare("creative/move_vehicle","UPDATE vrp_user_vehicles SET user_id = @nuser_id WHERE user_id = @user_id AND vehicle = @vehicle")


Citizen.CreateThread(function()
	Citizen.Wait(2000)
	vRP.execute("NL/update_state_veh_all")
	Citizen.Wait(10000)
	for k, v in pairs(cfg.rent) do
		for x, y in pairs(v.carros) do
			local info = vConceS.getCarInfo(y)
			if not info then print("Erro no carro: "..y) end
		end
	end
end)

function saveMessage(message)
	file = "Logs/carspawns.txt"
	local fl =  io.open(file, "a")
	if fl ~= nil then
		fl:write("LOG - "..os.date("%H:%M:%S %d/%m/%Y").." => "..tostring(message).."\n")
		fl:close()
  	end
end

local vehicles = {}
local rentvehs = {}
local vmodeli = {}

function vGRGS.requestPerm(perm)
	local source = source
	local user_id = vRP.getUserId(source)
	if perm and perm ~= "" and vRP.hasPermission(user_id, perm) then
		return true
	else
		return false
	end
end

function vGRGS.requestVehAndPerm(perm, veh)
	local source = source
	local user_id = vRP.getUserId(source)
	if perm == "" or vRP.hasPermission(user_id, perm) then
		local veiculo = {}
		for k,v in pairs(veh) do
			local info = vConceS.getCarInfo(v)
			local state = 0
			if rentvehs[user_id] and rentvehs[user_id][v] then
				state = 1 
			end
			table.insert(veiculo, {
				['nome'] = info.nome,
				['modelo'] = v,
				['placa'] = vConceS.criarPlaca(),
				['img'] = info.imagemcarro,
				['state'] = state,
				['tipo'] = info.tipo,
				['motor'] = 1000,
				['lataria'] = 1000,
				['gasolina'] = 100,
			})
		end
		local identity = vRP.getUserIdentity(user_id)
		return true, veiculo, identity.name.." "..identity.firstname
	else
		return false, nil, nil
	end
end

function vGRGS.requestOwner(home)
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id, perm) then
		local homes = vRP.query("homes/get_homeuser",{ user_id = user_id, home = home })
		if homes[1] then
			return true
		else
			return false
		end
	else
		return false
	end
end

function getUserByPlate(plate)
    local rows = vRP.query("NL/get_user_by_plate", {placa = plate})
    if #rows > 0 then
        return rows[1].user_id
    end
end

RegisterServerEvent('Garagem:enviarVeiculos')
AddEventHandler('Garagem:enviarVeiculos', function(tipo)
    local veiculo = {}
    local source = source
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    local veh = vRP.query("vRP/get_vehicles", {user_id = user_id, state = 0})
    for k,v in pairs(veh) do
		if tipo[tostring(v.tipo)] then
			table.insert(veiculo, {
				['nome'] = vConceS.getCarInfo(v.vehicle).nome,
				['modelo'] = v.vehicle,
				['placa'] = v.placa,
				['img'] = vConceS.getCarImage(v.vehicle),
				['state'] = v.state,
				['tipo'] = v.tipo,
				['motor'] = v.motor,
				['lataria'] = v.lataria,
				['gasolina'] = v.gasolina or 100.0,
			})
		end
    end
    local quantidade = vRP.table_size(vRP.table_filter(veh, function(v, k, t) return v.state end))
    TriggerClientEvent('Garagem:receberVeiculos', source, veiculo, identity.name.." "..identity.firstname, quantidade)
end)

RegisterServerEvent('Garagem:statusUpdate')
AddEventHandler('Garagem:statusUpdate', function(veh, motor, lataria, gasolina)
    local source = source
    local user_id = vRP.getUserId(source)
	vRP.execute("vRP/set_vehstatus", {vehicle = vRPclient.getHashModel(source, veh), motor = parseInt(motor), lataria = parseInt(lataria), gasolina = parseInt(gasolina), user_id = user_id})
end)	

RegisterServerEvent('Garagem:SpawnVeh')
AddEventHandler('Garagem:SpawnVeh', function(data, store)
    local source = source
    local user_id = vRP.getUserId(source)
	local cs = GNclient.checkCarSpace(source)
	if cs then
		local plate = data.placa
		local info = vConceS.getCarInfo(data.vehicle).show
		if store and store ~= "rent" or not store then
			local veiculo = vRP.query("vRP/get_vehicle_by_model", {user_id = user_id, vehicle = data.vehicle})
			if veiculo and veiculo[1] then
					if veiculo[1].state == 0 then
						if parseInt(os.time()) >= parseInt(veiculo[1].ipva+24*15*60*60) then
							TriggerClientEvent("Notify",source,"negado","Seu <b>Vehicle Tax</b> está atrasado.",10000)
							local ok = vRP.request(source, "Deseja pagar o IPVA do seu veiculo?", 15)
							if ok then
								local r = vRP.execute("vRP/set_ipva",{ ipva = os.time(), user_id = parseInt(user_id), vehicle = tostring(veiculo[1].vehicle)})
							else
								return
							end
						end
						local tuning = vRP.getSData("custom:u"..user_id.."veh_"..veiculo[1].vehicle) or {}
						local custom = json.decode(tuning) or {}
						local ok, netid, model, veh = GNclient.GaragemSpawnVeiculo(source, veiculo, custom,cs, plate)
						if ok then
							while NetworkGetEntityFromNetworkId(netid) == 0 do
								Citizen.Wait(500)
							end
							vehicles[netid] = {plate = plate, source = source, user_id = user_id, model = model, vehname = data.vehicle}
							if not vmodeli[user_id] then vmodeli[user_id] = {} end
							vmodeli[user_id][model] = {"normal", data.vehicle}
							vRP.execute("NL/update_state_veh", {user_id = user_id, veh = data.vehicle, state = 1})
						end
					elseif veiculo[1].state == 1 then
						TriggerClientEvent("Notify",source, "negado","[Garagem] Este veiculo já está fora!")
					elseif veiculo[1].state == 2 then
						TriggerClientEvent("Notify",source, "negado","[Garagem] Este veiculo está apreendido!")
					end
			else
				print("Ocorreu um erro ao selecionar o carro: "..json.encode(data))
			end
		else
			local modeli = vRPclient.getModelHash(source, data.vehicle)
			if vmodeli[user_id] and not vmodeli[user_id][modeli] or not vmodeli[user_id] then
				local ok, netid, model = GNclient.GaragemSpawnVeiculo(source, {data}, {},cs)
				vehicles[netid] = {plate = plate, source = source, user_id = user_id, model = model, vehname = data.vehicle}
				if not rentvehs[user_id] then rentvehs[user_id] = {} end
				if not vmodeli[user_id] then vmodeli[user_id] = {} end
				rentvehs[user_id][data.vehicle] = netid
				vmodeli[user_id][model] = {"rent", data.vehicle}
			else
				TriggerClientEvent("Notify",source, "negado","[Garagem] Este veiculo já está fora!")
			end
		end
	else
		TriggerClientEvent("Notify",source, "negado","[Garagem] Todas vagas já estão ocupadas!")
	end
end)

RegisterServerEvent('Garagem:forceDeleteVehicle')
AddEventHandler('Garagem:forceDeleteVehicle', function(veh)
	GNclient._freeThisVeh(source, veh)
end)

RegisterServerEvent('Garagem:DespawnVeh')
AddEventHandler('Garagem:DespawnVeh', function(data)
    local source = source
    local user_id = vRP.getUserId(source)
	local placa = data.placa
	data.model = vRPclient.getModelHash(source, data.id)
	if vmodeli[user_id] and vmodeli[user_id][data.model][1] == "rent" then
		local ok, netid, model = GNclient.getNearestOwnedVehicle(source, 25)
		if vmodeli[user_id] and vmodeli[user_id][model] then
			local vehname = GNclient.despawnGarageVehicle(source, netid, data.id)
			vehicles[netid] = nil
			vmodeli[user_id][model] = nil
			rentvehs[user_id][data.id] = nil
			TriggerClientEvent("Notify",source, "sucesso","[Garagem] Você guardou <b>"..vehname.."</b>")
		end
	else
		local veiculo = vRP.query("vRP/get_vehicle_by_model", {user_id = user_id, vehicle = data.id})
		if #veiculo > 0 then
			-- Verifica se o veiculo está fora
			if veiculo[1].state then
				local ok, netid, model = GNclient.getNearestOwnedVehicle(source, 25)
				if ok then
					if vehicles[netid] then placa = vehicles[netid].plate vehicles[netid] = nil end
					local vehname = GNclient.despawnGarageVehicle(source, netid, model, true)
					vRP.execute("NL/update_state_veh", {user_id = user_id, veh = data.id, state = 0})
					vehicles[netid] = nil
					vmodeli[user_id][data.model] = nil
					TriggerClientEvent("Notify",source, "sucesso","[Garagem] Você guardou <b>"..vRPclient.getHashModel(source, vehname).."</b>")
				else
					TriggerClientEvent("Notify",source, "negado", "[Garagem] Este veiculo muito longe para ser guardado!")
				end
			else
				TriggerClientEvent("Notify",source, "negado","[Garagem] Este veiculo já está na garagem!")
			end
		else
			local ok, netid, model = GNclient.getNearestOwnedVehicle(source, 25)
			if vmodeli[user_id] and vmodeli[user_id][model] then
				local vehname = GNclient.despawnGarageVehicle(source, netid, data.id)
				vehicles[netid] = nil
				vmodeli[user_id][model] = nil
				if rentvehs[user_id][data.id] then
					rentvehs[user_id][data.id] = nil
				end
				TriggerClientEvent("Notify",source, "sucesso","[Garagem] Você guardou <b>"..vehname.."</b>")
			end
		end
	end
end)

AddEventHandler('Garagem:ServerDespawnVeh', function(source,data)
	local source = source
    local user_id = vRP.getUserId(source)
	local placa = data.placa or nil
	local ok, netid, model = GNclient.getNearestVehicle(source, 5)
	if ok then
		local vehname
		local modelname = vRPclient.getHashModel(source, parseInt(model))
		if not modelname then print("Falha ao encontrar veiculo "..model) end
		if rentvehs[user_id] and rentvehs[user_id][modelname] then
			vehname = GNclient.despawnGarageVehicle(source, netid, model)
			rentvehs[user_id][modelname] = nil
			if vehicles[netid] and vehicles[netid].plate then placa = vehicles[netid].plate vehicles[netid] = nil end
			if vmodeli[user_id] and vmodeli[user_id][model] then
				vmodeli[user_id][model] = nil
			end
		else
			if vmodeli[user_id] and vmodeli[user_id][model] then
				vehname = GNclient.despawnGarageVehicle(source, netid, model, true)
				if vehicles[netid] and vehicles[netid].plate then placa = vehicles[netid].plate vehicles[netid] = nil end
				vmodeli[user_id][model] = nil
				vRP.execute("NL/update_state_veh", {user_id = user_id, veh = tostring(modelname:lower()), state = 0})
			else
				vehname = GNclient.despawnGarageVehicle(source, netid, model)
			end
		end
		TriggerClientEvent("Notify",source, "sucesso","[Garagem] Você guardou <b>"..modelname.."</b>")
	else
		TriggerClientEvent("Notify",source, "negado", "[Garagem] Este veiculo muito longe para ser guardado!")
	end
end)

AddEventHandler('Garagem:ServerWVRDespawnVeh', function(source,data)
	local source = source
    local user_id = vRP.getUserId(source)
	local placa = data.placa or nil
	local ok, netid, model = GNclient.getNearestVehicle(source, 5)
	if ok then
		local vehname = GNclient.despawnGarageVehicle(source, netid, model, true)
		if vehicles[netid] and vehicles[netid].plate then placa = vehicles[netid].plate vehicles[netid] = nil end
		if vmodeli[user_id][model] and vmodeli[user_id][model][1] == "normal" then
			vRP.execute("NL/update_state_veh", {user_id =user_id, veh = vmodeli[user_id][model][2], state = 0})
		end
		if vmodeli[user_id] and vmodeli[user_id][model] then
			vmodeli[user_id][model] = nil
		end
		if rentvehs[user_id][vmodeli[user_id][model][2]] then
			rentvehs[user_id][vmodeli[user_id][model][2]] = nil
		end
	else
		TriggerClientEvent("Notify",source, "negado", "[Garagem] Este veiculo muito longe para ser guardado!")
	end
end)

--[[
Citizen.CreateThread(function()
	while true do
		for uid, data in pairs(vehicles) do
			local source = vRP.getUserSource(uid)
			if source then
				for model, data in pairs(data) do
					local exists = vRPclient.doesEntityExist(source, data[4])
					if not exists then vehicles[uid][model] = nil end
				end
			end
			Citizen.Wait(50)
		end
		Citizen.Wait(50)
	end
end)]]

function vGRGS.checkVehicle(user_id, model)
	if vehicles[user_id] then
		return vehicles[user_id][model] or nil
	end
	return nil
end

function vGRGS.checkVehicleInfo(netid)
	if vehicles[netid] then
		return vehicles[netid] or nil
	end
	return nil
end

function vGRGS.GaragemVenderVeh(data, store)
	local source = source
	local user_id = vRP.getUserId(source)
	if store ~= "rent" then
		local placa = data.placa
		local veiculo = vRP.query("vRP/get_vehicle_by_model", {user_id = user_id, vehicle = data.id})
		if #veiculo > 0 then
			-- Verifica se o veiculo está fora
			if veiculo[1].state == 0 then
				local info = vConceS.getCarInfo(data.id)
				local p = math.floor(info.precocarro*0.6)
				local answ = vRP.request(source,"Deseja vender seu "..info.nome.." por "..p.." ?",60)
				if answ then
					vRP.execute("vRP/remove_vehicle",{user_id = user_id, vehicle = data.id})
					vRP.giveMoney(user_id, p)
					TriggerClientEvent("Notify",source, "sucesso","[Garagem] Você vendeu "..info.nome.." por "..p)
				end
			else
				TriggerClientEvent("Notify",source, "negado","[Garagem] Este veiculo não está na garagem!")
			end
		end
	else
		TriggerClientEvent("Notify",source, "negado","[Garagem] Você não pode vender veículo de aluguel")
	end
end

AddEventHandler("vRP:playerLeave",function(user_id, source)
	if vehicles[user_id] then
		vehicles[user_id] = nil
	end
	vRP.execute("NL/update_state_veh_all_user", {user_id = user_id})
end)

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
	if vehicles[user_id] then
		vehicles[user_id] = nil
	end
	vRP.execute("NL/update_state_veh_all_user", {user_id = user_id})
end)

function vGRGS.GaragemPagarTarifa(data, store)
	local source = source
	local user_id = vRP.getUserId(source)
	if store ~= "rent" then
		local rows = vRP.query("vRP/get_veh_state",{ user_id = user_id, vehicle = data.id })
		if #rows > 0 then
			if rows[1].state == 2 then
				local info = vConceS.getCarInfo(data.id)
				local p = 5000
				local req = vRP.request(source, "Deseja pagar "..p.." para liberar seu veículo?",30)
				if req and vRP.tryFullPayment(user_id, p) then
					vRP.execute("vRP/set_veh_state",{ user_id = user_id, vehicle = data.id, state = 0})
					TriggerClientEvent("Notify",source, "sucesso","[Garagem] Veículo liberado.")
				else
					TriggerClientEvent("Notify",source, "negado","[Garagem] Algo deu errado")
				end
			else
				TriggerClientEvent("Notify",source, "negado","[Garagem] O veículo não está apreendido")
			end
		else
			TriggerClientEvent("Notify",source, "negado","[Garagem] O veículo não está apreendido")
		end
	end
end

function vGRGS.vehicleLock()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local vehicle,vnetid,placa,vname,lock = vRPclient.vehList(source,7)
		if vehicle then
			local vinfo = vGRGS.checkVehicleInfo(vnetid)
			if vinfo and vinfo.user_id == user_id then
				TriggerClientEvent("vrp_sound:source",source,'lock',0.5)
				vRPclient.playAnim(source,true,{{"anim@mp_player_intmenu@key_fob@","fob_click"}},false)
				if lock == 1 then
					TriggerClientEvent("Notify",source,"importante","Veículo <b>trancado</b> com sucesso.",8000)
				else
					TriggerClientEvent("Notify",source,"importante","Veículo <b>destrancado</b> com sucesso.",8000)
				end
				return vnetid,lock
			else
				TriggerClientEvent("Notify",source,"importante","Falha ao destrancar o carro (1)!",8000)
			end
		else
			TriggerClientEvent("Notify",source,"importante","Falha ao destrancar o carro (2)!",8000)
		end
	end
	TriggerClientEvent("Notify",source,"importante","Falha ao destrancar o carro (3)!",8000)
	return nil
end

RegisterCommand('dv',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"adm.perm") then
		local vehicle,vnetid,placa = vRPclient.vehList(source,25)
		TriggerEvent('Garagem:ServerDespawnVeh', source,{placa = placa or nil})
	end
end)

RegisterCommand('dvarea',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.permissao") then
		local vehicle = true
		while vehicle do
        local x,y,z = vRPclient.getPosition(source)
			vehicle,vnetid,placa = vRPclient.vehList(source,7)
			TriggerEvent('Garagem:ServerDespawnVeh', source,{placa = placa or nil})
		end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REPARAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("tryreparar")
AddEventHandler("tryreparar",function(nveh)
	TriggerClientEvent("syncreparar",-1,nveh)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MOTOR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("trymotor")
AddEventHandler("trymotor",function(nveh)
	TriggerClientEvent("syncmotor",-1,nveh)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVELIVERY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('savelivery',function(source,args,rawCommand)
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"mecanico.permissao") then
		local vehicle,vnetid,placa,vname = vRPclient.vehList(source,7)
		if vehicle and placa then
			local puser_id = vRP.getUserByRegistration(placa)
			if puser_id then
				local custom = json.decode(vRP.getSData("custom:u"..parseInt(puser_id).."veh_"..vname))
				local livery = GNclient.returnlivery(source,livery)
				custom.liveries = livery
				vRP.setSData("custom:u"..parseInt(puser_id).."veh_"..vname,json.encode(custom))	
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVECOLOR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('savecolor',function(source,args,rawCommand)
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"mecanico.permissao") then
		local vehicle,vnetid,placa,vname = vRPclient.vehList(source,7)
		if vehicle and placa then
			local puser_id = vRP.getUserByRegistration(placa)
			if puser_id then
				local custom = json.decode(vRP.getSData("custom:u"..parseInt(puser_id).."veh_"..vname))
				local r1,g1,b1 = GNclient.returncolor1(source,r,g,b)
				local r2,g2,b2 = GNclient.returncolor2(source,r,g,b)
				custom.customcolor1 = {r1,g1,b1}
				custom.customcolor2 = {r2,g2,b2}
				vRP.setSData("custom:u"..parseInt(puser_id).."veh_"..vname,json.encode(custom))	
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECK LIVERY PERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function vGRGS.CheckLiveryPermission()
	local source = source
	local user_id = vRP.getUserId(source)
	return (vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"mecanico.permissao"))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECK COLOR PERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function vGRGS.CheckColorPermission()
	local source = source
	local user_id = vRP.getUserId(source)
	return (vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"mecanico.permissao"))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HASH
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('hash',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.permissao") then
        local vehassh = GNclient.getHash(source,vehiclehash)
        vRP.prompt(source,"Hash:",""..vehassh)
    end
end)

RegisterCommand('vehs',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if user_id then
		if args[1] and parseInt(args[2]) > 0 then
			local nplayer = vRP.getUserSource(parseInt(args[2]))
			local myvehicles = vRP.query("creative/get_vehicles",{ user_id = parseInt(user_id), vehicle = tostring(args[1]) })
			
			local value = vRP.getUData(parseInt(user_id),"vRP:multas")
			local multas = json.decode(value) or 0
			if multas > 0 then
				TriggerClientEvent("Notify",source,"negado","Você tem multas pendentes.",10000)
				return
			end
			
			if parseInt(os.time()) >= parseInt(myvehicles[1].ipva+24*15*60*60) then
				TriggerClientEvent("Notify",source,"negado","Seu <b>Vehicle Tax</b> está atrasado.",10000)
				local ok = vRP.request(source, "Deseja pagar o IPVA do seu veiculo?", 15)
				if ok then
					vRP.execute("vRP/set_ipva",{ user_id = parseInt(user_id), vehicle = tostring(args[1]), ipva = parseInt(os.time()) })
				end
				return
			end
			
			if vRP.searchReturn(source,user_id) then
				return
			end
			
			if myvehicles[1] then
				if (vRP.vehicleType(tostring(args[1])) == "exclusive" or vRP.vehicleType(tostring(args[1])) == "rental") and not vRP.hasPermission(user_id,"admin.permissao") then
					TriggerClientEvent("Notify",source,"negado","<b>"..vRP.vehicleName(tostring(args[1])).."</b> não pode ser transferido por ser um veículo <b>Exclusivo ou Alugado</b>.",10000)
				else
					local identity = vRP.getUserIdentity(parseInt(args[2]))
					local identity2 = vRP.getUserIdentity(user_id)
					local price = tonumber(sanitizeString(vRP.prompt(source,"Valor:",""),"\"[]{}+=?!_()#@%/\\|,.",false))			
					if vRP.request(source,"Deseja vender um <b>"..vRP.vehicleName(tostring(args[1])).."</b> para <b>"..identity.name.." "..identity.firstname.."</b> por <b>$"..vRP.format(parseInt(price)).."</b> dólares ?",30) then	
						if vRP.request(nplayer,"Aceita comprar um <b>"..vRP.vehicleName(tostring(args[1])).."</b> de <b>"..identity2.name.." "..identity2.firstname.."</b> por <b>$"..vRP.format(parseInt(price)).."</b> dólares ?",30) then
							local vehicle = vRP.query("creative/get_vehicles",{ user_id = parseInt(args[2]), vehicle = tostring(args[1]) })
							if parseInt(price) > 0 then
								if vehicle[1] then
									TriggerClientEvent("Notify",source,"negado","<b>"..identity.name.." "..identity.firstname.."</b> já possui este modelo de veículo.",10000)
									TriggerClientEvent("Notify",nplayer,"negado","Você já possui um <b>"..vRP.vehicleName(tostring(args[1])).."</b> em sua garagem.",10000)
									--TriggerClientEvent("Notify",nplayer,"negado","<b>Você</b> já possui este modelo de veículo.",10000)
									return
								end
								
								local value = vRP.getUData(parseInt(args[2]),"vRP:multas")
								local multas = json.decode(value) or 0
								if multas > 0 and parseInt(args[2]) then
									TriggerClientEvent("Notify",source,"negado","<b>"..identity.name.." "..identity.firstname.."</b> possui multas pendentes.",10000)
									TriggerClientEvent("Notify",nplayer,"negado","Você tem multas pendentes.",10000)
									return
								end
								
								local maxvehs = vRP.query("creative/con_maxvehs",{ user_id = parseInt(args[2]) })
								local maxcars = vRP.query("creative/get_users",{ user_id = parseInt(args[2]) })
								if vRP.hasPermission(parseInt(args[2]),"conce.permissao") then
									if parseInt(maxvehs[1].qtd) >= parseInt(maxcars[1].garagem) + 100 then
										TriggerClientEvent("Notify",source,"importante","<b>"..identity.name.." "..identity.firstname.."</b> atingiu o número máximo de veículos em sua garagem.",8000)
										TriggerClientEvent("Notify",nplayer,"importante","Você atingiu o número máximo de veículos em sua garagem.",8000)
										return
									end
								elseif vRP.hasPermission(parseInt(args[2]),"prata.permissao") then
									if parseInt(maxvehs[1].qtd) >= parseInt(maxcars[1].garagem) + 3 then
										TriggerClientEvent("Notify",source,"importante","<b>"..identity.name.." "..identity.firstname.."</b> atingiu o número máximo de veículos em sua garagem.",8000)
										TriggerClientEvent("Notify",nplayer,"importante","Você atingiu o número máximo de veículos em sua garagem.",8000)
										return
									end
								elseif vRP.hasPermission(parseInt(args[2]),"ouro.permissao") then
									if parseInt(maxvehs[1].qtd) >= parseInt(maxcars[1].garagem) + 6 then
										TriggerClientEvent("Notify",source,"importante","<b>"..identity.name.." "..identity.firstname.."</b> atingiu o número máximo de veículos em sua garagem.",8000)
										TriggerClientEvent("Notify",nplayer,"importante","Você atingiu o número máximo de veículos em sua garagem.",8000)
										return
									end
								elseif vRP.hasPermission(parseInt(args[2]),"platina.permissao") then
									if parseInt(maxvehs[1].qtd) >= parseInt(maxcars[1].garagem) + 20 then
										TriggerClientEvent("Notify",source,"importante","<b>"..identity.name.." "..identity.firstname.."</b> atingiu o número máximo de veículos em sua garagem.",8000)
										TriggerClientEvent("Notify",nplayer,"importante","Você atingiu o número máximo de veículos em sua garagem.",8000)
										return
									end
								else
									if parseInt(maxvehs[1].qtd) >= parseInt(maxcars[1].garagem) then
										TriggerClientEvent("Notify",source,"importante","<b>"..identity.name.." "..identity.firstname.."</b> atingiu o número máximo de veículos em sua garagem.",8000)
										TriggerClientEvent("Notify",nplayer,"importante","Você atingiu o número máximo de veículos em sua garagem.",8000)
										return
									end
								end
								
								if vRP.tryFullPayment(parseInt(args[2]),parseInt(price)) then
									vRP.execute("creative/move_vehicle",{ user_id = parseInt(user_id), nuser_id = parseInt(args[2]), vehicle = tostring(args[1]) })
									
									local custom = vRP.getSData("custom:u"..parseInt(user_id).."veh_"..tostring(args[1]))
									local custom2 = json.decode(custom)
									if custom2 then
										vRP.setSData("custom:u"..parseInt(args[2]).."veh_"..tostring(args[1]),json.encode(custom2))
										vRP.execute("creative/rem_srv_data",{ dkey = "custom:u"..parseInt(user_id).."veh_"..tostring(args[1]) })
									end
									
									local chest = vRP.getSData("chest:u"..parseInt(user_id).."veh_"..tostring(args[1]))
									local chest2 = json.decode(chest)
									if chest2 then
										vRP.setSData("chest:u"..parseInt(args[2]).."veh_"..tostring(args[1]),json.encode(chest2))
										vRP.execute("creative/rem_srv_data",{ dkey = "chest:u"..parseInt(user_id).."veh_"..tostring(args[1]) })
									end
									
									TriggerClientEvent("Notify",source,"sucesso","Você Vendeu <b>"..vRP.vehicleName(tostring(args[1])).."</b> e Recebeu <b>$"..vRP.format(parseInt(price)).."</b> dólares.",20000)
									TriggerClientEvent("Notify",nplayer,"importante","Você recebeu as chaves do veículo <b>"..vRP.vehicleName(tostring(args[1])).."</b> de <b>"..identity2.name.." "..identity2.firstname.."</b> e pagou <b>$"..vRP.format(parseInt(price)).."</b> dólares.",40000)
									vRPclient.playSound(source,"Hack_Success","DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS")
									vRPclient.playSound(nplayer,"Hack_Success","DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS")
									vRP.giveMoney(user_id,parseInt(price))
									SendWebhookMessage(webhookvehs,"```prolog\n[ID]: "..user_id.." "..identity2.name.." "..identity2.firstname.." \n[VENDEU]: "..vRP.vehicleName(tostring(args[1])).." \n[PARA O ID]: "..(args[2]).." "..identity.name.." "..identity.firstname.." \n[VALOR]: $"..vRP.format(parseInt(price)).." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
								end
							else
								TriggerClientEvent("Notify",nplayer,"negado","Dinheiro insuficiente.",8000)
								TriggerClientEvent("Notify",source,"negado","Dinheiro insuficiente.",8000)
							end
						end
					end
				end
			end
		else
			local vehicle = vRP.query("creative/get_vehicle",{ user_id = parseInt(user_id) })
			for k,v in pairs(vehicle) do
				TriggerClientEvent("Notify",source,"importante","<b>Modelo:</b> "..vRP.vehicleName(v.vehicle).." <b>("..v.vehicle..")</b>",20000)
			end
		end
	end
end)
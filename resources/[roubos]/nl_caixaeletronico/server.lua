local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

func = {}
Tunnel.bindInterface("nl_caixaeletronico",func)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local timers = 0
local recompensa = 0
local andamento = false
local dinheirosujo = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCALIDADES
-----------------------------------------------------------------------------------------------------------------------------------------
local caixas = {
	[1] = { ['seconds'] = 60 },
	[2] = { ['seconds'] = 60 },
	[3] = { ['seconds'] = 60 },
	[4] = { ['seconds'] = 60 },
	[5] = { ['seconds'] = 60 },
	[6] = { ['seconds'] = 60 },
	[7] = { ['seconds'] = 60 },
	[8] = { ['seconds'] = 60 },
	[9] = { ['seconds'] = 60 },
	[10] = { ['seconds'] = 60 },
	[11] = { ['seconds'] = 60 },
	[12] = { ['seconds'] = 60 }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------
function emServico()
    local emServico = {}
    for uid,src in pairs(vRP.getUsers()) do
        local user_groups = vRP.getUserGroups(uid)
        for k,v in pairs(user_groups) do
            if k == "LSPD" then
                local data = vRP.getUserDataTable(uid)
                if data.emServico == "LSPD" then
                    emServico[uid] = true
                end
            end
        end
    end
    local servico = vRP.table_size(vRP.table_filter(emServico, function(v, k, t) return v end))
    return servico
end

function criarBlipRoubo(x,y,z)
	for uid,src in pairs(vRP.getUsers()) do
		local user_groups = vRP.getUserGroups(uid)
		for k,v in pairs(user_groups) do
			if k == "LSPD" then
				local data = vRP.getUserDataTable(uid)
				if data.emServico == "LSPD" then
					async(function()
						vRPclient._notify(src,"[911] O roubo começou no <b>Caixa Eletrônico</b>, dirija-se até o local e intercepte os assaltantes.")
						vRPclient.setGPS(src,x,y)
						vRPclient.playSound(src,"Oneshot_Final","MP_MISSION_COUNTDOWN_SOUNDSET")
						TriggerClientEvent('CaixaEletronico:criarBlip',src,x,y,z)
					end)
				end
			end
		end
	end
end

function finalizarRoubo(x,y,z)
	for uid,src in pairs(vRP.getUsers()) do
		local user_groups = vRP.getUserGroups(uid)
		for k,v in pairs(user_groups) do
			if k == "LSPD" then
				local data = vRP.getUserDataTable(uid)
				if data.emServico == "LSPD" then
					async(function()
						vRPclient._notify(src,"[911] O roubo terminou, os assaltantes estão fugindo com o dinheiro!")
					end)
				end
			end
		end
	end
	local coords = {x = x, y = y, z = z}
	TriggerClientEvent('CaixaEletronico:removerBlip',-1)
	andamento = false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKROBBERY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent('CaixaEletronico:IniciarRoubo')
AddEventHandler('CaixaEletronico:IniciarRoubo', function(id,x,y,z,head)
	local source = source
	local user_id = vRP.getUserId(source)
	local policiais = emServico()
	if user_id then

		if policiais < 0 then
			vRPclient._notify(source,"Número insuficiente de policiais no momento.")
		elseif (os.time()-timers) <= 1800 then
			vRPclient._notify(source,"Os caixas estão vazios, aguarde <b>"..parseInt((1800-(os.time()-timers))).." segundos</b> até que os civis depositem dinheiro.")
		else
			andamento = true
			timers = os.time()
			dinheirosujo = {}
			dinheirosujo[user_id] = caixas[id].seconds
			recompensa = parseInt(math.random(5000,15000)/caixas[id].seconds)
			TriggerClientEvent('iniciandocaixaeletronico',source,x,y,z,caixas[id].seconds,head)
			vRPclient._playAnim(source,false,{{"anim@heists@ornate_bank@grab_cash_heels","grab"}},true)

			criarBlipRoubo(x,y,z)

			SetTimeout(caixas[id].seconds*1000,function()
				if andamento then
					andamento = false
					finalizarRoubo(x,y,z)
				end
			end)

		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCELAR ROUBO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent('CaixaEletronico:CancelarRoubo')
AddEventHandler('CaixaEletronico:CancelarRoubo', function()
	local source = source
	if andamento then
		for uid,src in pairs(vRP.getUsers()) do
			local user_groups = vRP.getUserGroups(uid)
			for k,v in pairs(user_groups) do
				if k == "LSPD" then
					local data = vRP.getUserDataTable(uid)
					if data.emServico == "LSPD" then
						async(function()
							vRPclient._notify(src,"[911] O assaltante saiu correndo e deixou tudo para trás.")
						end)
					end
				end
			end
		end
		andamento = false
		TriggerClientEvent('CaixaEletronico:removerBlip',-1)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DAR DINHEIRO
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if andamento then
			for k,v in pairs(dinheirosujo) do
				if v > 0 then
					dinheirosujo[k] = v - 1
					vRP._giveInventoryItem(k,"dinheirosujo",recompensa)
				end
			end
		end
	end
end)
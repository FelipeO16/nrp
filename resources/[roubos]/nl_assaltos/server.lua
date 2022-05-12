local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
nALS = {}
Tunnel.bindInterface("nl_assaltos",nALS)
nALC = Tunnel.getInterface("nl_assaltos","nl_assaltos")
local cfg_mercado = module("vrp_mercado", "cfg/config")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURE AS VARIAVEIS DE ASSALTO NO VRP_MERCADO
local cfg = {
	-- em minutos
	tempoMesmaLoja = 1*60,
	tempoEntreLojas = 20
}

-- Não mexer abaixo
local emAssalto = false
local tempoEspera = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCAIS ROUBO
-----------------------------------------------------------------------------------------------------------------------------------------
local locais = {
}

local locais_c = {
}

Citizen.CreateThread(function()
	local rows = vRP.query("NL/selecionar_mercado_notvenda")
	if #rows > 0 then
		for k,v in pairs(rows) do
			local cfg_a = cfg_mercado.mercado[v.nome]
			table.insert(locais, {nome = v.nome, tempoAssalto = cfg_a.assalto.tempoAssalto, policiais = cfg_a.assalto.policiais})
			table.insert(locais_c, {x = cfg_a.cofre.posicao.x, y = cfg_a.cofre.posicao.y, z = cfg_a.cofre.posicao.z})
		end
	end
	
	Citizen.Wait(1000)
	for uid, src in pairs(vRP.getUsers()) do
		nALC.insertLocais(src, locais_c)
	end
end)

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
	nALC.insertLocais(source, locais_c)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTOS
-----------------------------------------------------------------------------------------------------------------------------------------
function nALS.AssaltoIniciarRoubo(localassalto,cds)
	local source = source
	local user_id = vRP.getUserId(source)
	local policiais = vRP.getUsersByPermission("policia.perm")
	local loja = locais[localassalto]
	if emAssalto then
		TriggerClientEvent("Notify", source, "importante","[ALERTA] Já existe um assalto em andamento")
	elseif #policiais < loja.policiais then
		TriggerClientEvent("Notify", source, "importante","[ALERTA] Número insuficiente de policiais na cidade para iniciar um roubo.")
	elseif loja.horaAssalto and (os.time()-loja.horaAssalto) < cfg.tempoEntreLojas then
		TriggerClientEvent("Notify", source, "importante","[ALERTA] Nenhuma loja pode ser assaltada agora, aguarde <b>"..(os.time()-loja.horaAssalto).."</b> segundos.")
	elseif loja.horaAssalto and (os.time()-loja.horaAssalto) < cfg.tempoMesmaLoja then
		TriggerClientEvent("Notify", source, "importante","[ALERTA] Os cofres estão vazios, aguarde <b>"..(os.time()-loja.horaAssalto).."</b> segundos até que os seguranças retornem com o dinheiro.")
	else
		emAssalto = true
		tempoEspera = os.time()
		nALC._AssaltoIniciarAssalto(source,loja.tempoAssalto, localassalto)
		for k,v in pairs(policiais) do
			local src = vRP.getUserSource(v)
			TriggerClientEvent("Notify", source, "importante","[911] O roubo começou no(a) <b>"..loja.nome.."</b>, dirija-se até o local e intercepte os assaltantes.")
			nALC._AssaltosCriarBlip(src,cds)
			vRPclient.setGPS(src,cds.x, cds.y)
			vRPclient.playSound(src,"HUD_MINI_GAME_SOUNDSET","CHECKPOINT_AHEAD")
		end

		local timer = 0
		while timer < loja.tempoAssalto and emAssalto do
			timer = timer+1
			Citizen.Wait(1000)
		end
		
		if emAssalto then
			for k,v in pairs(policiais) do
				local src = vRP.getUserSource(v)
				TriggerClientEvent("Notify", src, "importante","[911] O roubo terminou, os assaltantes estão fugindo com o dinheiro!")
			end
			TriggerClientEvent("Notify", source, "importante","O roubo terminou, pegue o dinheiro e fuja antes que a policia chegue!")
			nALC.AssaltosRemoverBlip(-1)
			local rows = vRP.query("NL/get_cofre_mercado", {nome = loja.nome})
			local cofre = rows[1]
			local last_cofre = 0
			cofre = cofre.cofre
			if cofre > 0 then
				last_cofre = math.floor(cofre*0.3)
				cofre = math.ceil(cofre*0.7)
			end
			TriggerClientEvent("Notify", source, "importante","Você recebeu "..cofre.." de dinheiro sujo")
			vRP.execute("NL/set_cofre_mercado", {nome = loja.nome, cofre = last_cofre})
			TriggerClientEvent("DropSystem:dropCoords", source, "dinheirosujo", cofre, cds)
			locais[localassalto].horaAssalto = os.time()
			emAssalto = false
		end
	end
end

function nALS.AssaltoCancelarRoubo()
	local source = source
	if emAssalto then
		local policiais = vRP.getUsersByPermission("policia.perm")
		for k,v in pairs(policiais) do
			local src = vRP.getUserSource(v)
			vRPclient._notify(src,"[911] O assaltante saiu correndo e deixou tudo para trás.")
		end
		emAssalto = false
		TriggerClientEvent("Notify", source, "importante","O roubo foi cancelado!")
		nALC.AssaltosRemoverBlip(-1)
	end
end
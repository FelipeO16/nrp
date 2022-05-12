local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
emP = {}
Tunnel.bindInterface("vrp_camahospital",emP)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local base = 500

function emP.checkServices()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local paramedicos = vRP.getUsersByPermission("ems.perm")
		if #paramedicos == 0 then
			return true
		end
	end
	return false
end

function emP.doPayment(value)
	value = math.floor(base*(math.floor(value/300*100)/10))
	local user_id = vRP.getUserId(source)
	if vRP.tryFullPayment(user_id, value) then
		return true
	else
		return false
	end
end

function emP.requestBase()
	return base
end
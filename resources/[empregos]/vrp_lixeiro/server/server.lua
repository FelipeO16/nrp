local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPjob = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_lixeiro",vRPjob)
Proxy.addInterface("vrp_lixeiro",vRPjob)

passanger1 = nil
passanger2 = nil
passanger3 = nil

function vRPjob.Permissao()
	local user_id = vRP.getUserId(source)
    return vRP.hasPermission(user_id, "lixo.perm")
end

RegisterServerEvent('vrp_lixeiro:pay')
AddEventHandler('vrp_lixeiro:pay', function(amount)
	local source = source
    local user_id = vRP.getUserId(source)
	local payamount = math.ceil(amount)
	vRP.giveMoney(user_id,tonumber(payamount))
	vRPclient.notify(source, 'Você recebeu '..payamount..' nesta coleta!')
end)

RegisterServerEvent('vrp_lixeiro:binselect')
AddEventHandler('vrp_lixeiro:binselect', function(binpos, platenumber, bagnumb)
	TriggerClientEvent('vrp_lixeiro:setbin', -1, binpos, platenumber,  bagnumb)
end)

RegisterServerEvent('vrp_lixeiro:requestpay')
AddEventHandler('vrp_lixeiro:requestpay', function(platenumber, amount)
	print('recieved request to start pay: '..platenumber.." for "..amount)
	TriggerClientEvent('vrp_lixeiro:startpayrequest', -1, platenumber, amount)
end)

RegisterServerEvent('vrp_lixeiro:bagremoval')
AddEventHandler('vrp_lixeiro:bagremoval', function(platenumber)
	TriggerClientEvent('vrp_lixeiro:removedbag', -1, platenumber)

end)

RegisterServerEvent('vrp_lixeiro:endcollection')
AddEventHandler('vrp_lixeiro:endcollection', function(platenumber)
	TriggerClientEvent('vrp_lixeiro:clearjob', -1, platenumber)
end)

RegisterServerEvent('vrp_lixeiro:reportbags')
AddEventHandler('vrp_lixeiro:reportbags', function(platenumber)
	TriggerClientEvent('vrp_lixeiro:countbagtotal', -1, platenumber)
end)

RegisterServerEvent('vrp_lixeiro:bagsdone')
AddEventHandler('vrp_lixeiro:bagsdone', function(platenumber, bagstopay)
	local source = source
    local user_id = vRP.getUserId(source)
	TriggerClientEvent('vrp_lixeiro:addbags', -1, platenumber, bagstopay, user_id )
end)
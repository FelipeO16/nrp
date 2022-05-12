local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local prop = {}

RegisterServerEvent('DropSystem:create')
AddEventHandler('DropSystem:create', function(props, item, count)
    local name = vRP.getItemName(item)
    prop[props] = {item = item, count = count, name = name}
    TriggerClientEvent('DropSystem:createForAll', -1, props, item, count, name)
end)

RegisterServerEvent('DropSystem:drop')
AddEventHandler('DropSystem:drop', function(prop)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        vRP.giveInventoryItem(user_id,item,count,true)
        TriggerClientEvent('DropSystem:createForAll', -1, prop)
    end
end)

RegisterServerEvent('DropSystem:take')
AddEventHandler('DropSystem:take', function(props, netId)
    local user_id = vRP.getUserId(source)
    if prop[props] ~= nil then
        local new_weight = vRP.getInventoryWeight(user_id)+vRP.getItemWeight(prop[props].item)*prop[props].count
        if new_weight <= vRP.getInventoryMaxWeight(user_id) then
            vRP.giveInventoryItem(user_id,prop[props].item,prop[props].count,true)
            vRPclient.playAnim(source,true,{{"pickup_object","pickup_low",1}},false)
            vRPclient.playSound(source,"HUD_FRONTEND_DEFAULT_SOUNDSET","PICK_UP")
            prop[props] = nil
            TriggerClientEvent('DropSystem:remove', -1, props, netId)
        else
            vRPclient._notify(source, "Inventário cheio")
        end
    end
end)
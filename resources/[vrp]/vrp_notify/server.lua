local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")


RegisterCommand('callback',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    if vRP.hasPermission(user_id,"adm.perm") then
        if args[1] then
        	local id = vRP.getUserSource(parseInt(args[1]))
            local mensagem = vRP.prompt(source,"Mensagem:","")
            if mensagem == "" then
                return
            end
            TriggerClientEvent("NotifyAdmCallback",id,identity.name,mensagem)
        end
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPC = Tunnel.getInterface("vRP")
local webhookchat = "https://discord.com/api/webhooks/920008581040996382/YzJXm4nsNTi8OsXrGDhTsLK93wQYMY7Yj2BtblbwnXYqOQMSrLXDzz03WYQ0WXsRUsKq"

function SendWebhookMessage(webhook,message)
   if webhook ~= "none" then
       PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
   end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vCLIENT = Tunnel.getInterface("chat")
-----------------------------------------------------------------------------------------------------------------------------------------
-- MESSAGEENTERED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("chat:messageEntered")
AddEventHandler("chat:messageEntered",function(message)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local identity = vRP.getUserIdentity(user_id)
		if identity then
			-- TriggerClientEvent("chatMessage",source,identity["name"].." "..identity["firstname"],{100,100,100},"^3"..message)

			-- local players = vRPC.getNearestPlayers(source,35)
			-- for k,v in pairs(players) do
			-- 	async(function()
			-- 		TriggerClientEvent("chatMessage",k,identity["name"].." "..identity["firstname"],{100,100,100},"^3"..message)
			-- 	end)
			-- end
		end
		SendWebhookMessage(webhookchat,"[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[CHAT PROXIMO]: "..message.." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r")
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MENSAGEM NO CHAT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("chat:messageEntered")
AddEventHandler("chat:messageEntered",function(message)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local identity = vRP.getUserIdentity(user_id)
		if identity then
			TriggerClientEvent("chatMessage",source,"#"..user_id.." "..identity["name"].." "..identity["firstname"],{100,100,100},"^3"..message)

			local players = vRPC.getNearestPlayers(source,35)
			for k,v in pairs(players) do
				async(function()
					TriggerClientEvent("chatMessage",k,"#"..user_id.." "..identity["name"].." "..identity["firstname"],{100,100,100},"^3"..message)
				end)
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDFALLBACK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("__cfx_internal:commandFallback")
AddEventHandler("__cfx_internal:commandFallback",function(command)
	local name = GetPlayerName(source)
	if not command or not name then
		return
	end

	CancelEvent()
end)


AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
    local source = source
    Wait(10000)
    TriggerClientEvent('chatMessage',source,"",{255, 0, 50},"@Prefeitura  ^0 Seja bem vindo ao Narnia-RP, tenha um ótimo RP!")
end)


RegisterCommand('911', function(source, args, rawCommand)
    local message = rawCommand:sub(4)
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    fal = identity.name.. " " .. identity.firstname
    if user_id and vRP.hasPermission(user_id,'policia.permissao') then
    TriggerClientEvent('chatMessage',-1,"[NARNIA POLICE DEPARTAMENT] "..identity.name.." "..identity.firstname.. ":",{51, 51, 255},"^0"..message)
end
SendWebhookMessage(webhookchat,"[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[911]: "..message.." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r")
end, false)



RegisterCommand('112', function(source, args, rawCommand)
    local message = rawCommand:sub(4)
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    fal = identity.name.. " " .. identity.firstname
    if user_id and vRP.hasPermission(user_id,'paramedico.permissao')  then
        TriggerClientEvent('chatMessage',-1,"[NARNIA MEDICAL CENTER] "..identity.name.." "..identity.firstname.. ":",{255, 51, 102},"^0"..message)
end
    SendWebhookMessage(webhookchat,"[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[112]: "..message.." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r")
end, false)

RegisterCommand('fms', function(source, args, rawCommand)
    local message = rawCommand:sub(4)
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    fal = identity.name.. " " .. identity.firstname
    if user_id and vRP.hasPermission(user_id,'fms.permissao')  then
        TriggerClientEvent('chatMessage',-1,"[NARNIA CUSTOMS] "..identity.name.." "..identity.firstname.. ":",{255, 51, 102},"^0"..message)
end
    SendWebhookMessage(webhookchat,"[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[112]: "..message.." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r")
end, false)

RegisterCommand('fcs', function(source, args, rawCommand)
    local message = rawCommand:sub(4)
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    fal = identity.name.. " " .. identity.firstname
    if user_id and vRP.hasPermission(user_id,'fcs.permissao')  then
        TriggerClientEvent('chatMessage',-1,"[NARNIA MOTOR SPORTS] "..identity.name.." "..identity.firstname.. ":",{255, 51, 102},"^0"..message)
end
    SendWebhookMessage(webhookchat,"[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[112]: "..message.." "..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r")
end, false)


RegisterCommand('clearchat', function(source)
    local user_id = vRP.getUserId(source);
    if user_id ~= nil then
        if vRP.hasPermission(user_id, "admin.permissao") then
            TriggerClientEvent("chat:clear", -1);
        else
            TriggerClientEvent("chat:clear", source);
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STATUSCHAT
-----------------------------------------------------------------------------------------------------------------------------------------
function statusChat(source)
	return vCLIENT.statusChat(source)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPORTS
-----------------------------------------------------------------------------------------------------------------------------------------
-- exports("statusChat",statusChat)
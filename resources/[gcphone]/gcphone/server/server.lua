local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

vRP._prepare("NL/gcphone",[[
    CREATE TABLE IF NOT EXISTS `phone_app_chat` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `channel` varchar(20) NOT NULL,
        `message` varchar(255) NOT NULL,
        `time` timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (`id`)
      ) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;
      
      CREATE TABLE IF NOT EXISTS `phone_calls` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `owner` varchar(10) NOT NULL COMMENT 'Num tel proprio',
        `num` varchar(10) NOT NULL COMMENT 'Num reférence du contact',
        `incoming` int(11) NOT NULL COMMENT 'Défini si on est à l''origine de l''appels',
        `time` timestamp NOT NULL DEFAULT current_timestamp(),
        `accepts` int(11) NOT NULL COMMENT 'Appels accepter ou pas',
        PRIMARY KEY (`id`)
      ) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8;
      
      CREATE TABLE IF NOT EXISTS `phone_messages` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `transmitter` varchar(10) NOT NULL,
        `receiver` varchar(10) NOT NULL,
        `message` varchar(255) NOT NULL DEFAULT '0',
        `time` timestamp NOT NULL DEFAULT current_timestamp(),
        `isRead` int(11) NOT NULL DEFAULT 0,
        `owner` int(11) NOT NULL DEFAULT 0,
        PRIMARY KEY (`id`)
      ) ENGINE=MyISAM AUTO_INCREMENT=106 DEFAULT CHARSET=utf8;
      
      CREATE TABLE IF NOT EXISTS `phone_users_contacts` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `identifier` varchar(60) CHARACTER SET utf8mb4 DEFAULT NULL,
        `number` varchar(10) CHARACTER SET utf8mb4 DEFAULT NULL,
        `display` varchar(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '-1',
        PRIMARY KEY (`id`)
      ) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
      
      CREATE TABLE IF NOT EXISTS `twitter_accounts` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `username` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '0',
        `password` varchar(50) COLLATE utf8mb4_bin NOT NULL DEFAULT '0',
        `avatar_url` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
        PRIMARY KEY (`id`),
        UNIQUE KEY `username` (`username`)
      ) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
      
      CREATE TABLE IF NOT EXISTS `twitter_tweets` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `authorId` int(11) NOT NULL,
        `realUser` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
        `message` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL,
        `time` timestamp NOT NULL DEFAULT current_timestamp(),
        `likes` int(11) NOT NULL DEFAULT 0,
        PRIMARY KEY (`id`),
        KEY `FK_twitter_tweets_twitter_accounts` (`authorId`),
        CONSTRAINT `FK_twitter_tweets_twitter_accounts` FOREIGN KEY (`authorId`) REFERENCES `twitter_accounts` (`id`)
      ) ENGINE=InnoDB AUTO_INCREMENT=170 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      
      CREATE TABLE IF NOT EXISTS `twitter_likes` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `authorId` int(11) DEFAULT NULL,
        `tweetId` int(11) DEFAULT NULL,
        PRIMARY KEY (`id`),
        KEY `FK_twitter_likes_twitter_accounts` (`authorId`),
        KEY `FK_twitter_likes_twitter_tweets` (`tweetId`),
        CONSTRAINT `FK_twitter_likes_twitter_accounts` FOREIGN KEY (`authorId`) REFERENCES `twitter_accounts` (`id`),
        CONSTRAINT `FK_twitter_likes_twitter_tweets` FOREIGN KEY (`tweetId`) REFERENCES `twitter_tweets` (`id`) ON DELETE CASCADE
      ) ENGINE=InnoDB AUTO_INCREMENT=137 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
      
]])

print("[GCPHONE] init gcphone tables")

async(function()
    vRP.execute("NL/gcphone")
end)

math.randomseed(os.time())

function getPhoneRandomNumber()
    local numBase0 = math.random(1000,9999)
	local numBase1 = math.random(0,9999)
	local num = string.format("%04d-%04d",numBase0,numBase1)
	return num
end

function getNumberPhone(identifier)
	local result = MySQL.Sync.fetchAll("SELECT vrp_user_identities.phone FROM vrp_user_identities WHERE vrp_user_identities.user_id = @identifier",{ ['@identifier'] = identifier })
	if result[1] ~= nil then
		return result[1].phone
	end
	return nil
end

function getIdentifierByPhoneNumber(phone_number) 
	local result = MySQL.Sync.fetchAll("SELECT vrp_user_identities.user_id FROM vrp_user_identities WHERE vrp_user_identities.phone = @phone_number",{ ['@phone_number'] = phone_number })
	if result[1] ~= nil then
		return result[1].user_id
	end
	return nil
end

function getPlayerID(source)
	local player = vRP.getUserId(source)
	return player
end

function getIdentifiant(id)
	for _, v in ipairs(id) do
		return v
	end
end

function getOrGeneratePhoneNumber(sourcePlayer,identifier,cb)
	local sourcePlayer = sourcePlayer
	local identifier = identifier
	local myPhoneNumber = getNumberPhone(identifier)
	if myPhoneNumber == '0' or myPhoneNumber == nil then
		repeat
			myPhoneNumber = getPhoneRandomNumber()
			local id = getIdentifierByPhoneNumber(myPhoneNumber)
		until id == nil
		MySQL.Async.insert("UPDATE vrp_user_identities SET phone = @myPhoneNumber WHERE user_id = @identifier",{ ['@myPhoneNumber'] = myPhoneNumber, ['@identifier'] = identifier },function()
			cb(myPhoneNumber)
		end)
	else
		cb(myPhoneNumber)
	end
end

function getContacts(identifier)
	local result = MySQL.Sync.fetchAll("SELECT * FROM phone_users_contacts WHERE phone_users_contacts.identifier = @identifier",{ ['@identifier'] = identifier })
	return result
end

function addContact(source,identifier,number,display)
	local sourcePlayer = tonumber(source)
	MySQL.Async.insert("INSERT INTO phone_users_contacts (`identifier`, `number`,`display`) VALUES(@identifier, @number, @display)",{
		['@identifier'] = identifier,
		['@number'] = number,
		['@display'] = display
	},function()
		notifyContactChange(sourcePlayer,identifier)
	end)
end

function updateContact(source,identifier,id,number,display)
	local sourcePlayer = tonumber(source)
	MySQL.Async.insert("UPDATE phone_users_contacts SET number = @number, display = @display WHERE id = @id",{ 
		['@number'] = number,
		['@display'] = display,
		['@id'] = id
	},function()
		notifyContactChange(sourcePlayer,identifier)
	end)
end

function deleteContact(source,identifier,id)
	local sourcePlayer = tonumber(source)
	MySQL.Sync.execute("DELETE FROM phone_users_contacts WHERE `identifier` = @identifier AND `id` = @id",{
		['@identifier'] = identifier,
		['@id'] = id
	})
	notifyContactChange(sourcePlayer,identifier)
end

function deleteAllContact(identifier)
	MySQL.Sync.execute("DELETE FROM phone_users_contacts WHERE `identifier` = @identifier",{
		['@identifier'] = identifier
	})
end

function notifyContactChange(source,identifier)
	local sourcePlayer = tonumber(source)
	local identifier = identifier
	if sourcePlayer ~= nil then 
		TriggerClientEvent("gcPhone:contactList",sourcePlayer,getContacts(identifier))
	end
end

RegisterServerEvent('gcPhone:addContact')
AddEventHandler('gcPhone:addContact',function(display,phoneNumber)
	local sourcePlayer = tonumber(source)
	local identifier = getPlayerID(source)
	addContact(sourcePlayer,identifier,phoneNumber,display)
end)

RegisterServerEvent('gcPhone:updateContact')
AddEventHandler('gcPhone:updateContact',function(id,display,phoneNumber)
	local sourcePlayer = tonumber(source)
	local identifier = getPlayerID(source)
	updateContact(sourcePlayer,identifier,id,phoneNumber,display)
end)

RegisterServerEvent('gcPhone:deleteContact')
AddEventHandler('gcPhone:deleteContact',function(id)
	local sourcePlayer = tonumber(source)
	local identifier = getPlayerID(source)
	deleteContact(sourcePlayer,identifier,id)
end)

function getMessages(identifier)
	local result = MySQL.Sync.fetchAll("SELECT phone_messages.* FROM phone_messages LEFT JOIN vrp_user_identities ON vrp_user_identities.user_id = @identifier WHERE phone_messages.receiver = vrp_user_identities.phone",{ ['@identifier'] = identifier })
	return result
end

RegisterServerEvent('gcPhone:_internalAddMessage')
AddEventHandler('gcPhone:_internalAddMessage',function(transmitter,receiver,message,owner,cb)
	cb(_internalAddMessage(transmitter,receiver,message,owner))
end)

function _internalAddMessage(transmitter, receiver, message, owner)
	local Query = "INSERT INTO phone_messages (`transmitter`,`receiver`,`message`,`isRead`,`owner`) VALUES(@transmitter,@receiver,@message,@isRead,@owner);"
	local Query2 = 'SELECT * from phone_messages WHERE `id` = (SELECT LAST_INSERT_ID());'
	local Parameters = {
		['@transmitter'] = transmitter,
		['@receiver'] = receiver,
		['@message'] = message,
		['@isRead'] = owner,
		['@owner'] = owner
	}
	return MySQL.Sync.fetchAll(Query .. Query2,Parameters)[1]
end

function addMessage(source,identifier,phone_number,message)
	local sourcePlayer = tonumber(source)
	local otherIdentifier = getIdentifierByPhoneNumber(phone_number)
	local myPhone = getNumberPhone(identifier)
	if otherIdentifier ~= nil and vRP.getUserSource(otherIdentifier) ~= nil then
		local tomess = _internalAddMessage(myPhone,phone_number,message,0)
		TriggerClientEvent("gcPhone:receiveMessage",tonumber(vRP.getUserSource(otherIdentifier)),tomess)
	end
	local memess = _internalAddMessage(phone_number,myPhone,message,1)
	TriggerClientEvent("gcPhone:receiveMessage",sourcePlayer,memess)
end

function setReadMessageNumber(identifier, num)
	local mePhoneNumber = getNumberPhone(identifier)
	MySQL.Sync.execute("UPDATE phone_messages SET phone_messages.isRead = 1 WHERE phone_messages.receiver = @receiver AND phone_messages.transmitter = @transmitter",{ 
		['@receiver'] = mePhoneNumber,
		['@transmitter'] = num
	})
end

function deleteMessage(msgId)
	MySQL.Sync.execute("DELETE FROM phone_messages WHERE `id` = @id",{
		['@id'] = msgId
	})
end

function deleteAllMessageFromPhoneNumber(source,identifier,phone_number)
	local source = source
	local identifier = identifier
	local mePhoneNumber = getNumberPhone(identifier)
	MySQL.Sync.execute("DELETE FROM phone_messages WHERE `receiver` = @mePhoneNumber and `transmitter` = @phone_number",{ ['@mePhoneNumber'] = mePhoneNumber,['@phone_number'] = phone_number })
end

function deleteAllMessage(identifier)
	local mePhoneNumber = getNumberPhone(identifier)
	MySQL.Sync.execute("DELETE FROM phone_messages WHERE `receiver` = @mePhoneNumber",{
		['@mePhoneNumber'] = mePhoneNumber
	})
end

RegisterServerEvent('gcPhone:sendMessage')
AddEventHandler('gcPhone:sendMessage',function(phoneNumber,message)
    local sourcePlayer = tonumber(source)
    local identifier = getPlayerID(source)
    addMessage(sourcePlayer,identifier,phoneNumber,message)
end)

RegisterServerEvent('gcPhone:deleteMessage')
AddEventHandler('gcPhone:deleteMessage',function(msgId)
	deleteMessage(msgId)
end)

RegisterServerEvent('gcPhone:deleteMessageNumber')
AddEventHandler('gcPhone:deleteMessageNumber',function(number)
	local sourcePlayer = tonumber(source)
	local identifier = getPlayerID(source)
	deleteAllMessageFromPhoneNumber(sourcePlayer,identifier,number)
end)

RegisterServerEvent('gcPhone:deleteAllMessage')
AddEventHandler('gcPhone:deleteAllMessage',function()
	local sourcePlayer = tonumber(source)
	local identifier = getPlayerID(source)
	deleteAllMessage(identifier)
end)

RegisterServerEvent('gcPhone:setReadMessageNumber')
AddEventHandler('gcPhone:setReadMessageNumber',function(num)
	local sourcePlayer = tonumber(source)  
	local identifier = getPlayerID(source)
	setReadMessageNumber(identifier,num)
end)

RegisterServerEvent('gcPhone:deleteALL')
AddEventHandler('gcPhone:deleteALL',function()
	local sourcePlayer = tonumber(source)
	local identifier = getPlayerID(source)
	deleteAllMessage(identifier)
	deleteAllContact(identifier)
	appelsDeleteAllHistorique(identifier)
	TriggerClientEvent("gcPhone:contactList",sourcePlayer,{})
	TriggerClientEvent("gcPhone:allMessage",sourcePlayer,{})
	TriggerClientEvent("appelsDeleteAllHistorique",sourcePlayer,{})
end)

local AppelsEnCours = {}
local lastIndexCall = 10

function getHistoriqueCall(num)
	local result = MySQL.Sync.fetchAll("SELECT * FROM phone_calls WHERE phone_calls.owner = @num ORDER BY time DESC LIMIT 120",{ ['@num'] = num })
	return result
end

function sendHistoriqueCall(src,num)
	local histo = getHistoriqueCall(num)
	TriggerClientEvent('gcPhone:historiqueCall',src,histo)
end

function saveAppels(appelInfo)
	if appelInfo.extraData == nil or appelInfo.extraData.useNumber == nil then
		MySQL.Async.insert("INSERT INTO phone_calls (`owner`,`num`,`incoming`,`accepts`) VALUES(@owner,@num,@incoming,@accepts)",{ ['@owner'] = appelInfo.transmitter_num, ['@num'] = appelInfo.receiver_num, ['@incoming'] = 1, ['@accepts'] = appelInfo.is_accepts },function()
			notifyNewAppelsHisto(appelInfo.transmitter_src,appelInfo.transmitter_num)
		end)
	end
	if appelInfo.is_valid == true then
		local num = appelInfo.transmitter_num
		if appelInfo.hidden == true then
			mun = "####-####"
		end
		MySQL.Async.insert("INSERT INTO phone_calls (`owner`, `num`,`incoming`, `accepts`) VALUES(@owner, @num, @incoming, @accepts)",{ ['@owner'] = appelInfo.receiver_num, ['@num'] = num, ['@incoming'] = 0, ['@accepts'] = appelInfo.is_accepts },function()
			if appelInfo.receiver_src ~= nil then
				notifyNewAppelsHisto(appelInfo.receiver_src,appelInfo.receiver_num)
			end
		end)
	end
end

function notifyNewAppelsHisto(src,num)
	sendHistoriqueCall(src,num)
end

RegisterServerEvent('gcPhone:getHistoriqueCall')
AddEventHandler('gcPhone:getHistoriqueCall',function()
	local sourcePlayer = tonumber(source)
	local srcIdentifier = getPlayerID(source)
	local srcPhone = getNumberPhone(srcIdentifier)
	sendHistoriqueCall(sourcePlayer,num)
end)

RegisterServerEvent('gcPhone:internal_startCall')
AddEventHandler('gcPhone:internal_startCall',function(source,phone_number,rtcOffer,extraData)
	local rtcOffer = rtcOffer
	if phone_number == nil or phone_number == '' then
		return
	end

	local hidden = string.sub(phone_number,1,1) == '#'
	if hidden == true then
		phone_number = string.sub(phone_number,2)
	end

	local indexCall = lastIndexCall
	lastIndexCall = lastIndexCall + 1

	local sourcePlayer = tonumber(source)
	local srcIdentifier = getPlayerID(source)
	local srcPhone = ''

	if extraData ~= nil and extraData.useNumber ~= nil then
		srcPhone = extraData.useNumber
	else
		srcPhone = getNumberPhone(srcIdentifier)
	end

	local destPlayer = getIdentifierByPhoneNumber(phone_number)
	local is_valid = destPlayer ~= nil and destPlayer ~= srcIdentifier
	AppelsEnCours[indexCall] = { id = indexCall, transmitter_src = sourcePlayer, transmitter_num = srcPhone, receiver_src = nil, receiver_num = phone_number, is_valid = destPlayer ~= nil, is_accepts = false, hidden = hidden, rtcOffer = rtcOffer, extraData = extraData }
    
	if is_valid == true then
		if vRP.getUserSource(destPlayer) ~= nil then
			srcTo = tonumber(vRP.getUserSource(destPlayer))
			if srcTo ~= nill then
				AppelsEnCours[indexCall].receiver_src = srcTo
				--TriggerEvent('gcPhone:addCall',AppelsEnCours[indexCall])
				TriggerClientEvent('gcPhone:waitingCall',sourcePlayer,AppelsEnCours[indexCall],true)
				TriggerClientEvent('gcPhone:waitingCall',srcTo,AppelsEnCours[indexCall],false)
			else
				--TriggerEvent('gcPhone:addCall',AppelsEnCours[indexCall])
				TriggerClientEvent('gcPhone:waitingCall',sourcePlayer,AppelsEnCours[indexCall],true)
			end
		end
	else
		TriggerEvent('gcPhone:addCall',AppelsEnCours[indexCall])
		TriggerClientEvent('gcPhone:waitingCall',sourcePlayer,AppelsEnCours[indexCall],true)
	end
end)

RegisterServerEvent('gcPhone:startCall')
AddEventHandler('gcPhone:startCall',function(phone_number,rtcOffer,extraData)
	TriggerEvent('gcPhone:internal_startCall',source,phone_number,rtcOffer,extraData)
end)

RegisterServerEvent('gcPhone:candidates')
AddEventHandler('gcPhone:candidates',function(callId,candidates)
	if AppelsEnCours[callId] ~= nil then
		local source = source
		local to = AppelsEnCours[callId].transmitter_src
		if source == to then 
			to = AppelsEnCours[callId].receiver_src
		end
		TriggerClientEvent('gcPhone:candidates',to,candidates)
	end
end)

RegisterServerEvent('gcPhone:acceptCall')
AddEventHandler('gcPhone:acceptCall',function(infoCall,rtcAnswer)
	local id = infoCall.id
	if AppelsEnCours[id] ~= nil then
		AppelsEnCours[id].receiver_src = infoCall.receiver_src or AppelsEnCours[id].receiver_src
		if AppelsEnCours[id].transmitter_src ~= nil and AppelsEnCours[id].receiver_src ~= nil then
			AppelsEnCours[id].is_accepts = true
			AppelsEnCours[id].rtcAnswer = rtcAnswer
			TriggerClientEvent('gcPhone:acceptCall',AppelsEnCours[id].transmitter_src,AppelsEnCours[id],true)
			TriggerClientEvent('gcPhone:acceptCall',AppelsEnCours[id].receiver_src,AppelsEnCours[id],false)
			saveAppels(AppelsEnCours[id])
		end
	end
end)

RegisterServerEvent('gcPhone:rejectCall')
AddEventHandler('gcPhone:rejectCall',function(infoCall)
	local id = infoCall.id
	if AppelsEnCours[id] ~= nil then
		if AppelsEnCours[id].transmitter_src ~= nil then
			TriggerClientEvent('gcPhone:rejectCall',AppelsEnCours[id].transmitter_src)
		end
		if AppelsEnCours[id].receiver_src ~= nil then
			TriggerClientEvent('gcPhone:rejectCall',AppelsEnCours[id].receiver_src)
		end

		if AppelsEnCours[id].is_accepts == false then 
			saveAppels(AppelsEnCours[id])
		end
		TriggerEvent('gcPhone:removeCall',AppelsEnCours)
		AppelsEnCours[id] = nil
	end
end)

RegisterServerEvent('gcPhone:appelsDeleteHistorique')
AddEventHandler('gcPhone:appelsDeleteHistorique',function(numero)
	local sourcePlayer = tonumber(source)
	local srcIdentifier = getPlayerID(source)
	local srcPhone = getNumberPhone(srcIdentifier)
	MySQL.Sync.execute("DELETE FROM phone_calls WHERE `owner` = @owner AND `num` = @num",{
		['@owner'] = srcPhone,
		['@num'] = numero
	})
end)

function appelsDeleteAllHistorique(srcIdentifier)
	local srcPhone = getNumberPhone(srcIdentifier)
	MySQL.Sync.execute("DELETE FROM phone_calls WHERE `owner` = @owner",{ ['@owner'] = srcPhone })
end

RegisterServerEvent('gcPhone:appelsDeleteAllHistorique')
AddEventHandler('gcPhone:appelsDeleteAllHistorique',function()
	local sourcePlayer = tonumber(source)
	local srcIdentifier = getPlayerID(source)
	appelsDeleteAllHistorique(srcIdentifier)
end)

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
	local sourcePlayer = tonumber(source)
	local identifier = getPlayerID(source)
	getOrGeneratePhoneNumber(sourcePlayer,identifier,function(myPhoneNumber)
		TriggerClientEvent("gcPhone:myPhoneNumber",sourcePlayer,myPhoneNumber)
		TriggerClientEvent("gcPhone:contactList",sourcePlayer,getContacts(identifier))
		TriggerClientEvent("gcPhone:allMessage",sourcePlayer,getMessages(identifier))
	end)
end)

RegisterServerEvent('gcPhone:allUpdate')
AddEventHandler('gcPhone:allUpdate',function()
	local sourcePlayer = tonumber(source)
	local identifier = getPlayerID(source)
	local num = getNumberPhone(identifier)
	TriggerClientEvent("gcPhone:myPhoneNumber",sourcePlayer,num)
	TriggerClientEvent("gcPhone:contactList",sourcePlayer,getContacts(identifier))
	TriggerClientEvent("gcPhone:allMessage",sourcePlayer,getMessages(identifier))
	sendHistoriqueCall(sourcePlayer,num)
end)

AddEventHandler('onMySQLReady',function()
	MySQL.Async.fetchAll("DELETE FROM phone_messages WHERE (DATEDIFF(CURRENT_DATE,time) > 10)")
end)
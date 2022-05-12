local htmlEntities = module("lib/htmlEntities")
local Tools = module("lib/Tools")

RegisterCommand('admin', function(player, choice)
    local user_id = vRP.getUserId(player)
    if user_id then
        local desc = vRP.prompt(player, "Qual seu problema:", "") or ""
        local answered = false
        local players = {}
        for k, v in pairs(vRP.rusers) do
            local player = vRP.getUserSource(tonumber(k))
            if vRP.hasPermission(k, "adm.perm") and player then
                table.insert(players, player)
            end
        end

        for k, v in pairs(players) do
            async(function()
                local ok = vRP.request(v, "Chamada [ID: " .. user_id ..
                                           "] atender: " ..
                                           htmlEntities.encode(desc), 60)
                if ok then
                    if not answered then
                        vRPclient._notify(player, "Pedido aceito")
                        vRPclient._teleport(v, vRPclient.getPosition(player))
                        answered = true
                    else
                        vRPclient._notify(v, "Já foi atendido.")
                    end
                end
            end)
        end
    end
end)

RegisterCommand('addgroup', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if user_id then
        -- if vRP.hasPermission(user_id, "adm.perm") then
        if args[1] and args[2] then
            vRP.addUserGroup(parseInt(args[1]), args[2])
        end
        -- end
    end
end)

RegisterCommand('removegroup', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "adm.perm") then
        if args[1] and args[2] then
            vRP.removeUserGroup(parseInt(args[1]), args[2])
            vRPclient._notify(source, "Emprego: " .. args[2] ..
                                  " foi removido do ID: " .. parseInt(args[1]))
        end
    end
end)

RegisterCommand('wl', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "adm.perm") then
        if args[1] then
            vRP.setWhitelisted(parseInt(args[1]), true)
            vRPclient._notify(source, "Você deu whitelist para o ID: " ..
                                  parseInt(args[1]))
        end
    end
end)

RegisterCommand('unwl', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "adm.perm") then
        if args[1] then
            vRP.setWhitelisted(parseInt(args[1]), false)
            vRPclient._notify(source, "Você tirou a whitelist do ID: " ..
                                  parseInt(args[1]))
        end
    end
end)

RegisterCommand('kick', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "adm.perm") then
        if args[1] then
            local id = vRP.getUserSource(parseInt(args[1]))
            if id then
                vRP.kick(id, "Você foi expulso da cidade.")
                -- saveKickLog(id, GetPlayerName(source), reason)
                vRPclient._notify(source, "Você kickou o ID: " .. id)
            end
        end
    end
end)

RegisterCommand('ban', function(player, choice, args, rawCommand)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and vRP.hasPermission(user_id, "adm.perm") then
        vRP.prompt(player, "User id to ban: ", "", function(player, id)
            id = parseInt(id)
            vRP.prompt(player, "Reason: ", "", function(player, reason)
                local source = vRP.getUserSource(id)
                vRP.prompt(player, "Hours: ", "", function(player, duration)
                    if tonumber(duration) then
                        vRPclient._notify(player, {"banned user " .. id})
                        -- saveBanLog(id,GetPlayerName(player),reason,duration)
                        vRP.ban(source, reason)
                    else
                        vRPclient._notify(player, {"~r~Invalid ban time!"})
                    end
                end)
            end)
        end)
    end
end)

RegisterCommand('unban', function(source, args, rawCommand)
    local user_id = vRP.getUserId(player)
    if user_id and vRP.hasPermission(user_id, "adm.perm") then
        local id = vRP.prompt(player, "User id to unban: ", "")
        id = parseInt(id)
        vRP.setBanned(id, false)
        vRPclient._notify(player, "un-banned user " .. id)
    end
end)

RegisterCommand('coords', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "adm.perm") then
        local x, y, z = vRPclient.getPosition(source)
        vRP.prompt(source, "Cordenadas:",
                   "x = " .. x .. ", y = " .. y .. ", z = " .. z)
    end
end)

RegisterCommand('tpme', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "adm.perm") then
        if args[1] then
            local tplayer = vRP.getUserSource(parseInt(args[1]))
            local x, y, z = vRPclient.getPosition(source)
            if tplayer then vRPclient._teleport(tplayer, x, y, z) end
        end
    end
end)

RegisterCommand('tpto', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "adm.perm") then
        if args[1] then
            local tplayer = vRP.getUserSource(parseInt(args[1]))
            if tplayer then
                vRPclient._teleport(source, vRPclient.getPosition(tplayer))
            end
        end
    end
end)

RegisterCommand('tpcoords', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "adm.perm") then
        local fcoords = vRP.prompt(source, "Cordenadas:", "")
        if fcoords == "" then return end
        local coords = {}
        for coord in string.gmatch(fcoords or "0,0,0", "[^,]+") do
            table.insert(coords, parseInt(coord))
        end
        vRPclient._teleport(source, coords[1] or 0, coords[2] or 0,
                            coords[3] or 0)
    end
end)

RegisterCommand('giveitem', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "adm.perm") then
        if args[1] and args[2] then
            if vRP.getItemDefinition(args[1]) then
                vRP.giveInventoryItem(user_id, args[1], parseInt(args[2]), true)
            else
                vRPclient._notifyError(source, "Esse item não existe")
            end
        end
    end
end)

RegisterCommand('nc', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "adm.perm") then
        vRPclient._toggleNoclip(source)
    end
end)

RegisterCommand('reviver', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "adm.perm") then
        if args[1] then
            local nplayer = vRP.getUserSource(parseInt(args[1]))
            if nplayer then vRPclient._killGod(nplayer) end
        else
            vRPclient._killGod(source)
        end
    end
end)

RegisterCommand('car', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "adm.perm") then
        if args[1] then vRPclient._SpawnCar(source, args[1]) end
    end
end)

RegisterCommand('givemoney', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "adm.perm") then
        if args[1] then vRP.giveMoney(user_id, parseInt(args[1])) end
    end
end)

RegisterCommand('tpway', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, "adm.perm") then vRPclient._tpway(source) end
end)

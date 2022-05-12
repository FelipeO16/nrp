local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPnt = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_nitro",vRPnt)
Proxy.addInterface("vrp_nitro",vRPnt)
GNclient = Tunnel.getInterface("vrp_garagem")

local installedCars = {}

vRP._prepare("vRP/nitro",[[
    CREATE TABLE IF NOT EXISTS nitro_vehicles(
        id_owner INTEGER,
        model VARCHAR(255),
        plate varchar(50) NOT NULL,
        amount int(11) NOT NULL DEFAULT 100,
        CONSTRAINT pk_nitro PRIMARY KEY(id_owner, model)
    )
]])

vRP._prepare("vRP/select_all_nitro","SELECT * FROM nitro_vehicles")
vRP._prepare("vRP/update_amount_nitro","UPDATE nitro_vehicles SET amount = @amount WHERE id_owner = @id_owner and model = @model")
vRP._prepare("vRP/insert_nitro","INSERT INTO nitro_vehicles(id_owner, model, plate, amount) VALUES(@id_owner, @model, @plate, @amount)")
vRP._prepare("vRP/delete_nitro","DELETE FROM nitro_vehicles WHERE id_owner = @id_owner and model = @model")

async(function()
    vRP.execute("vRP/nitro")
end)

function updateVehicles()
    local rows = vRP.query("vRP/select_all_nitro")
    for k,v in pairs(rows) do
        if #rows ~= nil then
            installedCars[v.model] = {plate = v.plate, amount = v.amount}
        end
    end
    TriggerClientEvent('Nitro:syncInstalledVehicles', -1, installedCars)
end

RegisterServerEvent('Nitro:verifyNitro')
AddEventHandler('Nitro:verifyNitro', function()
    local user_id = vRP.getUserId(source)
    local have = vRP.hasPermission(user_id, "#water.>1")
    TriggerClientEvent("Nitro:hasNitro", source, have)
end)

RegisterServerEvent('Nitro:verifyWrench')
AddEventHandler('Nitro:verifyWrench', function()
    local user_id = vRP.getUserId(source)
    local have = vRP.hasPermission(user_id, "#tacos.>1")
    TriggerClientEvent("Nitro:hasWrench", source, have)
end)

function DoesVehicleHaveAOwner(plate)
    local user_id = vRP.Registration(plate)
    if user_id then
        return true
    end
end

RegisterServerEvent('Nitro:InstallNitro')
AddEventHandler('Nitro:InstallNitro', function(model, plate, amount)
    local source = source
    local user_id = vRP.getUserId(source)
    if DoesVehicleHaveAOwner(plate) then
        local id_dono = vRP.getUserByRegistration(plate)
        vRP.tryGetInventoryItem(user_id, "water", 1, true)
        installedCars[model] = {plate = plate, amount = amount}
        vRP.execute("vRP/insert_nitro", {
            id_owner = id_dono,
            model = model,
            plate = plate,
            amount = amount
        })
        TriggerClientEvent('Nitro:syncInstalledVehicles', -1, installedCars)
    else
        vRPclient._notify(source, "Esse veiculo não tem dono!")
    end
end)

RegisterServerEvent('Nitro:UninstallNitro')
AddEventHandler('Nitro:UninstallNitro', function(model, plate)
    local source = source
    local user_id = vRP.getUserId(source)
    if installedCars[model].plate ~= nil then
        if DoesVehicleHaveAOwner(plate) then
            local id_dono = vRP.getUserByRegistration(plate)
            vRP.tryGetInventoryItem(user_id, "tacos", 1, true)
            vRP.execute('vRP/delete_nitro', {
                id_owner = id_dono,
                model = model
            })
            installedCars[model] = nil
            TriggerClientEvent('Nitro:syncInstalledVehicles', -1, installedCars)
        else
            vRPclient._notify(source, "Esse veiculo não tem dono!")
        end
    end
end)

RegisterServerEvent('Nitro:UpdateNitroAmount')
AddEventHandler('Nitro:UpdateNitroAmount', function(model, plate, amount)
    local user_id = vRP.getUserByRegistration(plate)
    if DoesVehicleHaveAOwner(plate) then
        if installedCars[model].plate == plate then
            installedCars[model].amount = (amount)
            vRP.execute("vRP/update_amount_nitro", {id_owner = user_id, model = model, amount = amount})
        end
    else
        if installedCars[model].plate == plate then
            installedCars[model].amount = (amount)
        end
    end
end)

AddEventHandler('vRP:playerSpawn', function(user_id, source, first_spawn) 
    if user_id then
        updateVehicles(source)
    end
end)
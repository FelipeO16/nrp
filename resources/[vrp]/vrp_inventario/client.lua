local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_inventario",src)
Proxy.addInterface("vrp_inventario",src)

JBserver = Tunnel.getInterface("vrp_inventario","vrp_inventario")

local vehFront = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        if IsControlJustPressed(0, 10) and GetLastInputMethod(0) then
            vehFront = vRP.getNearestVehicle(3)
            if vehFront and GetVehicleDoorLockStatus(vehFront) == 1 then
				if not JBserver.vehicleApreendido() then
                    SetVehicleDoorOpen(vehFront, 5, false, false)
                    TriggerServerEvent("Inventario:abrirBauCar")
				else
					vRP.notify("Veiculo Apreendido!")
				end
            else
               vRP.notify("Não há veículos na frente")
			end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        if IsControlJustPressed(0, 40) then
            TriggerServerEvent("Inventario:pegarInventarioNuser")
        end
		
		if IsControlJustPressed(0, 243) then
			TriggerServerEvent('Inventario:pegarInventario')
		end
    end
end)

function DisplayInput()
    DisplayOnscreenKeyboard(1, "FMMC_MPM_TYP8", "", "", "", "", "", 30)
    while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        Wait(1)
    end
    if GetOnscreenKeyboardResult() then
        return tonumber(GetOnscreenKeyboardResult())
    end
end

RegisterNetEvent('Inventario:enviarInventario')
AddEventHandler('Inventario:enviarInventario', function(inventario, dinheiro, weight, max_weight, hue, identidade)
    TransitionToBlurred(1000)
	SetNuiFocus(true, true)
	SendNUIMessage({
        show = true,
        inventario = inventario,
        dinheiro = dinheiro,
        weight = weight,
        max_weight = max_weight,
        hue = hue,
        identidade = identidade
	})
end)

RegisterNetEvent('Inventario:enviarInventarioNuser')
AddEventHandler('Inventario:enviarInventarioNuser', function(inventario, dinheiro, weight, max_weight, hue, identidade)
    TriggerServerEvent('Inventario:pegarInventario')
    TransitionToBlurred(1000)
	SetNuiFocus(true, true)
	SendNUIMessage({
        nuserBau = true,
        inventarioNuser = inventario,
        dinheiro = dinheiro,
        weight = weight,
        max_weight = max_weight,
        hue = hue,
        identidade = identidade
	})
end)


RegisterNetEvent('Inventario:inventarioSecundario')
AddEventHandler('Inventario:inventarioSecundario', function(InventarioSecundario)
    TriggerServerEvent('Inventario:pegarInventario')
    TransitionToBlurred(1000)
	SetNuiFocus(true, true)
	SendNUIMessage({
        showSecundary = true,
        InventarioSecundario = InventarioSecundario
	})
end)

RegisterNetEvent('Inventario:inventarioSecundarioCar')
AddEventHandler('Inventario:inventarioSecundarioCar', function(InventarioSecundarioCar, quantidadeItens)
    TriggerServerEvent('Inventario:pegarInventario')
    TransitionToBlurred(1000)
	SetNuiFocus(true, true)
	SendNUIMessage({
        showSecundaryCar = true,
        quantidadeItens = quantidadeItens,
        InventarioSecundarioCar = InventarioSecundarioCar
	})
end)

--- USUARIO

RegisterNUICallback('dropar', function(data, cb)
    local idname = data.id
    local idqtd = data.qtd
    TriggerServerEvent('Inventario:dropar', idname, idqtd)
end)

RegisterNUICallback('usar', function(data, cb)
    local idname = data.id
    local idqtd = data.qtd
    TriggerEvent('Inventario:enviarInventario')
    TriggerServerEvent('Inventario:usar', idname, idqtd)
end)

--- USUARIO

RegisterNUICallback('droparBau', function(data, cb)
    local idname = data.id
    local idqtd = data.qtd
    TriggerServerEvent('Homes:guardarNoBau', idname, idqtd)
end)

RegisterNUICallback('droparInv', function(data, cb)
    local idname = data.id
    local idqtd = data.qtd
    TriggerServerEvent('Homes:retirarDoBau', idname, idqtd)
end)

--- CARRO

RegisterNUICallback('droparBauCar', function(data, cb)
    local idname = data.id
    local idqtd = data.qtd
    TriggerServerEvent('Inventario:guardarNoBauCar', idname, idqtd)
end)

RegisterNUICallback('droparInvCar', function(data, cb)
    local idname = data.id
    local idqtd = data.qtd
    TriggerServerEvent('Inventario:retirarDoBauCar', idname, idqtd)
end)

--- ASSALTAR

RegisterNUICallback('droparBauUser', function(data, cb)
    local idname = data.id
    local idqtd = data.qtd
    TriggerServerEvent('Inventario:pegarInventario')
    TriggerServerEvent('Inventario:guardarNoBauUser', idname, idqtd)
end)

RegisterNUICallback('droparInvUser', function(data, cb)
    local idname = data.id
    local idqtd = data.qtd
    TriggerServerEvent('Inventario:retirarDoBauUser', idname, idqtd)
end)

RegisterNUICallback('fechar', function()
    TransitionFromBlurred(1000)
    SetVehicleDoorShut(vehFront, 5, false)
    SetNuiFocus(false, false)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
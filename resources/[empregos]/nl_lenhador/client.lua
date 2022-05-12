local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPserver = Tunnel.getInterface("vRP")
emP = Tunnel.getInterface("lenhador_coletar")
-----------------------------------------------------------------------------------------------------------------------------------------
-- Variaveis
-----------------------------------------------------------------------------------------------------------------------------------------
local click = false
local processo = false
local etapa = 1
local segundos = 0
local list = {}
local refinamento = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- Peds e Blips
-----------------------------------------------------------------------------------------------------------------------------------------
local peds = {
    {x = -471.108, y = 5304.714, z = 84.980, nome = "Celso Portioli", heading = 157.175, hash = 0xA956BD9E, model = "s_m_m_gaffer_01", tipo = "Refinamento"},
    {x = 1167.661, y = -1347.221, z = 33.915, nome = "Carlos Milagres", heading = 272.239, hash = 0xA956BD9E, model = "s_m_m_gaffer_01", tipo = "Comprador"}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- Arvores
-----------------------------------------------------------------------------------------------------------------------------------------
local arvores = {
	{ index = 1, x = -491.592, y = 5394.765, z = 77.385 },
	{ index = 2, x = -504.143, y = 5391.011, z = 75.784 },
	{ index = 3, x = -500.382, y = 5400.503, z = 75.170 },
}

local pontosDeRefinamento = {
    [1] = {
        ["coord"] = { x = -476.221, y = 5304.649, z = 85.785 },
        ["rot"] = { x = -15.0, y = 0.0, z = 70.0 }
    },
    [2] = {
        ["coord"] = { x = -487.199, y = 5308.811, z = 82.855 },
        ["rot"] = { x = -15.0, y = 0.0, z = 70.0 }
    },
    [3] = {
        ["coord"] = { x = -509.524, y = 5317.082, z = 82.833 },
        ["rot"] = { x = 0.0, y = 0.0, z = 70.0 }
    },
    [4] = {
        ["coord"] = { x = -539.199, y = 5327.915, z = 76.747 },
        ["rot"] = { x = -15.0, y = 0.0, z = 70.0 }
    },
    [5] = {
        ["coord"] = { x = -548.625, y = 5331.250, z = 76.640 },
        ["rot"] = { x = 0.0, y = 0.0, z = 70.0 }
    }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- Functions
-----------------------------------------------------------------------------------------------------------------------------------------
function criarPed()
	for _, v in pairs(peds) do
        RequestModel(GetHashKey(v.model))
        while not HasModelLoaded(GetHashKey(v.model)) do
            Wait(1)
        end
        Ped = CreatePed(4, v.hash, v.x, v.y, v.z, 90.604, false, true)
        SetEntityHeading(Ped, v.heading)
        FreezeEntityPosition(Ped, true)
        SetEntityInvincible(Ped, true)
        SetBlockingOfNonTemporaryEvents(Ped, true)    
    end
end

function criarProp()
	Prop = GetHashKey("prop_log_01")
	RequestModel(Prop)
	while not HasModelLoaded(Prop) do
		Citizen.Wait(1)
	end
	local object = CreateObject(Prop, pontosDeRefinamento[1].coord.x, pontosDeRefinamento[1].coord.y, pontosDeRefinamento[1].coord.z, true, true, true)
	PlaceObjectOnGroundProperly(object)
	local network = NetworkGetNetworkIdFromEntity(object)
	return network
end

function lerp(a, b, t)
    return (1 - t) * a + t * b
end

function distancia(vector1, vector2)
    if (vector1 == nil or vector2 == nil) then
       return false
	end

    return math.sqrt(
        math.pow(vector1.x - vector2.x, 2) +
        math.pow(vector1.y - vector2.y, 2) +
        math.pow(vector1.z - vector2.z, 2)
    )
end

function vectorLerp(vector1, vector2, l, clamp)
    if (clamp) then
        if (l < 0.0) then
            l = 0.0
		end

        if (l > 0.0) then
            l = 1.0
		end
    end

    local x = lerp(vector1.x, vector2.x, l)
    local y = lerp(vector1.y, vector2.y, l)
    local z = lerp(vector1.z, vector2.z, l)

    return { x = x, y = y, z = z }
end

function lerpObject(id, to, speed)
    local runTimer = 0
	local dist = 0
	
    FreezeEntityPosition(id, true)

    local pos = GetEntityCoords(id, false)
    dist = distancia(pos, to)
    local objectSpeed = (1.0 / dist) * 0.01 * speed
    runTimer = runTimer + objectSpeed

	local posTick = vectorLerp(pos, to, runTimer, false)
	SetEntityCoords(id,posTick.x,posTick.y,posTick.z)
end

function DrawText3D(x,y,z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text)) / 370
	DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Eventos
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('Lenhador:clickLenhador')
AddEventHandler('Lenhador:clickLenhador', function()
	if emP.verificarRefinamento() then
		local prop = criarProp()
		TriggerServerEvent("Lenhador:iniciarRefinamento", prop)
	end
end)

RegisterNetEvent('Lenhador:clickComprador')
AddEventHandler('Lenhador:clickComprador', function()
	TriggerServerEvent("Lenhador:venderMadeiras")
end)

RegisterNetEvent('Lenhador:atualizarRefinamento')
AddEventHandler('Lenhador:atualizarRefinamento', function(prop)
  refinamento[prop] = true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Threads
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(6)
		if not processo and not vRP.isHandcuffed() then
			for k,v in pairs(arvores) do
				local ped = PlayerPedId()
				local distancia = GetDistanceBetweenCoords(GetEntityCoords(ped),v.x,v.y,v.z)
				if distancia <= 50 and list[v.index] == nil then
					DrawMarker(1, v.x-0.3, v.y+0.8, v.z-1, 0, 0, 0, 0, 0, 0, 2.0001,2.0001,2.0001, 0, 232, 255, 155, 0, 0, 0, 0, 0, 0, 0)
					if distancia <= 1.2 then
						DrawText3D(v.x, v.y, v.z+0.4, "~g~[E] ~w~Para cortar")
						if IsControlJustPressed(0,38) then
							if GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_HATCHET") or GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_BATTLEAXE") then
								list[v.index] = true
								processo = true
								segundos = 5
								vRP._playAnim(true,{{"melee@hatchet@streamed_core","plyr_front_takedown_b"}},true)
							end
						end
					end
				else
					Citizen.Wait(50)
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		for k,v in pairs(refinamento) do
			local ped = PlayerPedId()
    		local pedCoord = GetEntityCoords(ped)
			local ItemProp = GetClosestObjectOfType(pedCoord["x"], pedCoord["y"], pedCoord["z"], 100.0, GetHashKey("prop_log_01"), true, false, false)
			if DoesEntityExist(ItemProp) then
				local ObjectNet = ObjToNet(ItemProp)
				local propCoord = GetEntityCoords(ItemProp, false)
				if etapa == 1 then
					SetEntityRotation(ItemProp, pontosDeRefinamento[2].rot.x,pontosDeRefinamento[2].rot.y,pontosDeRefinamento[2].rot.z , 0, false)
					lerpObject(ItemProp, pontosDeRefinamento[2].coord, 2.00)
					local distancia = GetDistanceBetweenCoords(propCoord.x, propCoord.y, propCoord.z, pontosDeRefinamento[2].coord.x, pontosDeRefinamento[2].coord.y, pontosDeRefinamento[2].coord.z, true)
					if distancia <= 0.05 then
						etapa = 3
					end
				elseif etapa == 3 then
					SetEntityRotation(ItemProp, pontosDeRefinamento[3].rot.x,pontosDeRefinamento[3].rot.y,pontosDeRefinamento[3].rot.z , 0, false)
					lerpObject(ItemProp, pontosDeRefinamento[3].coord, 2.00)
					local distancia = GetDistanceBetweenCoords(propCoord.x, propCoord.y, propCoord.z, pontosDeRefinamento[3].coord.x, pontosDeRefinamento[3].coord.y, pontosDeRefinamento[3].coord.z, true)
					if distancia <= 0.05 then
						etapa = 4
					end
				elseif etapa == 4 then
					SetEntityRotation(ItemProp, pontosDeRefinamento[4].rot.x,pontosDeRefinamento[4].rot.y,pontosDeRefinamento[4].rot.z , 0, false)
					lerpObject(ItemProp, pontosDeRefinamento[4].coord, 2.00)
					local distancia = GetDistanceBetweenCoords(propCoord.x, propCoord.y, propCoord.z, pontosDeRefinamento[4].coord.x, pontosDeRefinamento[4].coord.y, pontosDeRefinamento[4].coord.z, true)
					if distancia <= 0.05 then
						etapa = 5
					end
				elseif etapa == 5 then
					SetEntityRotation(ItemProp, pontosDeRefinamento[5].rot.x,pontosDeRefinamento[5].rot.y,pontosDeRefinamento[5].rot.z , 0, false)
					lerpObject(ItemProp, pontosDeRefinamento[5].coord, 2.00)
					local distancia = GetDistanceBetweenCoords(propCoord.x, propCoord.y, propCoord.z, pontosDeRefinamento[5].coord.x, pontosDeRefinamento[5].coord.y, pontosDeRefinamento[5].coord.z, true)
					if distancia <= 5 then
						etapa = 1
						emP.enviarItem()
						DeleteObject(NetToObj(ObjectNet))
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if processo then
			if segundos > 0 then
				segundos = segundos - 1
				if segundos == 0 then
					emP.checkPayment()
					processo = false
					vRP._stopAnim(false)
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(180000)
		list = {}
	end
end)

Citizen.CreateThread(function()
	criarPed()
end)
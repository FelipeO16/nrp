local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local cfg = module("yang_elevador","config")
vRP = Proxy.getInterface("vRP")

local vELC = {}
Tunnel.bindInterface("vrp_elevador",vELC)
local vELS = Tunnel.getInterface("vrp_elevador","vrp_elevador")

local dentro = nil
local ped = nil
local teleport = cfg

Citizen.CreateThread(function()
	SetNuiFocus(false)
	while true do
		Citizen.Wait(4)
		ped = PlayerPedId()
		local cds = GetEntityCoords(ped)
		for k, v in pairs(teleport) do
			for x, y in pairs(v) do
				local dist = GetDistanceBetweenCoords(cds, vector3(table.unpack(y)), true)
				if dist <= 2.0 and not dentro then
					DrawMarker(27, y[1], y[2], y[3]-1, 0, 0, 0, 0, 0, 0, 1.0001,1.0001,1.0001, 255, 255, 255, 200, 0, 0, 0, 0, 0, 0, 0)
					if IsControlJustPressed(0, 38) then
						dentro = {k,x}
						if x == 1 then x = "T" end
						SendNUIMessage({open = true, title = k..' - '..x, place = k, total = count(v)})
						SetNuiFocus(true, true)
					end
				elseif dentro and dentro[1] == k and dentro[2] == x and dist > 2.2 and dentro then
					dentro = false
					SendNUIMessage({open = false})
				end
			end
		end
	end
end)

function count(tbl)
	local a = 0
	if type(tbl) == "table" then
		for k, v in pairs(tbl) do
			a = a+1
		end
	end
	return a
end

RegisterNUICallback('fechar', function(data, cb)
	dentro = false
	SetNuiFocus(false)
end)

RegisterNUICallback('teleporte', function(data, cb)
	SetNuiFocus(false)
	if dentro[2] ~= data.andar then
		local cd = teleport[data.place][data.andar]
		DoScreenFadeOut(0)
		Citizen.Wait(100)
		SetEntityCoordsNoOffset(ped, cd[1], cd[2], cd[3], 0.0, 0.0, 0.0)
		DoScreenFadeIn(2000)
	end
	dentro = false
end)
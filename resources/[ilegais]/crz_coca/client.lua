local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

local l = 0
local g = 0
local permissao = false
local statuses = false
local cocaina = 0
local step = 0
local started = 0
local started1 = 0
local started2 = 0
local started3 = 0
local started4 = 0
local folhas = 0 
local transformando = 0

local estufas = {
	{1931.06,4862.22,47.20,"ESTUFA 1"}, -- estufa 1
	{1901.65,4891.15,47.57,"ESTUFA 1"}, -- estufa 1
	{1936.04,4866.99,46.94,"ESTUFA 2"}, -- estufa 2
	{1906.16,4895.92,48.02,"ESTUFA 2"}, -- estufa 1
	{1942.71,4873.08,46.54,"ESTUFA 3"}, -- estufa 3
	{1912.89,4902.47,48.11,"ESTUFA 3"}, -- estufa 3
	{1950.06,4881.22,46.02,"ESTUFA 4"}, -- estufa 4
	{1920.80,4910.67,48.09,"ESTUFA 4"}, -- estufa 4
	{1954.63,4886.23,45.77,"ESTUFA 5"}, -- estufa 5
	{1925.02,4915.49,47.63,"ESTUFA 5"}, -- estufa 5
	{1958.11,4891.37,45.24,"ESTUFA 6"}, -- estufa 6
	{1929.72,4919.65,47.42,"ESTUFA 6"}, -- estufa 6
	
	
}
local posicoes = {
-- estufa 1 [ 8 ]
	{1928.46,4864.48,47.24},
	{1927.29,4865.71,47.20},
	{1926.29,4866.69,47.17},
	{1924.41,4868.71,47.13},
	{1908.17,4884.52,47.25},
	{1907.14,4885.58,47.28},
	{1905.51,4887.03,47.36},
	{1904.02,4888.55,47.45},
	-- 8
-- estufa 2 [ 8 ]
	{1933.0435791016,4869.1381835938,47.111061096191},
	{1932.1163330078,4870.0610351563,47.099105834961},
	{1930.8226318359,4871.38671875,47.081764221191},
	{1928.8562011719,4873.45703125,47.075748443604},
	{1912.8137207031,4889.2954101563,47.596221923828},
	{1911.7214355469,4890.3549804688,47.655612945557},
	{1910.4632568359,4891.5737304688,47.714317321777},
	{1908.8903808594,4893.0986328125,47.787322998047},
	-- 16
-- estufa 3 [ 4 ]
	{1916.55,4898.57,47.77},
	{1914.45,4900.62,47.96},
	{1917.69,4897.45,47.67},
	{1918.76,4896.37,47.57},
	-- 20
-- estufa 4 [ 8 ]
	{1922.8292236328,4908.18359375,47.88410949707},
	{1924.912109375,4906.0771484375,47.705718994141},
	{1925.7841796875,4905.1323242188,47.611980438232},
	{1926.9937744141,4903.8715820313,47.47492980957},
	{1941.021484375,4889.8203125,46.275196075439},
	{1942.7159423828,4888.1337890625,46.230117797852},
	{1944.2045898438,4886.6899414063,46.192138671875},
	{1945.3428955078,4885.5708007813,46.165458679199},
	-- 28
-- estufa 5 [ 4 ]
	{1950.2022705078,4889.78125,45.703556060791},
	{1949.3500976563,4890.6411132813,45.707141876221},
	{1948.0155029297,4892.0205078125,45.708435058594},
	{1946.1467285156,4893.9501953125,45.750034332275},
	-- 32
-- estufa 6 [ 6 ]
	{1938.6608886719,4910.6274414063,46.162059783936},
	{1940.5964355469,4908.65234375,45.924896240234},
	{1942.7100830078,4906.5234375,45.769744873047},
	{1948.5727539063,4901.01171875,45.417064666748},
	{1950.3703613281,4899.1533203125,45.350521087646},
	{1952.6193847656,4896.8764648438,45.3154296875},
	-- 38
}

l = math.random(1,38)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(3)
		if not permissao then
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1899.79,4925.15,48.81, true) <= 1.0 then	
				DrawText3Ds(1899.79,4925.15,48.81+0.5,"PRESSIONE ~r~E~w~ PARA COMEÇAR A TRABALHAR")
				if IsControlJustPressed(0, 38) and not vRP.isHandcuffed() then		
					TriggerServerEvent('crz_cocaina:permissao')
				end
			end		
		end
		if permissao then
			if IsControlJustPressed(0,246) and not vRP.isHandcuffed() then	
				statuses = not statuses
			end
			if statuses then
				drawTxt(0.452,0.88,1.0,1.0,0.35,"PRESSIONE ~r~U ~w~PARA CANCELAR A MISSÃO",255,255,255,150)
				if l <= 8 then
					drawTxt(0.452,0.90,1.0,1.0,0.45,"VÁ ATÉ A ~g~ESTUFA 1~w~ PARA COLHER",255,255,255,255)
				elseif l >= 9 and l <= 16 then
					drawTxt(0.452,0.90,1.0,1.0,0.45,"VÁ ATÉ A ~g~ESTUFA 2~w~ PARA COLHER",255,255,255,255)
				elseif l >= 17 and l <= 20 then
					drawTxt(0.452,0.90,1.0,1.0,0.45,"VÁ ATÉ A ~g~ESTUFA 3~w~ PARA COLHER",255,255,255,255)
				elseif l >= 21 and l <= 28 then
					drawTxt(0.452,0.90,1.0,1.0,0.45,"VÁ ATÉ A ~g~ESTUFA 4~w~ PARA COLHER",255,255,255,255)
				elseif l >= 29 and l <= 32 then
					drawTxt(0.452,0.90,1.0,1.0,0.45,"VÁ ATÉ A ~g~ESTUFA 5~w~ PARA COLHER",255,255,255,255)
				elseif l >= 33 and l <= 38 then
					drawTxt(0.452,0.90,1.0,1.0,0.45,"VÁ ATÉ A ~g~ESTUFA 6~w~ PARA COLHER",255,255,255,255)
				end
			else
				drawTxt(0.452,0.88,1.0,1.0,0.35,"PRESSIONE ~r~Y ~w~PARA VER A MISSÃO",255,255,255,150)
			end
			for _,v in pairs(estufas) do
				if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), v[1],v[2],v[3], true) <= 1.5 then	
					DrawText3Ds(v[1],v[2],v[3]+0.5,v[4])
				end
			end
			DrawMarker(23, posicoes[l][1],posicoes[l][2],posicoes[l][3]-0.9701, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.5, 13, 232, 255, 50, 0, 0, 2, 0, 0, 0, 0)
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), posicoes[l][1],posicoes[l][2],posicoes[l][3], true) <= 1.0 then	
				DrawText3Ds(posicoes[l][1],posicoes[l][2],posicoes[l][3]+0.5,"PRESSIONE ~r~E~w~ PARA COLHER A PLANTAÇÃO")
				if IsControlJustPressed(0, 38) and not vRP.isHandcuffed() then		
					TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
					Citizen.Wait(10000)
					TriggerServerEvent('crz_cocaina:receberItem')
					ClearPedTasksImmediately(PlayerPedId())
					l = math.random(1,38)
				end
			end	
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- TELEPORTS - ROXOS
-----------------------------------------------------------------------------------------------------------------------------------------
local permitido = false
RegisterNetEvent('crz_cocaina:entrada')
AddEventHandler('crz_cocaina:entrada', function()
	DoScreenFadeOut(1000)
	Citizen.Wait(1500)
	SetEntityCoords(PlayerPedId(), 139.91,-1952.60,19.46)
	Citizen.Wait(1000)
	DoScreenFadeIn(1000)
end)
RegisterNetEvent('crz_cocaina:saida')
AddEventHandler('crz_cocaina:saida', function()
	step = 0
	started = 0
	started1 = 0
	started2 = 0
	started3 = 0
	started4 = 0
	folhas = 0
	DoScreenFadeOut(1000)
	Citizen.Wait(1500)
	SetEntityCoords(PlayerPedId(), 997.00,-3200.69,-36.39)
	Citizen.Wait(1000)
	DoScreenFadeIn(1000)
end)

Citizen.CreateThread(function()
	while true do
		Wait(0)
		--[[if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 997.00,-3200.69,-36.39, true) <= 1.0 then
			DrawText3Ds(997.00,-3200.69,-36.39+0.5,"")
			if IsControlJustPressed(0, 38) and not vRP.isHandcuffed() then		
				TriggerServerEvent('crz_cocaina:entrada')
			end
		end	
		if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 139.91,-1952.60,19.46, true) <= 1.0 then
			DrawText3Ds(139.91,-1952.60,19.46+0.5,"")
			if IsControlJustPressed(0, 38) and not vRP.isHandcuffed() then		
				TriggerEvent('crz_cocaina:saida')
			end
		end]]
		-- ligar maquinario
		if step == 0 and started == 0 then
			-- iniciando step
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1108.16,4938.38,218.64, true) <= 1.0 then
				DrawText3Ds(-1108.16,4938.38,218.64+0.5,"PRESSIONE ~r~E~w~ PARA LIGAR MAQUINA")
				if IsControlJustPressed(0, 38) and not vRP.isHandcuffed() then	
					started = 1 
					TriggerEvent('crz_cocaina:step1')
					Citizen.Wait(15000)
					step = 1
					started = 0
				end
			end	
		elseif step == 1 then
			-- parte step 1
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1111.89,4943.61,218.65, true) <= 1.0 then
				DrawText3Ds(-1111.89,4943.61,218.65+0.5,"PRESSIONE ~r~E~w~ PARA ATIVAR O PROCESSO")
				if IsControlJustPressed(0, 38) and not vRP.isHandcuffed() then	
					started1 = 1
					TriggerEvent('crz_cocaina:step2')
					Citizen.Wait(15000)
					started1 = 0
					step = 2
				end
			end	
		elseif step == 2 and started2 == 0 then
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1106.55,4951.08,218.64, true) <= 1.0 then
				DrawText3Ds(-1106.55,4951.08,218.64+0.5,"PRESSIONE ~r~E~w~ PARA COLOCAR FOLHA DE COCA")
				if IsControlJustPressed(0, 38) and not vRP.isHandcuffed() then	
					--TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
				    --Citizen.Wait(15000)
				    --ClearPedTasksImmediately(PlayerPedId())
					-- PEGAR AS FOLHAS DE COCA DELE.
					TriggerServerEvent('crz_cocaina:quantasfolhas')
				end
			end	
		elseif step == 3 then
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1106.67,4954.62,218.64, true) <= 1.0 then
				DrawText3Ds(-1106.67,4954.62,218.64+0.5,"PRESSIONE ~r~E~w~ PARA ATIVAR A MAQUINA")
				if IsControlJustPressed(0, 38) and not vRP.isHandcuffed() then	
					started3 = 1
					TriggerEvent('crz_cocaina:step4')
					Citizen.Wait(15000)
					started3 = 0
					step = 4
				end
			end	
		elseif step == 4 and started4 == 0 then
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1105.67,4948.05,218.64, true) <= 1.0 then
				DrawText3Ds(-1105.67,4948.05,218.64+0.5,"PRESSIONE ~r~E~w~ PARA COLETAR O PÓ")
				if IsControlJustPressed(0, 38) and not vRP.isHandcuffed() then
					TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
				Citizen.Wait(5000)
				ClearPedTasksImmediately(PlayerPedId())
					TriggerServerEvent('crz_cocaina:prodCocaSj')
				end
			end	
		end
		if step >= 1 then
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1112.29,4939.42,218.64, true) <= 1.0 then
				DrawText3Ds(-1112.29,4939.42,218.64+0.5,"PRESSIONE ~r~E~w~ PARA DESLIGAR AS MAQUINAS")
				if IsControlJustPressed(0, 38) and not vRP.isHandcuffed() then	
					step = 0
					started = 0
					started1 = 0
					started2 = 0
					started3 = 0
					started4 = 0
					folhas = 0
				end
			end	
		end
		if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1107.46,4941.68,218.64, true) <= 1.0 then
			DrawText3Ds(-1107.46,4941.68,218.64+0.5,"PRESSIONE ~r~E~w~ PARA TRANSFORMAR COCAINA")
			if IsControlJustPressed(0, 38) and not vRP.isHandcuffed() then	
				TriggerEvent('crz_cocaina:limpar')
				transformando = 1
				TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
				Citizen.Wait(15000)
				transformando = 0
				ClearPedTasksImmediately(PlayerPedId())
				TriggerServerEvent('crz_cocaina:limparCoca')
			end
		end			
	end
end)

-- mensagens steps
RegisterNetEvent('crz_cocaina:prodstep2')
AddEventHandler('crz_cocaina:prodstep2',function(quantidade)
	folhas = quantidade
	started2 = 1
	TriggerEvent('crz_cocaina:step3', quantidade)
	Citizen.Wait(15000)
	started2 = 0
	step = 3
end)
-- mensagens steps
RegisterNetEvent('crz_cocaina:prodStep4')
AddEventHandler('crz_cocaina:prodStep4',function()
	started4 = 1
	TriggerEvent('crz_cocaina:step5')
	Citizen.Wait(15000)
	TriggerServerEvent('crz_cocaina:enviarItem', folhas)
	PlaySoundFrontend(-1, 'PICK_UP', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
	-- receber item da coca suja
	started2 = 0
	started3 = 0
	started4 = 0
	step = 2
end)


Citizen.CreateThread(function()
	while true do
		Wait(0)
		if step == 1 then
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1108.16,4938.38,218.64, true) <= 1.0 then
				DrawText3Ds(-1108.16,4938.38,218.64+0.5,"MAQUINA ~g~ATIVADA...")
			end
		elseif step == 2 then
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1108.16,4938.38,218.64, true) <= 1.0 then
				DrawText3Ds(-1108.16,4938.38,218.64+0.5,"MAQUINA ~g~ATIVADA...")
			end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1111.89,4943.61,218.65, true) <= 1.0 then
				DrawText3Ds(-1111.89,4943.61,218.65+0.5,"PROCESSO ~g~ATIVADO...")
			end
		elseif step == 3 then
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1014.58,-3198.13,-38.99, true) <= 1.0 then
				DrawText3Ds(1014.58,-3198.13,-38.99+0.5,"MAQUINA ~g~ATIVADA...")
			end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1011.64,-3196.92,-38.99, true) <= 1.0 then
				DrawText3Ds(1011.64,-3196.92,-38.99+0.5,"PROCESSO ~g~ATIVADO...")
			end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1106.55,4951.08,218.64, true) <= 1.0 then
				DrawText3Ds(-1106.55,4951.08,218.64+0.5,"PROCESSO ~g~PREPARADO...")
			end
		elseif step == 4 then
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1014.58,-3198.13,-38.99, true) <= 1.0 then
				DrawText3Ds(1014.58,-3198.13,-38.99+0.5,"MAQUINA ~g~ATIVADA...")
			end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1011.64,-3196.92,-38.99, true) <= 1.0 then
				DrawText3Ds(1011.64,-3196.92,-38.99+0.5,"PROCESSO ~g~ATIVADO...")
			end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1106.55,4951.08,218.64, true) <= 1.0 then
				DrawText3Ds(-1106.55,4951.08,218.64+0.5,"PROCESSO ~g~PREPARADO...")
			end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1106.67,4954.62,218.64, true) <= 1.0 then
				DrawText3Ds(-1106.67,4954.62,218.64+0.5,"MAQUINA ~g~LIGADA...")
			end
		end
	end
end)
RegisterNetEvent('crz_cocaina:limpar')
AddEventHandler('crz_cocaina:limpar',function()
	Citizen.CreateThread(function()
		while transformando == 1 do
			Citizen.Wait(1)
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1107.46,4941.68,218.64, true) <= 1.0 then
				DrawText3Ds(-1107.46,4941.68,218.64+0.5,"TRANSFORMANDO COCAINA.")
			end	
		end
	end)
end)
RegisterNetEvent('crz_cocaina:step1')
AddEventHandler('crz_cocaina:step1',function()
	Citizen.CreateThread(function()
		while started == 1 do
			Citizen.Wait(1)
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1108.16,4938.38,218.64, true) <= 1.0 then
				DrawText3Ds(-1108.16,4938.38,218.64+0.5,"LIGANDO MÁQUINARIO.")
			end	
		end
	end)
end)
RegisterNetEvent('crz_cocaina:step2')
AddEventHandler('crz_cocaina:step2',function()
	Citizen.CreateThread(function()
		while started1 == 1 do
			Citizen.Wait(1)
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1111.89,4943.61,218.65, true) <= 1.0 then
				DrawText3Ds(-1111.89,4943.61,218.65+0.5,"ATIVANDO.")
			end	
		end
	end)
end)
RegisterNetEvent('crz_cocaina:step3')
AddEventHandler('crz_cocaina:step3',function(quantidade)
	Citizen.CreateThread(function()
		while started2 == 1 do
			Citizen.Wait(1)
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1106.55,4951.08,218.64, true) <= 1.0 then
				DrawText3Ds(-1106.55,4951.08,218.64+0.5,"COLOCANDO "..quantidade.." FOLHA DE COCA")
			end	
		end
	end)
end)
RegisterNetEvent('crz_cocaina:step4')
AddEventHandler('crz_cocaina:step4',function()
	Citizen.CreateThread(function()
		while started3 == 1 do
			Citizen.Wait(1)
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1106.67,4954.62,218.64, true) <= 1.0 then
				DrawText3Ds(-1106.67,4954.62,218.64+0.5,"LIGANDO MÁQUINA.")
			end	
		end
	end)
end)

RegisterNetEvent('crz_cocaina:step5')
AddEventHandler('crz_cocaina:step5',function()
	Citizen.CreateThread(function()
		while started4 == 1 do
			Citizen.Wait(1)
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -1105.67,4948.05,218.64, true) <= 1.0 then
				DrawText3Ds(-1105.67,4948.05,218.64+0.5,"PEGANDO PÓ")
			end	
		end
	end)
end)



-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCELANDO MISSÃO
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsControlJustPressed(0,303) and permissao then
			permissao = false
			permitido = false
		end
	end
end)

RegisterNetEvent('crz_cocaina:permissao')
AddEventHandler('crz_cocaina:permissao', function()
	permissao = true
end)

function DrawText3Ds(x,y,z, text)
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

function drawTxt(x,y,width,height,scale,text,r,g,b,a)
    SetTextFont(4)
    SetTextScale(scale,scale)
    SetTextColour(r,g,b,a)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x,y)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DRAWTEXT
-----------------------------------------------------------------------------------------------------------------------------------------
    DrawText3Ds(89.22,-1903.511,21.23+0.5,"DESEMPACOTAR PACOTES DE COCAINA.")
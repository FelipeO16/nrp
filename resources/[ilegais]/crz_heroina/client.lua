-- VARIAVEIS
local step = 0
local started = 0
local started1 = 0 
local started2 = 0
local started3 = 0
local started4 = 0
local started5 = 0
local started6 = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- TELEPORTS - AMARELOS
-----------------------------------------------------------------------------------------------------------------------------------------
local permitido = false
RegisterNetEvent('crz_heroina:entrada')
AddEventHandler('crz_heroina:entrada', function()
	DoScreenFadeOut(1000)
	Citizen.Wait(1500)
	SetEntityCoords(PlayerPedId(), 938.47863769531,-2970.9978027344,8.9242525100708)
	Citizen.Wait(1000)
	DoScreenFadeIn(1000)
end)
RegisterNetEvent('crz_heroina:saida')
AddEventHandler('crz_heroina:saida', function()
	DoScreenFadeOut(1000)
	Citizen.Wait(1500)
	SetEntityCoords(PlayerPedId(), -7.4851222038269,6208.1484375,31.385133743286)
	Citizen.Wait(1000)
	DoScreenFadeIn(1000)
end)

Citizen.CreateThread(function()
	while true do
		Wait(0)
        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), -7.4851222038269,6208.1484375,31.385133743286, true) <= 1.0 then	
            DrawText3Ds(-7.4851222038269,6208.1484375,31.385133743286+0.5,"PRESSIONE ~r~E~w~ PARA ENTRAR NO OFICIO")
            if IsControlJustPressed(0, 38) then		
                TriggerServerEvent('crz_heroina:entrada')
            end
        end	
		if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 938.47863769531,-2970.9978027344,8.9242525100708, true) <= 1.0 then
			DrawText3Ds(938.47863769531,-2970.9978027344,8.9242525100708+0.5,"PRESSIONE ~r~E~w~ PARA SAIR DO OFICIO")
			if IsControlJustPressed(0, 38) then		
				TriggerEvent('crz_heroina:saida')
			end
        end	
    end
end)

-- PRODUOCAO
Citizen.CreateThread(function()
	while true do
		Wait(0)
		-- ligar maquinario
		if step == 0 and started == 0 then
			-- iniciando step
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1490.98,6396.27,20.78, true) <= 1.0 then
				DrawText3Ds(1490.98,6396.27,20.78+0.5,"PRESSIONE ~r~E~w~ PARA LIGAR GERADOR")
				if IsControlJustPressed(0, 38) then	
					started = 1 
					TriggerEvent('crz_heroina:step1')
					Citizen.Wait(20000)
					step = 1
					started = 0
				end
			end
        elseif step == 1 then
			-- iniciando step
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1505.46,6391.87,20.78, true) <= 1.0 then
				DrawText3Ds(1505.46,6391.87,20.78+0.5,"PRESSIONE ~r~E~w~ PARA COLETAR MATERIAL")
				if IsControlJustPressed(0, 38) then	
					started1 = 1 
					TriggerEvent('crz_heroina:step2')
					Citizen.Wait(5000)
					step = 2
					started1 = 0
				end
			end
        elseif step == 2 and started1 == 0 then
			-- iniciando step
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1503.51,6393.45,20.78, true) <= 1.0 then
				DrawText3Ds(1503.51,6393.45,20.78+0.5,"PRESSIONE ~r~E~w~ PARA COLOCAR O MATERIAL NA MESA")
				if IsControlJustPressed(0, 38) then	
					started2 = 1
					TriggerEvent('crz_heroina:step3')
					TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
				    Citizen.Wait(10000)
				    ClearPedTasksImmediately(PlayerPedId())
					Citizen.Wait(5000)
					step = 3
					started2 = 0
				end
			end
        elseif step == 3 and started2 == 0 then
			-- iniciando step
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1498.58,6394.58,20.78, true) <= 1.0 then
				DrawText3Ds(1498.58,6394.58,20.78+0.5,"PRESSIONE ~r~E~w~ PARA SEPARAR O MATERIAL")
				if IsControlJustPressed(0, 38) then	
					started3 = 1 
					TriggerEvent('crz_heroina:step4')
					Citizen.Wait(5000)
					step = 4
					started3 = 0
				end
			end
        elseif step == 4 and started3 == 0 then
			-- iniciando step
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1494.61,6395.40,20.78, true) <= 1.0 then
				DrawText3Ds(1494.61,6395.40,20.78+0.5,"PRESSIONE ~r~E~w~ PARA LAVAR O MATERIAL")
				if IsControlJustPressed(0, 38) then	
					started4 = 1 
					TriggerEvent('crz_heroina:step5')
					Citizen.Wait(5000)
					step = 5
					started4 = 0
				end
			end
        elseif step == 5 and started4 == 0 then
			-- iniciando step
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1493.21,6390.31,21.25, true) <= 1.0 then
				DrawText3Ds(1493.21,6390.31,21.25+0.5,"PRESSIONE ~r~E~w~ PARA ADICIONAR SUBSTANCIAS")
				if IsControlJustPressed(0, 38) then	
					started5 = 1 
					TriggerEvent('crz_heroina:step6')
					Citizen.Wait(5000)
					step = 6
					started5 = 0
				end
            end
        elseif step == 6 and started5 == 0 then
			-- iniciando step
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1490.49,6391.21,20.78, true) <= 1.0 then
				DrawText3Ds(1490.49,6391.21,20.78+0.5,"PRESSIONE ~r~E~w~ PARA EMBALAR")
				if IsControlJustPressed(0, 38) then	
					started6 = 1 
					TriggerEvent('crz_heroina:step7')
                    Citizen.Wait(5000)
                    TriggerServerEvent('crz_heroina:enviarItem')
                    PlaySoundFrontend(-1, 'PICK_UP', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                    started6 = 0
                    step = 1
				end
            end
        end
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(0)
		if step == 1 then
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1490.98,6396.27,20.78, true) <= 1.0 then
				DrawText3Ds(1490.98,6396.27,20.78+0.5,"MAQUINA ~g~ATIVADA.")
            end
        elseif step == 2 then
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1490.98,6396.27,20.78, true) <= 1.0 then
				DrawText3Ds(1490.98,6396.27,20.78+0.5,"MAQUINA ~g~ATIVADA.")
            end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1505.46,6391.87,20.78, true) <= 1.0 then
				DrawText3Ds(1505.46,6391.87,20.78+0.5,"MATERIAL ~g~COLETADO...")
			end
        elseif step == 3 then
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1490.98,6396.27,20.78, true) <= 1.0 then
				DrawText3Ds(1490.98,6396.27,20.78+0.5,"MAQUINA ~g~ATIVADA.")
            end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1505.46,6391.87,20.78, true) <= 1.0 then
				DrawText3Ds(1505.46,6391.87,20.78+0.5,"MATERIAL ~g~COLETADO...")
			end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1502.79,6393.62,20.78, true) <= 1.0 then
				DrawText3Ds(1502.79,6393.62,20.78+0.5,"MATERIAL ~g~NA MESA...")
			end
        elseif step == 4 then
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1490.98,6396.27,20.78, true) <= 1.0 then
				DrawText3Ds(1490.98,6396.27,20.78+0.5,"MAQUINA ~g~ATIVADA.")
            end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1505.46,6391.87,20.78, true) <= 1.0 then
				DrawText3Ds(1505.46,6391.87,20.78+0.5,"MATERIAL ~g~COLETADO...")
			end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1502.79,6393.62,20.78, true) <= 1.0 then
				DrawText3Ds(1502.79,6393.62,20.78+0.5,"MATERIAL ~g~NA MESA...")
			end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1498.58,6394.58,20.78, true) <= 1.0 then
				DrawText3Ds(1498.58,6394.58,20.78+0.5,"MATERIAL ~g~SEPARADO...")
			end
        elseif step == 5 then
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1490.98,6396.27,20.78, true) <= 1.0 then
				DrawText3Ds(1490.98,6396.27,20.78+0.5,"MAQUINA ~g~ATIVADA.")
            end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1505.46,6391.87,20.78, true) <= 1.0 then
				DrawText3Ds(1505.46,6391.87,20.78+0.5,"MATERIAL ~g~COLETADO...")
			end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1502.79,6393.62,20.78, true) <= 1.0 then
				DrawText3Ds(1502.79,6393.62,20.78+0.5,"MATERIAL ~g~NA MESA...")
			end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1498.58,6394.58,20.78, true) <= 1.0 then
				DrawText3Ds(1498.58,6394.58,20.78+0.5,"MATERIAL ~g~SEPARADO...")
			end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1494.61,6395.40,20.78, true) <= 1.0 then
				DrawText3Ds(1494.61,6395.40,20.78+0.5,"MATERIAL ~g~LIMPO...")
			end
        elseif step == 6 then
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1490.98,6396.27,20.78, true) <= 1.0 then
				DrawText3Ds(1490.98,6396.27,20.78+0.5,"MAQUINA ~g~ATIVADA.")
            end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1505.46,6391.87,20.78, true) <= 1.0 then
				DrawText3Ds(1505.46,6391.87,20.78+0.5,"MATERIAL ~g~COLETADO...")
			end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1502.79,6393.62,20.78, true) <= 1.0 then
				DrawText3Ds(1502.79,6393.62,20.78+0.5,"MATERIAL ~g~NA MESA...")
			end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1498.58,6394.58,20.78, true) <= 1.0 then
				DrawText3Ds(1498.58,6394.58,20.78+0.5,"MATERIAL ~g~SEPARADO...")
			end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1494.61,6395.40,20.78, true) <= 1.0 then
				DrawText3Ds(1494.61,6395.40,20.78+0.5,"MATERIAL ~g~LIMPO...")
			end
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1493.21,6390.31,21.25, true) <= 1.0 then
				DrawText3Ds(1493.21,6390.31,21.25+0.5,"SUBSTANCIA ~g~ADICIONADA...")
			end
		end
	end
end)


RegisterNetEvent('crz_heroina:step1')
AddEventHandler('crz_heroina:step1',function()
	Citizen.CreateThread(function()
		while started == 1 do
			Citizen.Wait(1)
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1490.98,6396.27,20.78, true) <= 1.0 then
				DrawText3Ds(1490.98,6396.27,20.78+0.5,"LIGANDO GERADOR.")
			end	
		end
	end)
end)

RegisterNetEvent('crz_heroina:step2')
AddEventHandler('crz_heroina:step2',function()
	Citizen.CreateThread(function()
		while started1 == 1 do
			Citizen.Wait(1)
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1505.46,6391.87,20.78, true) <= 1.0 then
				DrawText3Ds(1505.46,6391.87,20.78+0.5,"PEGANDO MATERIAL.")
			end	
		end
	end)
end)

RegisterNetEvent('crz_heroina:step3')
AddEventHandler('crz_heroina:step3',function()
	Citizen.CreateThread(function()
		while started2 == 1 do
			Citizen.Wait(1)
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1502.79,6393.62,20.78, true) <= 1.0 then
				DrawText3Ds(1502.79,6393.62,20.78+0.5,"COLOCANDO MATERIAL NA MESA.")
			end	
		end
	end)
end)

RegisterNetEvent('crz_heroina:step4')
AddEventHandler('crz_heroina:step4',function()
	Citizen.CreateThread(function()
		while started3 == 1 do
			Citizen.Wait(1)
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1498.58,6394.58,20.78, true) <= 1.0 then
				DrawText3Ds(1498.58,6394.58,20.78+0.5,"SEPARANDO MATERIAL.")
			end	
		end
	end)
end)

RegisterNetEvent('crz_heroina:step5')
AddEventHandler('crz_heroina:step5',function()
	Citizen.CreateThread(function()
		while started4 == 1 do
			Citizen.Wait(1)
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1494.61,6395.40,20.78, true) <= 1.0 then
				DrawText3Ds(1494.61,6395.40,20.78+0.5,"LIMPANDO MATERIAL.")
			end	
		end
	end)
end)

RegisterNetEvent('crz_heroina:step6')
AddEventHandler('crz_heroina:step6',function()
	Citizen.CreateThread(function()
		while started5 == 1 do
			Citizen.Wait(1)
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1493.21,6390.31,21.25, true) <= 1.0 then
				DrawText3Ds(1493.21,6390.31,21.25+0.5,"ADICIONANDO SUBSTANCIA..")
			end	
		end
	end)
end)
RegisterNetEvent('crz_heroina:step7')
AddEventHandler('crz_heroina:step7',function()
	Citizen.CreateThread(function()
		while started6 == 1 do
			Citizen.Wait(1)
			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1490.49,6391.21,20.78, true) <= 1.0 then
				DrawText3Ds(1490.49,6391.21,20.78+0.5,"EMBALANDO..")
			end	
		end
	end)
end)

-- FUNCTION

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

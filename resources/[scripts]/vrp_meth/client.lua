local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
local started = false
local displayed = false
local progress = 0
local CurrentVehicle 
local pause = false
local selection = 0
local quality = 0

local LastCar

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

RegisterNetEvent('vrp_methcar:stop')
AddEventHandler('vrp_methcar:stop', function()
	started = false
	DisplayHelpText("~r~Produção interrompida...")
	FreezeEntityPosition(LastCar, false)
	SetPedIntoVehicle(PlayerPedId(), LastCar, -1)
	SetVehicleDoorShut(LastCar, 2)
end)

RegisterNetEvent('vrp_methcar:notify')
AddEventHandler('vrp_methcar:notify', function(message)
	ShowNotification(message)
end)

RegisterNetEvent('vrp_methcar:startprod')
AddEventHandler('vrp_methcar:startprod', function()
	DisplayHelpText("~g~Iniciando produção")
	started = true
	displayed = false
	FreezeEntityPosition(CurrentVehicle, true)
	ShowNotification("~r~Produção de metanfetamina iniciada")	
	SetPedIntoVehicle(PlayerPedId(), CurrentVehicle, 3)
	SetVehicleDoorOpen(CurrentVehicle, 2)
end)

RegisterNetEvent('vrp_methcar:blowup')
AddEventHandler('vrp_methcar:blowup', function(posx, posy, posz)
	AddExplosion(posx, posy, posz + 2,23, 20.0, true, false, 1.0, true)
	if not HasNamedPtfxAssetLoaded("core") then
		RequestNamedPtfxAsset("core")
		while not HasNamedPtfxAssetLoaded("core") do
			Citizen.Wait(1)
		end
	end
	SetPtfxAssetNextCall("core")
	local fire = StartParticleFxLoopedAtCoord("ent_ray_heli_aprtmnt_l_fire", posx, posy, posz-0.8 , 0.0, 0.0, 0.0, 0.8, false, false, false, false)
	Citizen.Wait(6000)
	StopParticleFxLooped(fire, 0)
end)

RegisterNetEvent('vrp_methcar:smoke')
AddEventHandler('vrp_methcar:smoke', function(posx, posy, posz, bool)
	if bool == 'a' then
		if not HasNamedPtfxAssetLoaded("core") then
			RequestNamedPtfxAsset("core")
			while not HasNamedPtfxAssetLoaded("core") do
				Citizen.Wait(1)
			end
		end
		SetPtfxAssetNextCall("core")
		local smoke = StartParticleFxLoopedAtCoord("exp_grd_flare", posx, posy, posz + 1.7, 0.0, 0.0, 0.0, 2.0, false, false, false, false)
		SetParticleFxLoopedAlpha(smoke, 0.8)
		SetParticleFxLoopedColour(smoke, 0.0, 0.0, 0.0, 0)
		Citizen.Wait(22000)
		StopParticleFxLooped(smoke, 0)
	else
		StopParticleFxLooped(smoke, 0)
	end
end)

RegisterNetEvent('vrp_methcar:drugged')
AddEventHandler('vrp_methcar:drugged', function()
	SetTimecycleModifier("drug_drive_blend01")
	SetPedMotionBlur(PlayerPedId(), true)
	SetPedMovementClipset(PlayerPedId(), "MOVE_M@DRUNK@SLIGHTLYDRUNK", true)
	SetPedIsDrunk(PlayerPedId(), true)
	Citizen.Wait(300000)
	ClearTimecycleModifier()
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		
		playerPed = PlayerPedId()
		local pos = GetEntityCoords(PlayerPedId())
		if IsPedInAnyVehicle(playerPed) then

			CurrentVehicle = GetVehiclePedIsUsing(PlayerPedId())
			car = GetVehiclePedIsIn(playerPed, false)
			LastCar = GetVehiclePedIsUsing(playerPed)
			local model = GetEntityModel(CurrentVehicle)
			local modelName = GetDisplayNameFromVehicleModel(model)
			
			if modelName == 'JOURNEY' and car then
				
				if GetPedInVehicleSeat(car, -1) == playerPed then

					if not started then
						if not displayed then
							DisplayHelpText("Pressione ~INPUT_THROW_GRENADE~ para começar a fazer drogas")
							displayed = true
						end
					end

					if IsControlJustReleased(0, Keys['G']) then
						if IsVehicleSeatFree(CurrentVehicle, 3) then
							TriggerServerEvent('vrp_methcar:start')	
							progress = 0
							pause = false
							selection = 0
							quality = 0
						else
							DisplayHelpText('~r~O carro já está ocupado')
						end
					end
				end

			end
		else
			if started then
				started = false
				displayed = false
				TriggerEvent('vrp_methcar:stop')
				FreezeEntityPosition(LastCar,false)
			end
		end
		
		if started then
			if progress < 96 then
				Citizen.Wait(6000)
				if not pause and IsPedInAnyVehicle(playerPed) then
					progress = progress +  1
					ShowNotification('~r~Produção de metanfetamina: ~g~~h~' .. progress .. '%')
					Citizen.Wait(6000) 
				end
				--
				--   EVENT 1
				--
				if progress > 22 and progress < 24 then
					pause = true
					if selection == 0 then
						ShowNotification('~o~O tubo de propano está vazando, o que você faz?')	
						ShowNotification('~o~1. Conserta usando fita')
						ShowNotification('~o~2. Deixa como está')
						ShowNotification('~o~3. Substitui')
						ShowNotification('~c~Pressione o número da opção que você deseja fazer')
					end
					if selection == 1 then
						ShowNotification('~r~A fita meio que parou o vazamento')
						quality = quality - 3
						pause = false
					end
					if selection == 2 then
						ShowNotification('~r~O tanque de propano explodiu, você estragou tudo ...')
						TriggerServerEvent('vrp_methcar:blow', pos.x, pos.y, pos.z)
						SetVehicleEngineHealth(CurrentVehicle, 0.0)
						quality = 0
						started = false
						displayed = false
						ApplyDamageToPed(PlayerPedId(), 10, false)
					end
					if selection == 3 then
						ShowNotification('~r~Bom trabalho, o tubo não estava em boas condições')
						pause = false
						quality = quality + 5
					end
				end
				--
				--   EVENT 5
				--
				if progress > 30 and progress < 32 then
					pause = true
					if selection == 0 then
						ShowNotification('~o~Você derramou uma garrafa de acetona no chão, o que você faz?')	
						ShowNotification('~o~1. Abra as janelas para se livrar do cheiro')
						ShowNotification('~o~2. Deixa como está')
						ShowNotification('~o~3. Coloque uma máscara com filtro de ar')
						ShowNotification('~c~Pressione o número da opção que você deseja fazer')
					end
					if selection == 1 then
						ShowNotification('~r~Você abriu as janelas para se livrar do cheiro')
						quality = quality - 1
						pause = false
					end
					if selection == 2 then
						ShowNotification('~r~Você ficou chapado por inalar muito acetona')
						pause = false
						TriggerEvent('vrp_methcar:drugged')
					end
					if selection == 3 then
						ShowNotification('~r~Essa é uma maneira fácil de corrigir o problema. Eu acho')
						SetPedPropIndex(playerPed, 1, 26, 7, true)
						pause = false
					end
				end
				--
				--   EVENT 2
				--
				if progress > 38 and progress < 40 then
					pause = true
					if selection == 0 then
						ShowNotification('~o~Metanfetamina torna-se sólido muito rápido, o que você faz?')	
						ShowNotification('~o~1. Aumente a pressão')
						ShowNotification('~o~2. Aumente a temperatura')
						ShowNotification('~o~3. Diminua a pressão')
						ShowNotification('~c~Pressione o número da opção que você deseja fazer')
					end
					if selection == 1 then
						ShowNotification('~r~Você aumentou a pressão e o propano começou a escapar, você diminuiu e está tudo bem por enquanto')
						pause = false
					end
					if selection == 2 then
						ShowNotification('~r~Aumentar a temperatura ajudou...')
						quality = quality + 5
						pause = false
					end
					if selection == 3 then
						ShowNotification('~r~Diminuir a pressão só piorou...')
						pause = false
						quality = quality -4
					end
				end
				--
				--   EVENT 8 - 3
				--
				if progress > 41 and progress < 43 then
					pause = true
					if selection == 0 then
						ShowNotification('~o~You accidentally pour too much acetone, what do you do?')	
						ShowNotification('~o~1. Do nothing')
						ShowNotification('~o~2. Try to sucking it out using syringe')
						ShowNotification('~o~3. Add more lithium to balance it out')
						ShowNotification('~c~Pressione o número da opção que você deseja fazer')
					end
					if selection == 1 then
						ShowNotification('~r~The meth is not smelling like acetone a lot')
						quality = quality - 3
						pause = false
					end
					if selection == 2 then
						ShowNotification('~r~It kind of worked but its still too much')
						pause = false
						quality = quality - 1
					end
					if selection == 3 then
						ShowNotification('~r~You successfully balanced both chemicals out and its good again')
						pause = false
						quality = quality + 3
					end
				end
				--
				--   EVENT 3
				--
				if progress > 46 and progress < 49 then
					pause = true
					if selection == 0 then
						ShowNotification('~o~You found some water coloring, what do you do?')	
						ShowNotification('~o~1. Add it in')
						ShowNotification('~o~2. Put it away')
						ShowNotification('~o~3. Drink it')
						ShowNotification('~c~Pressione o número da opção que você deseja fazer')
					end
					if selection == 1 then
						ShowNotification('~r~Good idea, people like colors')
						quality = quality + 4
						pause = false
					end
					if selection == 2 then
						ShowNotification('~r~Yeah it might destroy the taste of meth')
						pause = false
					end
					if selection == 3 then
						ShowNotification('~r~You are a bit weird and feel dizzy but its all good')
						pause = false
					end
				end
				--
				--   EVENT 4
				--
				if progress > 55 and progress < 58 then
					pause = true
					if selection == 0 then
						ShowNotification('~o~The filter is clogged, what do you do?')	
						ShowNotification('~o~1. Clean it using compressed air')
						ShowNotification('~o~2. Replace the filter')
						ShowNotification('~o~3. Clean it using a tooth brush')
						ShowNotification('~c~Pressione o número da opção que você deseja fazer')
					end
					if selection == 1 then
						ShowNotification('~r~Compressed air sprayed the liquid meth all over you')
						quality = quality - 2
						pause = false
					end
					if selection == 2 then
						ShowNotification('~r~Replacing it was probably the best option')
						pause = false
						quality = quality + 3
					end
					if selection == 3 then
						ShowNotification('~r~This worked quite well but its still kinda dirty')
						pause = false
						quality = quality - 1
					end
				end
				--
				--   EVENT 5
				--
				if progress > 58 and progress < 60 then
					pause = true
					if selection == 0 then
						ShowNotification('~o~You spilled a bottle of acetone on the ground, what do you do?')	
						ShowNotification('~o~1. Open the windows to get rid of the smell')
						ShowNotification('~o~2. Leave it be')
						ShowNotification('~o~3. Put on a mask with airfilter')
						ShowNotification('~c~Pressione o número da opção que você deseja fazer')
					end
					if selection == 1 then
						ShowNotification('~r~You opened the windows to get rid of the smell')
						quality = quality - 1
						pause = false
					end
					if selection == 2 then
						ShowNotification('~r~You got high from inhaling acetone too much')
						pause = false
						TriggerEvent('vrp_methcar:drugged')
					end
					if selection == 3 then
						ShowNotification('~r~Thats an easy way to fix the issue.. I guess')
						SetPedPropIndex(playerPed, 1, 26, 7, true)
						pause = false
					end
				end
				--
				--   EVENT 1 - 6
				--
				if progress > 63 and progress < 65 then
					pause = true
					if selection == 0 then
						ShowNotification('~o~The propane pipe is leaking, what do you do?')	
						ShowNotification('~o~1. Fix using tape')
						ShowNotification('~o~2. Leave it be ')
						ShowNotification('~o~3. Replace it')
						ShowNotification('~c~Pressione o número da opção que você deseja fazer')
					end
					if selection == 1 then
						ShowNotification('~r~The tape kinda stopped the leak')
						quality = quality - 3
						pause = false
					end
					if selection == 2 then
						ShowNotification('~r~The propane tank blew up, you messed up...')
						TriggerServerEvent('vrp_methcar:blow', pos.x, pos.y, pos.z)
						SetVehicleEngineHealth(CurrentVehicle, 0.0)
						quality = 0
						started = false
						displayed = false
						ApplyDamageToPed(PlayerPedId(), 10, false)
						print('Stopped making drugs')
					end
					if selection == 3 then
						ShowNotification('~r~Good job, the pipe wasnt in a good condition')
						pause = false
						quality = quality + 5
					end
				end
				--
				--   EVENT 4 - 7
				--
				if progress > 71 and progress < 73 then
					pause = true
					if selection == 0 then
						ShowNotification('~o~The filter is clogged, what do you do?')	
						ShowNotification('~o~1. Clean it using compressed air')
						ShowNotification('~o~2. Replace the filter')
						ShowNotification('~o~3. Clean it using a tooth brush')
						ShowNotification('~c~Pressione o número da opção que você deseja fazer')
					end
					if selection == 1 then
						ShowNotification('~r~Compressed air sprayed the liquid meth all over you')
						quality = quality - 2
						pause = false
					end
					if selection == 2 then
						ShowNotification('~r~Replacing it was probably the best option')
						pause = false
						quality = quality + 3
					end
					if selection == 3 then
						ShowNotification('~r~This worked quite well but its still kinda dirty')
						pause = false
						quality = quality - 1
					end
				end
				--
				--   EVENT 8
				--
				if progress > 76 and progress < 78 then
					pause = true
					if selection == 0 then
						ShowNotification('~o~You accidentally pour too much acetone, what do you do?')	
						ShowNotification('~o~1. Do nothing')
						ShowNotification('~o~2. Try to sucking it out using syringe')
						ShowNotification('~o~3. Add more lithium to balance it out')
						ShowNotification('~c~Pressione o número da opção que você deseja fazer')
					end
					if selection == 1 then
						ShowNotification('~r~The meth is not smelling like acetone a lot')
						quality = quality - 3
						pause = false
					end
					if selection == 2 then
						ShowNotification('~r~It kind of worked but its still too much')
						pause = false
						quality = quality - 1
					end
					if selection == 3 then
						ShowNotification('~r~You successfully balanced both chemicals out and its good again')
						pause = false
						quality = quality + 3
					end
				end
				--
				--   EVENT 9
				--
				if progress > 82 and progress < 84 then
					pause = true
					if selection == 0 then
						ShowNotification('~o~You need to take a shit, what do you do?')	
						ShowNotification('~o~1. Try to hold it')
						ShowNotification('~o~2. Go outside and take a shit')
						ShowNotification('~o~3. Shit inside')
						ShowNotification('~c~Pressione o número da opção que você deseja fazer')
					end
					if selection == 1 then
						ShowNotification('~r~Good job, you need to work first, shit later')
						quality = quality + 1
						pause = false
					end
					if selection == 2 then
						ShowNotification('~r~While you were outside the glass fell off the table and spilled all over the floor...')
						pause = false
						quality = quality - 2
					end
					if selection == 3 then
						ShowNotification('~r~The air smells like shit now, the meth smells like shit now')
						pause = false
						quality = quality - 1
					end
				end
				--
				--   EVENT 10
				--
				if progress > 88 and progress < 90 then
					pause = true
					if selection == 0 then
						ShowNotification('~o~Do you add some glass pieces to the meth so it looks like you have more of it?')	
						ShowNotification('~o~1. Yes!')
						ShowNotification('~o~2. No')
						ShowNotification('~o~3. What if I add meth to glass instead?')
						ShowNotification('~c~Pressione o número da opção que você deseja fazer')
					end
					if selection == 1 then
						ShowNotification('~r~Now you got few more baggies out of it')
						quality = quality + 1
						pause = false
					end
					if selection == 2 then
						ShowNotification('~r~You are a good drug maker, your product is high quality')
						pause = false
						quality = quality + 1
					end
					if selection == 3 then
						ShowNotification('~r~Thats a bit too much, its more glass than meth but ok')
						pause = false
						quality = quality - 1
					end
				end
				
				if IsPedInAnyVehicle(playerPed) then
					TriggerServerEvent('vrp_methcar:make', pos.x,pos.y,pos.z)
					if not pause then
						selection = 0
						quality = quality + 1
						progress = progress +  math.random(1, 2)
						ShowNotification('~r~Produção de metanfetamina: ~g~~h~' .. progress .. '%')
					end
				else
					TriggerEvent('vrp_methcar:stop')
				end

			else
				TriggerEvent('vrp_methcar:stop')
				progress = 100
				ShowNotification('~r~Produção de metanfetamina: ~g~~h~' .. progress .. '%')
				ShowNotification('~g~~h~Production finished')
				TriggerServerEvent('vrp_methcar:finish', quality)
				FreezeEntityPosition(LastCar, false)
			end	
			
		end
		
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)		
		if pause then
			if IsControlJustReleased(0, Keys['1']) then
				selection = 1
				ShowNotification('~g~Número da opção selecionada 1')
			end
			if IsControlJustReleased(0, Keys['2']) then
				selection = 2
				ShowNotification('~g~Número da opção selecionada 2')
			end
			if IsControlJustReleased(0, Keys['3']) then
				selection = 3
				ShowNotification('~g~Número da opção selecionada 3')
			end
		end

	end
end)

function ShowNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(0,1)
end
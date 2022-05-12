local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
nALC = {}
Tunnel.bindInterface("nl_assaltos",nALC)
nALS = Tunnel.getInterface("nl_assaltos","nl_assaltos")

local tempoAssalto = 0
local emAssalto = false
local localAssalto = nil
local blip = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- GERANDO LOCAL DO ROUBO
-----------------------------------------------------------------------------------------------------------------------------------------
local locais = {}

function nALC.insertLocais(locais_c)
	locais = locais_c
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROTEIRO DO ROUBO
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
        Citizen.Wait(7)
        local ped = PlayerPedId()
        local cds = GetEntityCoords(ped,true)
		if emAssalto then
			local item = locais[localAssalto]
            local distancia = GetDistanceBetweenCoords(item.x,item.y,item.z,cds,true)
            if distancia > 10 then
				nALS._AssaltoCancelarRoubo()
                emAssalto = false
				tempoAssalto = 0
			end
			Citizen.Wait(500)
		else
			for k, v in pairs(locais) do
				local distancia = GetDistanceBetweenCoords(v.x,v.y,v.z,cds,true)	
                while distancia <= 20 do
					cds = GetEntityCoords(ped,true)
					distancia = GetDistanceBetweenCoords(v.x,v.y,v.z,cds,true)	
                    DrawMarker(29,v.x,v.y,v.z,0,0,0,0,0,0,1.0,0.7,1.0,50,150,50,200,1,0,0,1)
                    if distancia <= 1.5 then
                        DisplayHelpText("Aperte ~INPUT_THROW_GRENADE~ para iniciar o roubo")
                        if IsControlJustPressed(0,47) and not IsPedInAnyVehicle(ped,false) and not vRP.isHandcuffed() then
                            if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") or GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then
                                nALS.AssaltoIniciarRoubo(k, v)
                            end
                        end
                    end
					Citizen.Wait(7)
				end
				Citizen.Wait(250)
            end
        end
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTOS
-----------------------------------------------------------------------------------------------------------------------------------------
function nALC.AssaltoIniciarAssalto(tAss,localAss)
    tempoAssalto = tAss
	localAssalto = localAss
	SetEntityHeading(PlayerPedId(),locais[localAss].h)
    emAssalto = true
end

function nALC.AssaltosCriarBlip(cds)
	if not blip then
		blip = AddBlipForCoord(cds)
		SetBlipScale(blip,0.5)
		SetBlipSprite(blip,1)
		SetBlipColour(blip,59)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Roubo em andamento")
		EndTextCommandSetBlipName(blip)
		SetBlipAsShortRange(blip,false)
	end
end

function nALC.AssaltosRemoverBlip()
	if blip and DoesBlipExist(blip) then
		RemoveBlip(blip)
		blip = nil
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONTAGEM + ENTREGA DA RECOMPENSA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	Citizen.Wait(1000)
    while true do
        Citizen.Wait(1000)
        if emAssalto then
			TriggerEvent("mt:missiontext", "Assalto em andamento: ~r~"..tempoAssalto.."s ~w~restantes", 1000)
            tempoAssalto = tempoAssalto - 1
            if tempoAssalto <= 0 then
                emAssalto = false
                ClearPedTasks(PlayerPedId())
            end
        end
    end
end)

AddEventHandler("mt:missiontext", function(text, time)
	ClearPrints()
	SetTextEntry_2("STRING")
	AddTextComponentString(text)
	DrawSubtitleTimed(time, 1)
end)


function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0,0,1,-1)
end
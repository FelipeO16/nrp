local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
emp = Tunnel.getInterface("entrega_coca")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local emservico = false
local quantidade = 0
local statuses = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- GERANDO LOCAL DE ENTREGA
-----------------------------------------------------------------------------------------------------------------------------------------
local entregas = {
	[1] = {x=155.85,y=-43.10,z=67.71},
	[2] = {x=313.35,y=-245.31,z=53.89},
	[3] = {x=-52.17,y=-103.74,z=57.63},
	[4] = {x=-269.36,y=27.27,z=54.65},
	[5] = {x=-598.12,y=5.68,z=43.07},
	[6] = {x=-795.49,y=40.80,z=48.25},
	[7] = {x=-843.95,y=87.22,z=51.96},
	[8] = {x=-831.32,y=-227.58,z=37.09},
	[9] = {x=-682.37,y=-374.73,z=34.15},
	[10] = {x=-295.17,y=-617.44,z=33.31},
	[11] = {x=-553.23,y=-649.75,z=33.08},
	[12] = {x=-934.24,y=-456.49,z=37.15},
	[13] = {x=-1078.39,y=-267.97,z=37.61},
	[14] = {x=-1437.76,y=-412.62,z=35.79},
	[15] = {x=-1669.03,y=-541.66,z=34.98},
	[16] = {x=-1392.47,y=-580.91,z=30.05},
	[17] = {x=-1042.79,y=-387.18,z=37.57},
	[18] = {x=-255.13,y=-756.19,z=32.63},
	[19] = {x=13.42,y=-972.96,z=29.30},
	[20] = {x=257.70,y=-1062.13,z=29.10},
	[21] = {x=792.41,y=-944.58,z=25.55},
	[22] = {x=120.44,y=-926.42,z=29.73},
	[23] = {x=2.53,y=-1127.96,z=28.09},
	[24] = {x=-582.63,y=-867.52,z=25.63},
	[25] = {x=-1047.00,y=-779.63,z=18.93},
	[26] = {x=-1061.55,y=-495.26,z=36.24},
	[27] = {x=-1071.15,y=-433.65,z=36.45},
	[28] = {x=-1203.82,y=-131.74,z=40.70},
	[29] = {x=-932.33,y=326.64,z=71.25},
	[30] = {x=-587.70,y=250.66,z=82.26},
	[31] = {x=-478.28,y=223.87,z=83.02},
	[32] = {x=-310.77,y=226.85,z=87.78},
	[33] = {x=75.20,y=229.06,z=108.70},
	[34] = {x=296.00,y=147.55,z=103.77},
	[35] = {x=978.79,y=-117.71,z=73.99},
	[36] = {x=1187.01,y=-431.18,z=67.02},
	[37] = {x=1260.03,y=-582.09,z=68.88},
	[38] = {x=1360.39,y=-570.32,z=74.22}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- INICIANDO TRABALHO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('entrega_coca:permissao')
AddEventHandler('entrega_coca:permissao',function()
	if not emservico then
		emservico = true
		destino = math.random(1,38)
		quantidade = math.random(1,2)
		CriandoBlip(entregas,destino)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GERANDO ENTREGA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), 1320.66,-748.63,65.98,true) <= 1 then
			DrawText3Ds(1320.66,-748.63,65.98+0.7,"PRESSIONE ~r~E~w~ PARA COMEÇAR O TRAMPO")
            if IsControlJustPressed(0,38) then	
				TriggerEvent('entrega_coca:permissao')
			end
		end
		if emservico then
			local ui = GetMinimapAnchor()
			local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),entregas[destino].x,entregas[destino].y,entregas[destino].z,true)
			if IsControlJustPressed(0,246) then	
				statuses = not statuses
			end
			if statuses then
				drawTxt(ui.right_x+0.0310,ui.bottom_y-0.046,1.0,1.0,0.35,"PRESSIONE ~r~U ~w~PARA CANCELAR O TRAMPO",255,255,255,150)
				drawTxt(ui.right_x+0.0310,ui.bottom_y-0.028,1.0,1.0,0.45,"ENTREGUE ~g~"..quantidade.."~w~ COCAINAS",255,255,255,255)
			else
				drawTxt(ui.right_x+0.0310,ui.bottom_y-0.028,1.0,1.0,0.35,"PRESSIONE ~r~Y ~w~PARA VER O TRAMPO",255,255,255,150)
			end
			if distance <= 50 then
				DrawMarker(21,entregas[destino].x,entregas[destino].y,entregas[destino].z+0.10,0,0,0,0,180.0,130.0,1.0,1.0,1.0,211,176,72,100,1,0,0,1)
				if distance < 3 then
					DrawText3Ds(entregas[destino].x,entregas[destino].y,entregas[destino].z, "[E] ENTREGAR")
                    if IsControlJustPressed(0,86) then
                        destinoantigo = destino
                        RemoveBlip(blip)
                        TriggerServerEvent('entrega_coca:itensReceber', quantidade)
                        while true do
                            if destinoantigo == destino then
                                destino = math.random(1,38)
                            else
                                break
                            end
                            Citizen.Wait(1)
                        end
                        CriandoBlip(entregas,destino)
					end
				end
			end
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCELANDO ENTREGA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if IsControlJustPressed(0,303) and emservico then
			emservico = false
			RemoveBlip(blip)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCOES
-----------------------------------------------------------------------------------------------------------------------------------------

function drawTxt(x,y,width,height,scale,text,r,g,b,a)
    SetTextFont(4)
    SetTextScale(scale,scale)
    SetTextColour(r,g,b,a)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x,y)
end

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

function GetMinimapAnchor()
    local safezone = GetSafeZoneSize()
    local safezone_x = 1.0 / 20.0
    local safezone_y = 1.0 / 20.0
    local aspect_ratio = GetAspectRatio(0)
    local res_x, res_y = GetActiveScreenResolution()
    local xscale = 1.0 / res_x
    local yscale = 1.0 / res_y
    local Minimap = {}
    Minimap.width = xscale * (res_x / (4 * aspect_ratio))
    Minimap.height = yscale * (res_y / 5.674)
    Minimap.left_x = xscale * (res_x * (safezone_x * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.bottom_y = 1.0 - yscale * (res_y * (safezone_y * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.right_x = Minimap.left_x + Minimap.width
    Minimap.top_y = Minimap.bottom_y - Minimap.height
    Minimap.x = Minimap.left_x
    Minimap.y = Minimap.top_y
    Minimap.xunit = xscale
    Minimap.yunit = yscale
    return Minimap
end

function CriandoBlip(entregas,destino)
	blip = AddBlipForCoord(entregas[destino].x,entregas[destino].y,entregas[destino].z)
	SetBlipSprite(blip,1)
	SetBlipColour(blip,5)
	SetBlipScale(blip,0.7)
	SetBlipAsShortRange(blip,false)
	SetBlipRoute(blip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Entrega de Cocaina")
	EndTextCommandSetBlipName(blip)
end
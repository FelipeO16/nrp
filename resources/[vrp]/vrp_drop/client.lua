---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Variáveis
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local dropList = {}
local pegando = {}

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Funções
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function getProps(item)
  local props = {
    water = "prop_ld_flow_bottle",
    tacos = "ng_proc_food_bag02a",
    dinheiro = "prop_cash_pile_01",
    pilulas = "prop_cs_pills",
    donut = "prop_donut_02",
    tronco = "prop_fncwood_16e",
    madeira_refinada = "prop_rub_planks_01",
    dinheirosujo = "prop_poly_bag_money",
    -- Armas
    ["wbody|WEAPON_PISTOL"] = "w_pi_pistol",
    ["wbody|WEAPON_CARBINERIFLE"] = "w_ar_carbinerifle",
    ["wbody|WEAPON_BAT"] = "p_cs_bbbat_01",
    -- Munição
    ["wammo|WEAPON_PISTOL"] = "w_pi_pistol_mag1"
  }
  if props[item] then 
    return props[item]
  else 
    return 'prop_paper_bag_small'
  end
end

function SetPropOnGround(item)
  x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
  Prop = GetHashKey(getProps(item))
  RequestModel(Prop)
  while not HasModelLoaded(Prop) do
    Citizen.Wait(1)
  end
  local object = CreateObject(Prop, x, y, z, true, false, false)
  PlaceObjectOnGroundProperly(object)
  local network = NetworkGetNetworkIdFromEntity(object)
  return network
end

function SetPropOnGroundCoords(item, coords)
  Prop = GetHashKey(getProps(item))
  RequestModel(Prop)
  while not HasModelLoaded(Prop) do
    Citizen.Wait(1)
  end
  local object = CreateObject(Prop, coords.x, coords.y, coords.z, true, false, false)
  PlaceObjectOnGroundProperly(object)
  local network = NetworkGetNetworkIdFromEntity(object)
  return network
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

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Eventos
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('DropSystem:drop')
AddEventHandler('DropSystem:drop', function(item, amount)
  local props = SetPropOnGround(item)
  TriggerServerEvent('DropSystem:create', props, item, amount)
end)

RegisterNetEvent('DropSystem:dropCoords')
AddEventHandler('DropSystem:dropCoords', function(item, amount, coords)
  local props = SetPropOnGroundCoords(item, coords)
  TriggerServerEvent('DropSystem:create', props, item, amount)
end)

RegisterNetEvent('DropSystem:remove')
AddEventHandler('DropSystem:remove', function(prop, netId)
  if dropList[prop] ~= nil then
    dropList[prop] = nil
    if NetworkHasControlOfNetworkId(netId) then
      DeleteObject(NetToObj(netId))
    end
  end
end)

RegisterNetEvent('DropSystem:createForAll')
AddEventHandler('DropSystem:createForAll', function(prop, item, count, name)
  dropList[prop] = {status = true, item = item, count = count, name = name}
end)

Citizen.CreateThread(function()
  while true do
    local ped = PlayerPedId()
    local pedCoord = GetEntityCoords(ped)
    for k,v in pairs(dropList) do
      if DoesObjectOfTypeExistAtCoords(pedCoord["x"], pedCoord["y"], pedCoord["z"], 1.0, GetHashKey(getProps(v.item)), false) then
        local ItemProp = GetClosestObjectOfType(pedCoord["x"], pedCoord["y"], pedCoord["z"], 1.0, GetHashKey(getProps(v.item)), true, false, false)
        if DoesEntityExist(ItemProp) then
          local ObjectNet = ObjToNet(ItemProp)
          local propCoord = GetEntityCoords(ItemProp)
          if (ObjectNet == k) then
            if (v.name == "Dinheiro") then
              DrawText3D(propCoord.x, propCoord.y, propCoord.z+0.4, "~g~[E] ~w~"..v.name.." - ~g~$"..v.count)
            elseif (v.name == "Dinheiro Sujo") then
              DrawText3D(propCoord.x, propCoord.y, propCoord.z+0.4, "~g~[E] ~w~"..v.name.." - ~r~$"..v.count)
            else
              DrawText3D(propCoord.x, propCoord.y, propCoord.z+0.4, "~g~[E] ~w~"..v.name.." - "..v.count)
            end
            if (IsControlJustPressed(1,38) and pegando[k] == nil) then
              pegando[k] = true
              if pegando[k] then
                SetTimeout(200,function()
                  TriggerServerEvent('DropSystem:take', k, ObjectNet)
                  pegando[k] = nil
                end)
              else
                return false
              end
            end
          end
        end
      end
    end
    Citizen.Wait(0)
  end
end)
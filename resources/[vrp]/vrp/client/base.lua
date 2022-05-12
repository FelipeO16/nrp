cfg = module("cfg/client")
teleport = module("cfg/teleport")

local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local Tools = module("vrp", "lib/Tools")

tvRP = {}
local players = {} -- keep track of connected players (server id)

-- bind client tunnel interface
Tunnel.bindInterface("vRP", tvRP)

-- get server interface
vRPserver = Tunnel.getInterface("vRP")

-- add client proxy interface (same as tunnel interface)
Proxy.addInterface("vRP",tvRP)

-- functions

local user_id
function tvRP.setUserId(_user_id)
  user_id = _user_id
end

-- get user id (client-side)
function tvRP.getUserId()
  return user_id
end

function tvRP.teleport(x,y,z)
  tvRP.unjail() -- force unjail before a teleportation
  SetEntityCoords(PlayerPedId(), x+0.0001, y+0.0001, z+0.0001, 1,0,0,1)
  vRPserver._updatePos(x,y,z)
end

function tvRP.teleport2(entity, coords, cb)
	RequestCollisionAtCoord(coords.x, coords.y, coords.z)

	while not HasCollisionLoadedAroundEntity(entity) do
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)
		Citizen.Wait(0)
	end

	SetEntityCoords(entity, coords.x, coords.y, coords.z)

	if cb ~= nil then
		cb()
	end
end


-- return x,y,z
function tvRP.getPosition()
  local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(),true))
  return x,y,z
end

-- return false if in exterior, true if inside a building
function tvRP.isInside()
  local x,y,z = tvRP.getPosition()
  return not (GetInteriorAtCoords(x,y,z) == 0)
end

-- return vx,vy,vz
function tvRP.getSpeed()
  local vx,vy,vz = table.unpack(GetEntityVelocity(PlayerPedId()))
  return math.sqrt(vx*vx+vy*vy+vz*vz)
end

function tvRP.getCamDirection()
  local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(PlayerPedId())
  local pitch = GetGameplayCamRelativePitch()

  local x = -math.sin(heading*math.pi/180.0)
  local y = math.cos(heading*math.pi/180.0)
  local z = math.sin(pitch*math.pi/180.0)

  -- normalize
  local len = math.sqrt(x*x+y*y+z*z)
  if len ~= 0 then
    x = x/len
    y = y/len
    z = z/len
  end

  return x,y,z
end

function tvRP.addPlayer(player)
  players[player] = true
end

function tvRP.removePlayer(player)
  players[player] = nil
end

function tvRP.getPlayers()
  return players
end

function tvRP.getNearestPlayers(radius)
  local r = {}

  local ped = GetPlayerPed(i)
  local pid = PlayerId()
  local px,py,pz = tvRP.getPosition()

  for k,v in pairs(players) do
    local player = GetPlayerFromServerId(k)

    if v and player ~= pid and NetworkIsPlayerConnected(player) then
      local oped = GetPlayerPed(player)
      local x,y,z = table.unpack(GetEntityCoords(oped,true))
      local distance = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
      if distance <= radius then
        r[GetPlayerServerId(player)] = distance
      end
    end
  end

  return r
end

function tvRP.getPlayersByCoords()
  local r = {}

  local pid = PlayerId()
  local px,py,pz = tvRP.getPosition()

  for k,v in pairs(players) do
    local player = GetPlayerFromServerId(k)

    if v and player ~= pid and NetworkIsPlayerConnected(player) then
      local oped = GetPlayerPed(player)
      r[GetPlayerServerId(player)] = GetEntityCoords(oped,true)
    end
  end

  return r
end

function tvRP.getNearestPlayerByCoords(coords)
  local p = nil
  local players = tvRP.getPlayersByCoords()
  for k,v in pairs(players) do
    local distance = GetDistanceBetweenCoords(v.x,v.y,v.z,coords.x,coords.y,coords.z,true)
    if (distance <= 1) then
      p = k
    end
  end

  return p
end

function tvRP.getNearestPlayer(radius)
  local p = nil

  local players = tvRP.getNearestPlayers(radius)
  local min = radius+10.0
  for k,v in pairs(players) do
    if v < min then
      min = v
      p = k
    end
  end

  return p
end

function tvRP.DrawText3D(x,y,z, text, rect)
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
	if not rect then
		DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
	end
end

function tvRP.dialogo(npc,msg,botao)
  TriggerEvent('Dialogo:Client', npc, msg, botao)
end

function tvRP.notify(msg)
  TriggerServerEvent('notifySuccess:Server', msg)
end

function tvRP.notifyError(msg)
  TriggerServerEvent('notifyError:Server', msg)
end

function tvRP.notifyWarning(msg)
  TriggerServerEvent('notifyWarning:Server', msg)
end

function tvRP.notifyPicture(icon, type, sender, title, text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    SetNotificationMessage(icon, icon, true, type, sender, title, text)
    DrawNotification(false, true)
end

-- SCREEN

-- play a screen effect
-- name, see https://wiki.fivem.net/wiki/Screen_Effects
-- duration: in seconds, if -1, will play until stopScreenEffect is called
function tvRP.playScreenEffect(name, duration)
  if duration < 0 then -- loop
    StartScreenEffect(name, 0, true)
  else
    StartScreenEffect(name, 0, true)

    Citizen.CreateThread(function() -- force stop the screen effect after duration+1 seconds
      Citizen.Wait(math.floor((duration+1)*1000))
      StopScreenEffect(name)
    end)
  end
end

-- stop a screen effect
-- name, see https://wiki.fivem.net/wiki/Screen_Effects
function tvRP.stopScreenEffect(name)
  StopScreenEffect(name)
end

-- ANIM

-- animations dict and names: http://docs.ragepluginhook.net/html/62951c37-a440-478c-b389-c471230ddfc5.htm

local anims = {}
local anim_ids = Tools.newIDGenerator()

-- play animation (new version)
-- upper: true, only upper body, false, full animation
-- seq: list of animations as {dict,anim_name,loops} (loops is the number of loops, default 1) or a task def (properties: task, play_exit)
-- looping: if true, will infinitely loop the first element of the sequence until stopAnim is called
function tvRP.playAnim(upper, seq, looping)
  if seq.task then -- is a task (cf https://github.com/ImagicTheCat/vRP/pull/118)
    tvRP.stopAnim(true)

    local ped = PlayerPedId()
    if seq.task == "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER" then -- special case, sit in a chair
      local x,y,z = tvRP.getPosition()
      TaskStartScenarioAtPosition(ped, seq.task, x, y, z-1, GetEntityHeading(ped), 0, 0, false)
    else
      TaskStartScenarioInPlace(ped, seq.task, 0, not seq.play_exit)
    end
  else -- a regular animation sequence
    tvRP.stopAnim(upper)

    local flags = 0
    if upper then flags = flags+48 end
    if looping then flags = flags+1 end

    Citizen.CreateThread(function()
      -- prepare unique id to stop sequence when needed
      local id = anim_ids:gen()
      anims[id] = true

      for k,v in pairs(seq) do
        local dict = v[1]
        local name = v[2]
        local loops = v[3] or 1

        for i=1,loops do
          if anims[id] then -- check animation working
            local first = (k == 1 and i == 1)
            local last = (k == #seq and i == loops)

            -- request anim dict
            RequestAnimDict(dict)
            local i = 0
            while not HasAnimDictLoaded(dict) and i < 1000 do -- max time, 10 seconds
              Citizen.Wait(10)
              RequestAnimDict(dict)
              i = i+1
            end

            -- play anim
            if HasAnimDictLoaded(dict) and anims[id] then
              local inspeed = 8.0001
              local outspeed = -8.0001
              if not first then inspeed = 2.0001 end
              if not last then outspeed = 2.0001 end

              TaskPlayAnim(PlayerPedId(),dict,name,inspeed,outspeed,-1,flags,0,0,0,0)
            end

            Citizen.Wait(0)
            while GetEntityAnimCurrentTime(PlayerPedId(),dict,name) <= 0.95 and IsEntityPlayingAnim(PlayerPedId(),dict,name,3) and anims[id] do
              Citizen.Wait(0)
            end
          end
        end
      end

      -- free id
      anim_ids:free(id)
      anims[id] = nil
    end)
  end
end

-- stop animation (new version)
-- upper: true, stop the upper animation, false, stop full animations
function tvRP.stopAnim(upper)
  anims = {} -- stop all sequences
  if upper then
    ClearPedSecondaryTask(PlayerPedId())
  else
    ClearPedTasks(PlayerPedId())
  end
end

-- Teste
function tvRP.CarregarObjeto(dict,anim,prop,flag,mao,altura,pos1,pos2,pos3)
  local ped = PlayerPedId()

  RequestModel(GetHashKey(prop))
  while not HasModelLoaded(GetHashKey(prop)) do
      Citizen.Wait(10)
  end

  if altura then
      local coords = GetOffsetFromEntityInWorldCoords(ped,0.0,0.0,-5.0)
      object = CreateObject(GetHashKey(prop),coords.x,coords.y,coords.z,true,true,true)
      SetEntityCollision(object,false,false)
      AttachEntityToEntity(object,ped,GetPedBoneIndex(ped,mao),altura,pos1,pos2,pos3,260.0,60.0,true,true,false,true,1,true)
  else
      tvRP.CarregarAnim(dict)
      TaskPlayAnim(ped,dict,anim,3.0,3.0,-1,flag,0,0,0,0)
      local coords = GetOffsetFromEntityInWorldCoords(ped,0.0,0.0,-5.0)
      object = CreateObject(GetHashKey(prop),coords.x,coords.y,coords.z,true,true,true)
      SetEntityCollision(object,false,false)
      AttachEntityToEntity(object,ped,GetPedBoneIndex(ped,mao),0.0,0.0,0.0,0.0,0.0,0.0,false,false,false,false,2,true)
  end
  SetEntityAsMissionEntity(object,true,true)
end

function tvRP.DeletarObjeto()
  tvRP.stopAnim(true)
  if DoesEntityExist(object) then
      DetachEntity(object,false,false)
      TriggerServerEvent("trydeleteobj",ObjToNet(object))
      object = nil
  end
end

function tvRP.CarregarAnim(dict)
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do
    Citizen.Wait(10)
  end
end

-- RAGDOLL
local ragdoll = false

-- set player ragdoll flag (true or false)
function tvRP.setRagdoll(flag)
  ragdoll = flag
end

-- ragdoll thread
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(10)
    if ragdoll then
      SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
    end
  end
end)

-- SOUND
-- some lists: 
-- pastebin.com/A8Ny8AHZ
-- https://wiki.gtanet.work/index.php?title=FrontEndSoundlist

-- play sound at a specific position
function tvRP.playSpatializedSound(dict,name,x,y,z,range)
  PlaySoundFromCoord(-1,name,x+0.0001,y+0.0001,z+0.0001,dict,0,range+0.0001,0)
end

-- play sound
function tvRP.playSound(dict,name)
  PlaySound(-1,name,dict,0,0,1)
end

--[[
-- not working
function tvRP.setMovement(dict)
  if dict then
    SetPedMovementClipset(PlayerPedId(),dict,true)
  else
    ResetPedMovementClipset(PlayerPedId(),true)
  end
end
--]]

-- events

AddEventHandler("playerSpawned",function()
	while not NetworkIsSessionStarted() do
		Citizen.Wait(1000)
	end
	
	ShutdownLoadingScreen()

	DoScreenFadeIn(500)

	while IsScreenFadingIn() do
		Citizen.Wait(0)
	end

	TriggerEvent("vRPcli:unfreeze")
	TriggerServerEvent("vRPcli:playerSpawned")
end)

AddEventHandler("onPlayerDied",function(player,reason)
  TriggerServerEvent("vRPcli:playerDied")
end)

AddEventHandler("onPlayerKilled",function(player,killer,reason)
  TriggerServerEvent("vRPcli:playerDied")
end)

-- voice proximity computation
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(500)
    if cfg.vrp_voip then -- vRP voip
      NetworkSetTalkerProximity(0) -- disable voice chat
    else -- regular voice chat
      local ped = PlayerPedId()
      local proximity = cfg.voice_proximity

      if IsPedSittingInAnyVehicle(ped) then
        local veh = GetVehiclePedIsIn(ped,false)
        local hash = GetEntityModel(veh)
        -- make open vehicles (bike,etc) use the default proximity
        if IsThisModelACar(hash) or IsThisModelAHeli(hash) or IsThisModelAPlane(hash) then
          proximity = cfg.voice_proximity_vehicle
        end
      elseif tvRP.isInside() then
        proximity = cfg.voice_proximity_inside
      end

      NetworkSetTalkerProximity(proximity+0.0001)
    end
  end
end)

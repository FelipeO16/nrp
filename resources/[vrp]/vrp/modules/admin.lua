local player_customs = {}

local function ch_display_custom(player, choice)
  local custom = vRPclient.getCustomization(player)
  if player_customs[player] then 
    player_customs[player] = nil
    vRPclient._removeDiv(player,"customization")
  else 
    local content = ""
    for k,v in pairs(custom) do
      content = content..k.." => "..json.encode(v).."<br />" 
    end

    player_customs[player] = true
    vRPclient._setDiv(player,"customization",".div_customization{ margin: auto; padding: 8px; width: 500px; margin-top: 80px; background: black; color: white; font-weight: bold; ", content)
  end
end

local function ch_audiosource(player, choice)
  local infos = splitString(vRP.prompt(player, "Audio source: name=url, omit url to delete the named source.", ""), "=")
  local name = infos[1]
  local url = infos[2]

  if name and string.len(name) > 0 then
    if url and string.len(url) > 0 then
      local x,y,z = vRPclient.getPosition(player)
      vRPclient._setAudioSource(-1,"vRP:admin:"..name,url,0.5,x,y,z,125)
    else
      vRPclient._removeAudioSource(-1,"vRP:admin:"..name)
    end
  end
end

local function ch_emote(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id and vRP.hasPermission(user_id,"adm.perm") then
    local content = vRP.prompt(player,"Animation sequence ('dict anim optional_loops' per line): ","")
    local seq = {}
    for line in string.gmatch(content,"[^\n]+") do
      local args = {}
      for arg in string.gmatch(line,"[^%s]+") do
        table.insert(args,arg)
      end

      table.insert(seq,{args[1] or "", args[2] or "", args[3] or 1})
    end

    vRPclient._playAnim(player, true,seq,false)
  end
end

local function ch_sound(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id and vRP.hasPermission(user_id,"adm.perm") then
    local content = vRP.prompt(player,"Sound 'dict name': ","")
      local args = {}
      for arg in string.gmatch(content,"[^%s]+") do
        table.insert(args,arg)
      end
      vRPclient._playSound(player, args[1] or "", args[2] or "")
  end
end
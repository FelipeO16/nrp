
-- this module describe the home system (experimental, a lot can happen and not being handled)

local lang = vRP.lang
local cfg = module("cfg/homes")


vRP.prepare("vRP/get_address","SELECT home, number FROM vrp_user_homes WHERE user_id = @user_id")
vRP.prepare("vRP/get_home_owner","SELECT user_id FROM vrp_user_homes WHERE home = @home AND number = @number")
vRP.prepare("vRP/rm_address","DELETE FROM vrp_user_homes WHERE user_id = @user_id")
-- api

function vRP.getUserAddresses(user_id)
  local rows = vRP.query("sRP/obter_endereco", {user_id = user_id})
  return rows
end

function vRP.setUserAddress(user_id,home,number,locked,limite)
  vRP.execute("NL/set_endereco", {user_id = user_id, home = home, number = number, locked = locked, guardaRoupa = json.encode({}), bau = json.encode({}), bauLimite = limite })
end

-- remove user address
function vRP.removeUserAddress(user_id)
  vRP.execute("vRP/rm_address", {user_id = user_id})
end

-- return user_id or nil
function vRP.getUserByAddress(home,number,cbr)
  local rows = vRP.query("vRP/get_home_owner", {home = home, number = number})
  if #rows > 0 then
    return rows[1].user_id
  end
end
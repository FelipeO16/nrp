local htmlEntities = module("lib/htmlEntities")

local cfg = module("cfg/identity")
local lang = vRP.lang

local sanitizes = module("cfg/sanitizes")

vRP.prepare("vRP/identity_tables", [[
CREATE TABLE IF NOT EXISTS vrp_user_identities(
  user_id INTEGER,
  age INTEGER,
  name VARCHAR(50),
  firstname VARCHAR(50),
  carma INTEGER,
  phone VARCHAR(20),
  registration VARCHAR(20),
  foto text(255),
  CONSTRAINT pk_user_identities PRIMARY KEY(user_id),
  CONSTRAINT fk_user_identities_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE,
  INDEX(registration),
  INDEX(phone)
);
]])

vRP.prepare("vRP/get_user_identity","SELECT * FROM vrp_user_identities WHERE user_id = @user_id")
vRP.prepare("vRP/init_user_identity","INSERT IGNORE INTO vrp_user_identities(user_id,age,name,firstname,carma,phone,registration,foto) VALUES(@user_id,@age,@name,@firstname,@carma,@phone,@registration,@foto)")
vRP.prepare("vRP/update_user_identity","UPDATE vrp_user_identities SET age = @age, name = @name, firstname = @firstname, carma = @carma, phone = @phone, registration = @registration, foto = @foto WHERE user_id = @user_id")
vRP.prepare("vRP/get_userbyreg","SELECT user_id FROM vrp_user_identities WHERE registration = @registration")
vRP.prepare("vRP/get_userbyphone","SELECT user_id FROM vrp_user_identities WHERE phone = @phone")

-- init
async(function()
  vRP.execute("vRP/identity_tables")
end)

-- api

-- return user identity
function vRP.getUserIdentity(user_id, cbr)
  local rows = vRP.query("vRP/get_user_identity", {user_id = user_id})
  return rows[1]
end

-- return user_id by registration or nil
function vRP.getUserByRegistration(registration, cbr)
  local rows = vRP.query("vRP/get_userbyreg", {registration = registration or ""})
  if #rows > 0 then
    return rows[1].user_id
  end
end

-- return user_id by phone or nil
function vRP.getUserByPhone(phone, cbr)
  local rows = vRP.query("vRP/get_userbyphone", {phone = phone or ""})
  if #rows > 0 then
    return rows[1].user_id
  end
end

function vRP.generateStringNumber(format) -- (ex: DDDLLL, D => digit, L => letter)
  local abyte = string.byte("A")
  local zbyte = string.byte("0")

  local number = ""
  for i=1,#format do
    local char = string.sub(format, i,i)
    if char == "D" then number = number..string.char(zbyte+math.random(0,9))
    elseif char == "L" then number = number..string.char(abyte+math.random(0,25))
    else number = number..char end
  end

  return number
end

-- return a unique registration number
function vRP.generateRegistrationNumber(cbr)
  local user_id = nil
  local registration = ""
  -- generate registration number
  repeat
    registration = vRP.generateStringNumber("DDDLLL")
    user_id = vRP.getUserByRegistration(registration)
  until not user_id

  return registration
end

-- return a unique phone number (0DDDDD, D => digit)
function vRP.generatePhoneNumber(cbr)
  local user_id = nil
  local phone = ""

  -- generate phone number
  repeat
    phone = vRP.generateStringNumber(cfg.phone_format)
    user_id = vRP.getUserByPhone(phone)
  until not user_id

  return phone
end

-- events, init user identity at connection
AddEventHandler("vRP:playerJoin",function(user_id,source,name,last_login)
  if not vRP.getUserIdentity(user_id) then
    local registration = vRP.generateRegistrationNumber()
    local phone = vRP.generatePhoneNumber()
    vRP.execute("vRP/init_user_identity", {
      user_id = user_id,
      age = math.random(25,40),
      name = cfg.random_last_names[math.random(1,#cfg.random_last_names)],
      firstname = cfg.random_first_names[math.random(1,#cfg.random_first_names)],
      carma = 0,
      phone = phone,
      registration = registration,
      foto = "http://painelcontabil.com.br/contador/painel/img/login.png"
    })
  end
end)

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  -- send registration number to client at spawn
  local identity = vRP.getUserIdentity(user_id)
  if identity then
    vRPclient._setRegistrationNumber(source,identity.registration or "000AAA")
  end
end)

-- player identity menu

-- add identity to main menu
--[[ vRP.registerMenuBuilder("main", function(add, data)
  local player = data.player

  local user_id = vRP.getUserId(player)
  if user_id then
    local identity = vRP.getUserIdentity(user_id)

    if identity then
      -- generate identity content
      -- get address
      local address = vRP.getUserAddress(user_id)
      local home = ""
      local number = ""
      if address then
        home = address.home
        number = address.number
      end

      local content = lang.cityhall.menu.info({htmlEntities.encode(identity.name),htmlEntities.encode(identity.firstname),identity.age,identity.registration,identity.phone,home,number})
      local choices = {}
      choices[lang.cityhall.menu.title()] = {function()end, content}

      add(choices)
    end
  end
end) ]]

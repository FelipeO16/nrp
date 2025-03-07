local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
local Luang = module("lib/Luang")
Debug = module("lib/Debug")

local config = module("cfg/base")

vRP = {}
Proxy.addInterface("vRP",vRP)

tvRP = {}
Tunnel.bindInterface("vRP",tvRP) -- listening for client tunnel

-- load language 
local Lang = Luang()
Lang:loadLocale(config.lang, module("cfg/lang/"..config.lang) or {})
vRP.lang = Lang.lang[config.lang]

-- init
vRPclient = Tunnel.getInterface("vRP") -- server -> client tunnel

vRP.users = {} -- will store logged users (id) by first identifier
vRP.rusers = {} -- store the opposite of users
vRP.user_tables = {} -- user data tables (logger storage, saved to database)
vRP.user_tmp_tables = {} -- user tmp data tables (logger storage, not saved)
vRP.user_sources = {} -- user sources 

-- db/SQL API
local db_drivers = {}
local db_driver
local cached_prepares = {}
local cached_queries = {}
local prepared_queries = {}
local db_initialized = false

-- register a DB driver
--- name: unique name for the driver
--- on_init(cfg): called when the driver is initialized (connection), should return true on success
---- cfg: db config
--- on_prepare(name, query): should prepare the query (@param notation)
--- on_query(name, params, mode): should execute the prepared query
---- params: map of parameters
---- mode: 
----- "query": should return rows, affected
----- "execute": should return affected
----- "scalar": should return a scalar
function vRP.registerDBDriver(name, on_init, on_prepare, on_query)
  if not db_drivers[name] then
    db_drivers[name] = {on_init, on_prepare, on_query}

    if name == config.db.driver then -- use/init driver
      db_driver = db_drivers[name] -- set driver

      local ok = on_init(config.db)
      if ok then
        print("^3[NL] Conectado ao banco de dados, usando o driver \""..name.."\".^0")
        db_initialized = true
        -- execute cached prepares
        for _,prepare in pairs(cached_prepares) do
          on_prepare(table.unpack(prepare, 1, table.maxn(prepare)))
        end

        -- execute cached queries
        for _,query in pairs(cached_queries) do
          async(function()
            query[2](on_query(table.unpack(query[1], 1, table.maxn(query[1]))))
          end)
        end

        cached_prepares = nil
        cached_queries = nil
      else
        error("[NL] Conexão falhou usando: \""..name.."\".")
      end
    end
  else
    error("[NL] DB driver \""..name.."\" already registered.")
  end
end

function vRP.format(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

-- prepare a query
--- name: unique name for the query
--- query: SQL string with @params notation
function vRP.prepare(name, query)
  if Debug.active then
    Debug.log("prepare "..name.." = \""..query.."\"")
  end

  prepared_queries[name] = true

  if db_initialized then -- direct call
    db_driver[2](name, query)
  else
    table.insert(cached_prepares, {name, query})
  end
end

-- execute a query
--- name: unique name of the query
--- params: map of parameters
--- mode: default is "query"
---- "query": should return rows (list of map of parameter => value), affected
---- "execute": should return affected
---- "scalar": should return a scalar
function vRP.query(name, params, mode)
  if not prepared_queries[name] then
    error("[NL] query "..name.." não existe.")
  end

  if not mode then mode = "query" end

  if Debug.active then
    Debug.log("query "..name.." ("..mode..") params = "..json.encode(params or {}))
  end

  if db_initialized then -- direct call
    return db_driver[3](name, params or {}, mode)
  else -- async call, wait query result
    local r = async()
    table.insert(cached_queries, {{name, params or {}, mode}, r})
    return r:wait()
  end
end

-- shortcut for vRP.query with "execute"
function vRP.execute(name, params)
  return vRP.query(name, params, "execute")
end

-- shortcut for vRP.query with "scalar"
function vRP.scalar(name, params)
  return vRP.query(name, params, "scalar")
end

-- DB driver error/warning

if not config.db or not config.db.driver then
  error("[NL] Missing DB config driver.")
end

Citizen.CreateThread(function()
  while not db_initialized do
    print("^1[NL] DB driver \""..config.db.driver.."\" ainda nao foi inicializado ("..#cached_prepares.." preparos em cache, "..#cached_queries.." consultas em cache).^0")
    Citizen.Wait(5000)
  end
end)

-- queries
vRP.prepare("vRP/base_tables",[[
CREATE TABLE IF NOT EXISTS vrp_users(
  id INTEGER AUTO_INCREMENT,
  last_login VARCHAR(255),
  whitelisted BOOLEAN,
  banned BOOLEAN,
  CONSTRAINT pk_user PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS vrp_user_ids(
  identifier VARCHAR(100),
  user_id INTEGER,
  CONSTRAINT pk_user_ids PRIMARY KEY(identifier),
  CONSTRAINT fk_user_ids_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS vrp_user_data(
  user_id INTEGER,
  dkey VARCHAR(100),
  dvalue TEXT,
  CONSTRAINT pk_user_data PRIMARY KEY(user_id,dkey),
  CONSTRAINT fk_user_data_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS vrp_srv_data(
  dkey VARCHAR(100),
  dvalue TEXT,
  CONSTRAINT pk_srv_data PRIMARY KEY(dkey)
);
]])

vRP.prepare("vRP/create_user","INSERT INTO vrp_users(whitelisted,banned) VALUES(false,false); SELECT LAST_INSERT_ID() AS id")
vRP.prepare("vRP/add_identifier","INSERT INTO vrp_user_ids(identifier,user_id) VALUES(@identifier,@user_id)")
vRP.prepare("vRP/userid_byidentifier","SELECT user_id FROM vrp_user_ids WHERE identifier = @identifier")

vRP.prepare("vRP/set_userdata","REPLACE INTO vrp_user_data(user_id,dkey,dvalue) VALUES(@user_id,@key,@value)")
vRP.prepare("vRP/get_userdata","SELECT dvalue FROM vrp_user_data WHERE user_id = @user_id AND dkey = @key")

vRP.prepare("vRP/set_srvdata","REPLACE INTO vrp_srv_data(dkey,dvalue) VALUES(@key,@value)")
vRP.prepare("vRP/get_srvdata","SELECT dvalue FROM vrp_srv_data WHERE dkey = @key")

vRP.prepare("vRP/get_banned","SELECT banned FROM vrp_users WHERE id = @user_id")
vRP.prepare("vRP/set_banned","UPDATE vrp_users SET banned = @banned WHERE id = @user_id")
vRP.prepare("vRP/get_whitelisted","SELECT whitelisted FROM vrp_users WHERE id = @user_id")
vRP.prepare("vRP/set_whitelisted","UPDATE vrp_users SET whitelisted = @whitelisted WHERE id = @user_id")
vRP.prepare("vRP/set_last_login","UPDATE vrp_users SET last_login = @last_login WHERE id = @user_id")
vRP.prepare("vRP/get_last_login","SELECT last_login FROM vrp_users WHERE id = @user_id")

-- init tables
print("^3[NL] init base tables^0")
async(function()
  vRP.execute("vRP/base_tables")
end)

-- identification system

--- sql.
-- return user id or nil in case of error (if not found, will create it)
function vRP.getUserIdByIdentifiers(ids)
  if ids and #ids then
    -- search identifiers
    for i=1,#ids do
      if not config.ignore_ip_identifier or (string.find(ids[i], "ip:") == nil) then  -- ignore ip identifier
        local rows = vRP.query("vRP/userid_byidentifier", {identifier = ids[i]})
        if #rows > 0 then  -- found
          return rows[1].user_id
        end
      end
    end

    -- no ids found, create user
    local rows, affected = vRP.query("vRP/create_user", {})

    if #rows > 0 then
      local user_id = rows[1].id
      -- add identifiers
      for l,w in pairs(ids) do
        if not config.ignore_ip_identifier or (string.find(w, "ip:") == nil) then  -- ignore ip identifier
          vRP.execute("vRP/add_identifier", {user_id = user_id, identifier = w})
        end
      end

      return user_id
    end
  end
end

-- return identification string for the source (used for non vRP identifications, for rejected players)
function vRP.getSourceIdKey(source)
  local ids = GetPlayerIdentifiers(source)
  local idk = "idk_"
  for k,v in pairs(ids) do
    idk = idk..v
  end

  return idk
end

function vRP.getPlayerEndpoint(player)
  return GetPlayerEP(player) or "0.0.0.0"
end

function vRP.getPlayerName(player)
  return GetPlayerName(player) or "unknown"
end

--- sql
function vRP.isBanned(user_id, cbr)
  local rows = vRP.query("vRP/get_banned", {user_id = user_id})
  if #rows > 0 then
    return rows[1].banned
  else
    return false
  end
end

--- sql
function vRP.setBanned(user_id,banned)
  vRP.execute("vRP/set_banned", {user_id = user_id, banned = banned})
end

--- sql
function vRP.isWhitelisted(user_id, cbr)
  local rows = vRP.query("vRP/get_whitelisted", {user_id = user_id})
  if #rows > 0 then
    return rows[1].whitelisted
  else
    return false
  end
end

--- sql
function vRP.setWhitelisted(user_id,whitelisted)
  vRP.execute("vRP/set_whitelisted", {user_id = user_id, whitelisted = whitelisted})
end

--- sql
function vRP.getLastLogin(user_id, cbr)
  local rows = vRP.query("vRP/get_last_login", {user_id = user_id})
  if #rows > 0 then
    return rows[1].last_login
  else
    return ""
  end
end

function vRP.setUData(user_id,key,value)
  vRP.execute("vRP/set_userdata", {user_id = user_id, key = key, value = value})
end

function vRP.getUData(user_id,key,cbr)
  local rows = vRP.query("vRP/get_userdata", {user_id = user_id, key = key})
  if #rows > 0 then
    return rows[1].dvalue
  else
    return ""
  end
end

function vRP.setSData(key,value)
  vRP.execute("vRP/set_srvdata", {key = key, value = value})
end

function vRP.getSData(key, cbr)
  local rows = vRP.query("vRP/get_srvdata", {key = key})
  if #rows > 0 then
    return rows[1].dvalue
  else
    return ""
  end
end

-- return user data table for vRP internal persistant connected user storage
function vRP.getUserDataTable(user_id)
  return vRP.user_tables[user_id]
end

function vRP.getUserTmpTable(user_id)
  return vRP.user_tmp_tables[user_id]
end

-- return the player spawn count (0 = not spawned, 1 = first spawn, ...)
function vRP.getSpawns(user_id)
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp then
    return tmp.spawns or 0
  end

  return 0
end

function vRP.getUserId(source)
  if source ~= nil then
    local ids = GetPlayerIdentifiers(source)
    if ids ~= nil and #ids > 0 then
      return vRP.users[ids[1]]
    end
  end

  return nil
end

-- return map of user_id -> player source
function vRP.getUsers()
  local users = {}
  for k,v in pairs(vRP.user_sources) do
    users[k] = v
  end

  return users
end

-- return source or nil
function vRP.getUserSource(user_id)
  return vRP.user_sources[user_id]
end

function vRP.ban(source,reason)
  local user_id = vRP.getUserId(source)

  if user_id then
    vRP.setBanned(user_id,true)
    vRP.kick(source,"[Banned] "..reason)
  end
end

function vRP.kick(source,reason)
  DropPlayer(source,reason)
end

-- drop vRP player/user (internal usage)
function vRP.dropPlayer(source)
  local user_id = vRP.getUserId(source)
  local endpoint = vRP.getPlayerEndpoint(source)

  -- remove player from connected clients
  vRPclient._removePlayer(-1, source)

  if user_id then
    TriggerEvent("vRP:playerLeave", user_id, source)

    -- save user data table
    vRP.setUData(user_id,"vRP:datatable",json.encode(vRP.getUserDataTable(user_id)))

    print("^3[NL] "..endpoint.." - [DESCONECTOU] - (user_id = "..user_id..")^0")
    vRP.users[vRP.rusers[user_id]] = nil
    vRP.rusers[user_id] = nil
    vRP.user_tables[user_id] = nil
    vRP.user_tmp_tables[user_id] = nil
    vRP.user_sources[user_id] = nil
  end
end

-- tasks

function task_save_datatables()
  SetTimeout(config.save_interval*1000, task_save_datatables)
  TriggerEvent("vRP:save")

  Debug.log("save datatables")
  for k,v in pairs(vRP.user_tables) do
    vRP.setUData(k,"vRP:datatable",json.encode(v))
  end
end

async(function()
  task_save_datatables()
end)

-- ping timeout
--[[ function task_timeout()
  local users = vRP.getUsers()
  for k,v in pairs(users) do
    if GetPlayerPing(v) <= 0 then
      vRP.kick(v,"[NL] Ping timeout.")
      vRP.dropPlayer(v)
    end
  end

  SetTimeout(30000, task_timeout)
end
task_timeout() ]]

-- handlers

AddEventHandler("playerConnecting",function(name,setMessage, deferrals)
  deferrals.defer()

  local source = source
  Debug.log("playerConnecting "..name)
  local ids = GetPlayerIdentifiers(source)

  if ids ~= nil and #ids > 0 then
    deferrals.update("[NL] Checking identifiers...")
    local user_id = vRP.getUserIdByIdentifiers(ids)
    -- if user_id ~= nil and vRP.rusers[user_id] == nil then -- check user validity and if not already connected (old way, disabled until playerDropped is sure to be called)
    if user_id then -- check user validity 
      deferrals.update("[NL] Checando Banimentos...")
      if not vRP.isBanned(user_id) then
        deferrals.update("[NL] Checando Whitelist...")
        if not config.whitelist or vRP.isWhitelisted(user_id) then
          if vRP.rusers[user_id] == nil then -- not present on the server, init
            -- load user data table
            deferrals.update("[NL] Carregando Banco de Dados...")
            local sdata = vRP.getUData(user_id, "vRP:datatable")

            -- init entries
            vRP.users[ids[1]] = user_id
            vRP.rusers[user_id] = ids[1]
            vRP.user_tables[user_id] = {}
            vRP.user_tmp_tables[user_id] = {}
            vRP.user_sources[user_id] = source

            local data = json.decode(sdata)
            if type(data) == "table" then vRP.user_tables[user_id] = data end

            -- init user tmp table
            local tmpdata = vRP.getUserTmpTable(user_id)

            deferrals.update("[NL] Pegando ultimo login...")
            local last_login = vRP.getLastLogin(user_id)
            tmpdata.last_login = last_login or ""
            tmpdata.spawns = 0

            -- set last login
            local ep = vRP.getPlayerEndpoint(source)
            local last_login_stamp = os.date("%H:%M:%S %d/%m/%Y")
            vRP.execute("vRP/set_last_login", {user_id = user_id, last_login = last_login_stamp})

            -- trigger join
            print("^3[NL] "..name.." ("..vRP.getPlayerEndpoint(source)..") - [ENTROU] - (user_id = "..user_id..")^0")
            TriggerEvent("vRP:playerJoin", user_id, source, name, tmpdata.last_login)
            deferrals.done()
          else -- already connected
            print("^3[NL] "..name.." ("..vRP.getPlayerEndpoint(source)..") - [VOLTOU] - (user_id = "..user_id..")^0")
            -- reset first spawn
            local tmpdata = vRP.getUserTmpTable(user_id)
            tmpdata.spawns = 0

            TriggerEvent("vRP:playerRejoin", user_id, source, name)
            deferrals.done()
          end

        else
          print("^1[NL] "..name.." ("..vRP.getPlayerEndpoint(source)..") - [WL OFF] - (user_id = "..user_id..")^0")
          Citizen.Wait(1000)
          deferrals.done("[NL] Sem WhiteList ! [ID = "..user_id.."] - https://discord.gg/9WKMbNk")
        end
      else
        print("^1[NL] "..name.." ("..vRP.getPlayerEndpoint(source)..") - [BAN] - (user_id = "..user_id..")^0")
        Citizen.Wait(1000)
        deferrals.done("[NL] Você está Banido ! [user_id = "..user_id.."] - https://discord.gg/9WKMbNk")
      end
    else
      print("^1[NL] "..name.." ("..vRP.getPlayerEndpoint(source)..") rejeitado: identification error^0")
      Citizen.Wait(1000)
      deferrals.done("[NL] Erro na indentificação.")
    end
  else
    print("^1[NL] "..name.." ("..vRP.getPlayerEndpoint(source)..") rejeitado: missing identifiers^0")
    Citizen.Wait(1000)
    deferrals.done("[NL] Identificadores ausentes.")
  end
end)

AddEventHandler("playerDropped",function(reason)
  local source = source
  Debug.log("playerDropped "..source)

  vRP.dropPlayer(source)
end)

RegisterServerEvent("vRPcli:playerSpawned")
AddEventHandler("vRPcli:playerSpawned", function()
  local user_id = vRP.getUserId(source)
  local player = source
  if user_id then
    vRP.user_sources[user_id] = source
    local tmp = vRP.getUserTmpTable(user_id)
    tmp.spawns = tmp.spawns+1
    local first_spawn = (tmp.spawns == 1)

    if first_spawn then
      -- first spawn, reference player
      -- send players to new player
      for k,v in pairs(vRP.user_sources) do
        vRPclient._addPlayer(source,v)
      end
      -- send new player to all players
      vRPclient._addPlayer(-1,source)
    end

      TriggerEvent("vRP:playerSpawn",user_id,player,first_spawn)
  end
end)

RegisterServerEvent("vRP:playerDied")

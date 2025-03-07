-- this file define global tools required by vRP and vRP extensions
-- it will create module, SERVER, CLIENT, async...

-- side detection
SERVER = IsDuplicityVersion()
CLIENT = not SERVER

function table.maxn(t)
  local max = 0
  for k,v in pairs(t) do
    local n = tonumber(k)
    if n and n > max then max = n end
  end

  return max
end

local modules = {}
-- load a lua resource file as module
-- rsc: resource name
-- path: lua file path without extension
function module(rsc, path)
  if path == nil then -- shortcut for vrp, can omit the resource parameter
    path = rsc
    rsc = "vrp"
  end

  local key = rsc..path

  local module = modules[key]
  if module then -- cached module
    return module
  else
    local code = LoadResourceFile(rsc, path..".lua")
    if code then
      local f,err = load(code, rsc.."/"..path..".lua")
      if f then
        local ok, res = xpcall(f, debug.traceback)
        if ok then
          modules[key] = res
          return res
        else
          error("error loading module "..rsc.."/"..path..":"..res)
        end
      else
        error("error parsing module "..rsc.."/"..path..":"..debug.traceback(err))
      end
    else
      error("resource file "..rsc.."/"..path..".lua not found")
    end
  end
end

-- Luaseq like for FiveM

local Debug = module("vrp", "lib/Debug")

local function wait(self)
  if Debug.active then -- debug
    SetTimeout(math.floor(Debug.async_time)*1000, function()
      if not self.r then
        Debug.log("WARNING: in resource \""..GetCurrentResourceName().."\" async return take more than "..Debug.async_time.."s "..self.traceback, true)
      end
    end)
  end

  local rets = Citizen.Await(self.p)
  if not rets then
    rets = self.r 
  end

  return table.unpack(rets, 1, table.maxn(rets))
end

local function areturn(self, ...)
  self.r = {...}
  self.p:resolve(self.r)
end

-- create an async returner
function async(func)
  if func then
    Citizen.CreateThreadNow(func)
  else
    if Debug.active then -- debug
      return setmetatable({ wait = wait, p = promise.new(), traceback = debug.traceback("",2) }, { __call = areturn })
    else
      return setmetatable({ wait = wait, p = promise.new() }, { __call = areturn })
    end
  end
end

function parseInt(v)
--  return cast(int,tonumber(v))
  local n = tonumber(v)
  if n == nil then 
    return 0
  else
    return math.floor(n)
  end
end

function parseDouble(v)
--  return cast(double,tonumber(v))
  local n = tonumber(v)
  if n == nil then n = 0 end
  return n
end

function parseFloat(v)
  return parseDouble(v)
end

-- will remove chars not allowed/disabled by strchars
-- if allow_policy is true, will allow all strchars, if false, will allow everything except the strchars
local sanitize_tmp = {}
function sanitizeString(str, strchars, allow_policy)
  local r = ""

  -- get/prepare index table
  local chars = sanitize_tmp[strchars]
  if chars == nil then
    chars = {}
    local size = string.len(strchars)
    for i=1,size do
      local char = string.sub(strchars,i,i)
      chars[char] = true
    end

    sanitize_tmp[strchars] = chars
  end

  -- sanitize
  size = string.len(str)
  for i=1,size do
    local char = string.sub(str,i,i)
    if (allow_policy and chars[char]) or (not allow_policy and not chars[char]) then
      r = r..char
    end
  end

  return r
end

function splitString(str, sep)
  if sep == nil then sep = "%s" end

  local t={}
  local i=1

  for str in string.gmatch(str, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end

  return t
end

function joinStrings(list, sep)
  if sep == nil then sep = "" end

  local str = ""
  local count = 0
  local size = #list
  for k,v in pairs(list) do
    count = count+1
    str = str..v
    if count < size then str = str..sep end
  end

  return str
end

local uuid = {}
function generateUUID()
	local c = tostring(os.clock())
	local a = c:sub(c:find('%.')+1, c:len())
	local p = c:sub(1,c:find('%.')-1)
	c = parseInt(p..a)
	local uid = os.time(os.date("!*t"))+c+os.time()
	if not uuid[uid] then
		uuid[uid] = os.time()
		return uid
	else
		Citizen.Wait(3)
		return generateUUID()
	end
end

Citizen.CreateThread(function()
	while true do
		for k, v in pairs(uuid) do
			if os.time()-v > 4 then
				uuid[k] = nil
			end
		end
		Citizen.Wait(1000)
	end
end)

function count(tbl)
	local a = 0
	if type(tbl) == "table" then
		for k, v in pairs(tbl) do
			a = a+1
		end
	end
	return a
end
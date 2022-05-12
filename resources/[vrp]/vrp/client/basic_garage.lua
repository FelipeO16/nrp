-- decorators
DecorRegister("vRP_owner", 3)
DecorRegister("vRP_vmodel", 3)

local veh_models = {}
local vehicles = {}

local vehList = {
	dinghy = 1033245328,
	dinghy2 = 276773164,
	dinghy3 = 509498602,
	dinghy4 = 867467158,
	jetmax = 861409633,
	marquis = -1043459709,
	seashark = -1030275036,
	seashark2 = -616331036,
	seashark3 = -311022263,
	speeder = 231083307,
	speeder2 = 437538602,
	squalo = 400514754,
	submersible = 771711535,
	submersible2 = -1066334226,
	suntrap = -282946103,
	toro = 1070967343,
	toro2 = 908897389,
	tropic = 290013743,
	tropic2 = 1448677353,
	tug = -2100640717,
	benson = 2053223216,
	biff = 850991848,
	hauler = 1518533038,
	hauler2 = 387748548,
	mule = 904750859,
	mule2 = -1050465301,
	mule3 = -2052737935,
	packer = 569305213,
	phantom = -2137348917,
	phantom2 = -1649536104,
	phantom3 = 177270108,
	pounder = 2112052861,
	stockade = 1747439474,
	stockade3 = -214455498,
	blista = -344943009,
	blista2 = 1039032026,
	blista3 = -591651781,
	brioso = 1549126457,
	dilettante = -1130810103,
	dilettante2 = 1682114128,
	issi2 = -1177863319,
	panto = -431692672,
	prairie = -1450650718,
	rhapsody = 841808271,
	cogcabrio = 330661258,
	exemplar = -5153954,
	f620 = -591610296,
	felon = -391594584,
	felon2 = -89291282,
	jackal = -624529134,
	oracle = 1348744438,
	oracle2 = -511601230,
	sentinel = 1349725314,
	sentinel2 = 873639469,
	windsor = 1581459400,
	windsor2 = -1930048799,
	zion = -1122289213,
	zion2 = -1193103848,
	bmx = 1131912276,
	cruiser = 448402357,
	fixter = -836512833,
	scorcher = -186537451,
	tribike = 1127861609,
	tribike2 = -1233807380,
	tribike3 = -400295096,
	ambulance = 1171614426,
	fbi = 1127131465,
	fbi2 = -1647941228,
	firetruck = 1938952078,
	pbus = -2007026063,
	police = 2046537925,
	police2 = -1627000575,
	police3 = 1912215274,
	police4 = -1973172295,
	policeold1 = -1536924937,
	policeold2 = -1779120616,
	policet = 456714581,
	policeb = -34623805,
	polmav = 353883353,
	pranger = 741586030,
	predator = -488123221,
	riot = -1205689942,
	sheriff = -1683328900,
	sheriff2 = 1922257928,
	annihilator = 837858166,
	buzzard = 788747387,
	buzzard2 = 745926877,
	cargobob = -50547061,
	cargobob2 = 1621617168,
	cargobob3 = 1394036463,
	cargobob4 = 2025593404,
	frogger = 744705981,
	frogger2 = 1949211328,
	maverick = -1660661558,
	savage = -82626025,
	skylift = 1044954915,
	supervolito = 710198397,
	supervolito2 = -1671539132,
	swift = -339587598,
	swift2 = 1075432268,
	valkyrie = -1600252419,
	valkyrie2 = 1543134283,
	volatus = -1845487887,
	bulldozer = 1886712733,
	cutter = -1006919392,
	dump = -2130482718,
	flatbed = 1353720154,
	guardian = -2107990196,
	handler = 444583674,
	mixer = -784816453,
	mixer2 = 475220373,
	rubble = -1705304628,
	tiptruck = 48339065,
	tiptruck2 = -947761570,
	apc = 562680400,
	barracks = -823509173,
	barracks2 = 1074326203,
	barracks3 = 630371791,
	crusader = 321739290,
	halftrack = -32236122,
	rhino = 782665360,
	trailersmall2 = -1881846085,
	akuma = 1672195559,
	avarus = -2115793025,
	bagger = -2140431165,
	bati2 = -891462355,
	bati = -114291515,
	bf400 = 86520421,
	blazer4 = -440768424,
	carbonrs = 11251904,
	chimera = 6774487,
	cliffhanger = 390201602,
	daemon2 = -1404136503,
	daemon = 2006142190,
	defiler = 822018448,
	double = -1670998136,
	enduro = 1753414259,
	esskey = 2035069708,
	faggio = -1842748181,
	faggio2 = 55628203,
	faggio3 = -1289178744,
	fcr2 = -757735410,
	fcr = 627535535,
	gargoyle = 741090084,
	hakuchou2 = -255678177,
	hakuchou = 1265391242,
	hexer = 301427732,
	innovation = -159126838,
	lectro = 640818791,
	manchez = -1523428744,
	nemesis = -634879114,
	nightblade = -1606187161,
	opressor = 884483972,
	pcj = -909201658,
	ratbike = 1873600305,
	ruffian = -893578776,
	sanchez2 = -1453280962,
	sanchez = 788045382,
	sanctus = 1491277511,
	shotaro = -405626514,
	sovereign = 743478836,
	thrust = 1836027715,
	vader = -140902153,
	vindicator = -1353081087,
	vortex = -609625092,
	wolfsbane = -618617997,
	zombiea = -1009268949,
	zombieb = -570033273,
	blade = -1205801634,
	buccaneer = -682211828,
	buccaneer2 = -1013450936,
	chino = 349605904,
	chino2 = -1361687965,
	dominator = 80636076,
	dominator2 = -915704871,
	dukes = 723973206,
	dukes2 = -326143852,
	faction = -2119578145,
	faction2 = -1790546981,
	faction3 = -2039755226,
	gauntlet = -1800170043,
	gauntlet2 = 349315417,
	hotknife = 37348240,
	lurcher = 2068293287,
	moonbeam = 525509695,
	moonbeam2 = 1896491931,
	nightshade = -1943285540,
	phoenix = -2095439403,
	picador = 1507916787,
	ratloader = -667151410,
	ratloader2 = -589178377,
	ruiner = -227741703,
	ruiner2 = 941494461,
	sabregt = -1685021548,
	sabregt2 = 223258115,
	sadler2 = 734217681,
	slamvan = 729783779,
	slamvan2 = 833469436,
	slamvan3 = 1119641113,
	stalion = 1923400478,
	stalion2 = -401643538,
	tampa = 972671128,
	tampa3 = -1210451983,
	vigero = -825837129,
	virgo = -498054846,
	virgo2 = -899509638,
	virgo3 = 16646064,
	voodoo = 2006667053,
	voodoo2 = 523724515,
	bfinjection = 1126868326,
	bifta = -349601129,
	blazer = -2128233223,
	blazer2 = -48031959,
	blazer3 = -1269889662,
	blazer5 = -1590337689,
	bodhi2 = -1435919434,
	brawler = -1479664699,
	dloader = 1770332643,
	dune = -1661854193,
	dune2 = 534258863,
	dune3 = 1897744184,
	dune4 = -827162039,
	dune5 = -827162039,
	insurgent = -1860900134,
	insurgent2 = 2071877360,
	insurgent3 = -1924433270,
	kalahari = 92612664,
	lguard = 469291905,
	marshall = 1233534620,
	mesa = 914654722,
	mesa2 = -748008636,
	mesa3 = -2064372143,
	monster = -845961253,
	nightshark = 433954513,
	rancherxl = 1645267888,
	rancherxl2 = 1933662059,
	rebel = -1207771834,
	rebel2 = -2045594037,
	sandking = -1189015600,
	sandking2 = 989381445,
	technical = -2096818938,
	technical2 = 1180875963,
	technical3 = 1356124575,
	trophytruck = 101905590,
	trophytruck2 = -663299102,
	besra = 1824333165,
	blimp = -150975354,
	blimp2 = -613725916,
	cargoplane = 368211810,
	cuban800 = -644710429,
	dodo = -901163259,
	duster = 970356638,
	hydra = 970385471,
	jet = 1058115860,
	lazer = -1281684762,
	luxor = 621481054,
	luxor2 = -1214293858,
	mammatus = -1746576111,
	miljet = 165154707,
	nimbus = -1295027632,
	shamal = -1214505995,
	stunt = -2122757008,
	titan = 1981688531,
	velum = -1673356438,
	velum2 = 1077420264,
	vestra = 1341619767,
	bjxl = 850565707,
	baller = -808831384,
	baller2 = 142944341,
	baller3 = 1878062887,
	baller4 = 634118882,
	baller5 = 470404958,
	baller6 = 666166960,
	cavalcade = 2006918058,
	cavalcade2 = -789894171,
	contender = 683047626,
	dubsta = 1177543287,
	dubsta2 = -394074634,
	dubsta3 = -1237253773,
	fq2 = -1137532101,
	granger = -1775728740,
	gresley = -1543762099,
	habanero = 884422927,
	huntley = 486987393,
	landstalker = 1269098716,
	patriot = -808457413,
	radi = -1651067813,
	rocoto = 2136773105,
	seminole = 1221512915,
	serrano = 1337041428,
	xls = 1203490606,
	xls2 = -432008408,
	asea = -1809822327,
	asea2 = -1807623979,
	asterope = -1903012613,
	cog55 = 906642318,
	cog552 = 704435172,
	cognoscenti = -2030171296,
	cognoscenti2 = -604842630,
	emperor = -685276541,
	emperor2 = -1883002148,
	emperor3 = -1241712818,
	fugitive = 1909141499,
	glendale = 75131841,
	ingot = -1289722222,
	intruder = 886934177,
	limo2 = -114627507,
	premier = -1883869285,
	primo = -1150599089,
	primo2 = -2040426790,
	regina = -14495224,
	romero = 627094268,
	stanier = -1477580979,
	stratum = 1723137093,
	stretch = -1961627517,
	surge = -1894894188,
	tailgater = -1008861746,
	warrener = 1373123368,
	washington = 1777363799,
	airbus = 1283517198,
	brickade = -305727417,
	bus = -713569950,
	coach = -2072933068,
	rallytruck = -2103821244,
	rentalbus = -1098802077,
	taxi = -956048545,
	tourbus = 1941029835,
	trash = 1917016601,
	trash2 = -1255698084,
	alpha = 767087018,
	banshee = -1041692462,
	banshee2 = 633712403,
	bestiagts = 1274868363,
	buffalo = -304802106,
	buffalo2 = 736902334,
	buffalo3 = 237764926,
	carbonizzare = 2072687711,
	comet2 = -1045541610,
	comet3 = -2022483795,
	coquette = 108773431,
	elegy = 196747873,
	elegy2 = -566387422,
	feltzer2 = -1995326987,
	feltzer3 = -1566741232,
	furoregt = -1089039904,
	fusilade = 499169875,
	futo = 2016857647,
	infernus2 = -1405937764,
	jester = -1297672541,
	jester2 = -1106353882,
	khamelion = 544021352,
	kuruma = -1372848492,
	kuruma2 = 410882957,
	lynx = 482197771,
	massacro = -142942670,
	massacro2 = -631760477,
	ninef = 1032823388,
	ninef2 = -1461482751,
	omnis = -777172681,
	penumbra = -377465520,
	rapidgt = -1934452204,
	rapidgt2 = 1737773231,
	raptor = -674927303,
	ruston = 719660200,
	schafter2 = -1255452397,
	schafter3 = -1485523546,
	schafter4 = 1489967196,
	schafter5 = -888242983,
	schafter6 = 1922255844,
	schwarzer = -746882698,
	seven70 = -1757836725,
	specter = 1886268224,
	specter2 = 1074745671,
	sultan = 970598228,
	surano = 384071873,
	tampa2 = -1071380347,
	tropos = 1887331236,
	verlierer2 = 1102544804,
	ardent = 159274291,
	btype = 117401876,
	btype2 = -831834716,
	btype3 = -602287871,
	casco = 941800958,
	cheetah2 = 223240013,
	coquette2 = 1011753235,
	coquette3 = 784565758,
	jb700 = 1051415893,
	mamba = -1660945322,
	manana = -2124201592,
	monroe = -433375717,
	peyote = 1830407356,
	pigalle = 1078682497,
	stinger = 1545842587,
	stingergt = -2098947590,
	torero = 1504306544,
	tornado = 464687292,
	tornado2 = 1531094468,
	tornado3 = 1762279763,
	tornado4 = -2033222435,
	tornado5 = -1797613329,
	tornado6 = -1558399629,
	ztype = 75889561,
	adder = -1216765807,
	bullet = -1696146015,
	cheetah = -1311154784,
	entityxf = -1291952903,
	fmj = 1426219628,
	gp1 = 1234311532,
	infernus = 418536135,
	re7b = -1232836011,
	nero = 1034187331,
	nero2 = 1093792632,
	osiris = 1987142870,
	penetrator = -1758137366,
	pfister811 = -1829802492,
	prototipo = 2123327359,
	reaper = 234062309,
	sheava = 819197656,
	sultanrs = -295689028,
	superd = 1123216662,
	t20 = 1663218586,
	tempesta = 272929391,
	turismo2 = -982130927,
	turismor = 408192225,
	tyrus = 2067820283,
	vacca = 338562499,
	vagner = 1939284556,
	voltic = -1622444098,
	voltic2 = 989294410,
	zentorno = -1403128555,
	italigtb = -2048333973,
	italigtb2 = -482719877,
	xa21 = 917809321,
	armytanker = -1207431159,
	armytrailer = -1476447243,
	armytrailer2 = -1637149482,
	baletrailer = -399841706,
	boattrailer = 524108981,
	cablecar = -960289747,
	docktrailer = -2140210194,
	graintrailer = 1019737494,
	proptrailer = 356391690,
	raketrailer = 390902130,
	tr2 = 2078290630,
	tr3 = 1784254509,
	tr4 = 2091594960,
	trflat = -1352468814,
	tvtrailer = -1770643266,
	tanker = -730904777,
	tanker2 = 1956216962,
	trailerlogs = 2016027501,
	trailersmall = 712162987,
	trailers = -877478386,
	trailers2 = -1579533167,
	trailers3 = -2058878099,
	freight = 1030400667,
	freightcar = 184361638,
	freightcont1 = 920453016,
	freightcont2 = 240201337,
	freightgrain = 642617954,
	freighttrailer = -777275802,
	tankercar = 586013744,
	airtug = 1560980623,
	caddy = 1147287684,
	caddy2 = -537896628,
	caddy3 = -769147461,
	docktug = -884690486,
	forklift = 1491375716,
	mower = 1783355638,
	ripley = -845979911,
	sadler = -599568815,
	scrap = -1700801569,
	towtruck = -1323100960,
	towtruck2 = -442313018,
	tractor = 1641462412,
	tractor2 = -2076478498,
	tractor3 = 1445631933,
	trailerlarge = 1502869817,
	trailers4 = -1100548694,
	utillitruck = 516990260,
	utillitruck3 = 2132890591,
	utillitruck2 = 887537515,
	bison = -16948145,
	bison2 = 2072156101,
	bison3 = 1739845664,
	bobcatxl = 1069929536,
	boxville = -1987130134,
	boxville2 = -233098306,
	boxville3 = 121658888,
	boxville4 = 444171386,
	boxville5 = 682434785,
	burrito = -1346687836,
	burrito2 = -907477130,
	burrito3 = -1743316013,
	burrito4 = 893081117,
	burrito5 = 1132262048,
	camper = 1876516712,
	gburrito = -1745203402,
	gburrito2 = 296357396,
	journey = -120287622,
	minivan = -310465116,
	minivan2 = -1126264336,
	paradise = 1488164764,
	pony = -119658072,
	pony2 = 943752001,
	rumpo = 1162065741,
	rumpo2 = -1776615689,
	rumpo3 = 1475773103,
	speedo = -810318068,
	speedo2 = 728614474,
	surfer = 699456151,
	surfer2 = -1311240698,
	taco = 1951180813,
	youga = 65402552,
	youga2 = 1026149675
}

function tvRP.vehList(radius)
	local ped = PlayerPedId()
	local veh = GetVehiclePedIsUsing(ped)
	if not IsPedInAnyVehicle(ped) then
		veh = tvRP.getNearestVehicle(radius)
	end
	if IsEntityAVehicle(veh) then
		local lock = GetVehicleDoorLockStatus(veh)
		local trunk = GetVehicleDoorAngleRatio(v,5)
		local x,y,z = table.unpack(GetEntityCoords(ped))
		for k,v in pairs(vehList) do
			if v == GetEntityModel(veh) then
				placa = string.gsub(string.gsub(GetVehicleNumberPlateText(veh), '^%s*(.-)%s*$', '%1'), '^%s*(.-)%s*$', '%1')
				local tuning = { GetNumVehicleMods(veh,13),GetNumVehicleMods(veh,12),GetNumVehicleMods(veh,15),GetNumVehicleMods(veh,11),GetNumVehicleMods(veh,16) }
				return veh,VehToNet(veh),placa,k,lock,trunk,GetDisplayNameFromVehicleModel(GetEntityModel(veh)),GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z)),tuning
			end
		end
	end
end

function tvRP.setVehicleModelsIndex(index)
  veh_models = index

  -- generate bidirectional keys
  for k,v in pairs(veh_models) do
    veh_models[v] = k
  end
end

-- veh: vehicle game id
-- return owner_user_id, vname (or nil if not managed by vRP)
function tvRP.getVehicleInfos(veh)
  if veh and DecorExistOn(veh, "vRP_owner") and DecorExistOn(veh, "vRP_vmodel") then
    local user_id = DecorGetInt(veh, "vRP_owner")
    local vmodel = DecorGetInt(veh, "vRP_vmodel")

    local vname = veh_models[vmodel]
    if vname then
      return user_id, vname
    end
  end
end

function tvRP.getModelHash(model)
	return vehList[model] or false
end

function tvRP.getHashModel(model)
	for k, v in pairs(vehList) do
		if v == model then
			return k
		end
	end
	return false
end

function tvRP.spawnGarageVehicle(name,pos) -- one vehicle per vname/model allowed at the same time

  local vehicle = vehicles[name]
  if vehicle == nil then
    -- load vehicle model
    local mhash = GetHashKey(name)

    local i = 0
    while not HasModelLoaded(mhash) and i < 10000 do
      RequestModel(mhash)
      Citizen.Wait(10)
      i = i+1
    end

    -- spawn car
    if HasModelLoaded(mhash) then
      local x,y,z = tvRP.getPosition()
      if pos then
        x,y,z = table.unpack(pos)
      end

      local nveh = CreateVehicle(mhash, x,y,z+0.5, 0.0, true, false)
      SetVehicleOnGroundProperly(nveh)
      SetEntityInvincible(nveh,false)
      SetPedIntoVehicle(PlayerPedId(),nveh,-1) -- put player inside
      SetVehicleNumberPlateText(nveh, "P "..tvRP.getRegistrationNumber())
      Citizen.InvokeNative(0xAD738C3085FE7E11, nveh, true, true) -- set as mission entity
      SetVehicleHasBeenOwnedByPlayer(nveh,true)

      -- set decorators
      DecorSetInt(veh, "vRP_owner", tvRP.getUserId())
      DecorSetInt(veh, "vRP_vmodel", veh_models[name])

      vehicles[name] = {name,nveh} -- set current vehicule

      SetModelAsNoLongerNeeded(mhash)
    end
  else
    tvRP.notify("This vehicle is already out.")
  end
end

function tvRP.despawnGarageVehicle(name)
  local vehicle = vehicles[name]
  if vehicle then
    -- remove vehicle
    SetVehicleHasBeenOwnedByPlayer(vehicle[2],false)
    Citizen.InvokeNative(0xAD738C3085FE7E11, vehicle[2], false, true) -- set not as mission entity
    SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(vehicle[2]))
    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle[2]))
    vehicles[name] = nil
    tvRP.notify("Vehicle stored.")
  end
end

-- check vehicles validity
--[[
Citizen.CreateThread(function()
  Citizen.Wait(30000)

  for k,v in pairs(vehicles) do
    if IsEntityAVehicle(v[3]) then -- valid, save position
      v.pos = {table.unpack(GetEntityCoords(vehicle[3],true))}
    elseif v.pos then -- not valid, respawn if with a valid position
      print("[vRP] invalid vehicle "..v[1]..", respawning...")
      tvRP.spawnGarageVehicle(v[1], v[2], v.pos)
    end
  end
end)
--]]

-- (experimental) this function return the nearest vehicle
-- (don't work with all vehicles, but aim to)
function tvRP.getNearestVehicles(radius)
	local r = {}
	local px,py,pz = table.unpack(GetEntityCoords(PlayerPedId()))

	local vehs = {}
	local it,veh = FindFirstVehicle()
	if veh then
		table.insert(vehs,veh)
	end
	local ok
	repeat
		ok,veh = FindNextVehicle(it)
		if ok and veh then
			table.insert(vehs,veh)
		end
	until not ok
	EndFindVehicle(it)

	for _,veh in pairs(vehs) do
		local x,y,z = table.unpack(GetEntityCoords(veh))
		local distance = Vdist(x,y,z,px,py,pz)
		if distance <= radius then
			r[veh] = distance
		end
	end
	return r
end

function tvRP.getNearestVehicle(radius)
	local veh
	local vehs = tvRP.getNearestVehicles(radius)
	local min = radius+0.0001
	for _veh,dist in pairs(vehs) do
		if dist < min then
			min = dist
			veh = _veh
		end
	end
	return veh, VehToNet(veh)
end

function tvRP.ModelName(radius)
	local veh = tvRP.getNearestVehicle(radius)
	if IsEntityAVehicle(veh) then
		local lock = GetVehicleDoorLockStatus(veh) >= 2
		local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
		local model = GetEntityModel(veh)
		local name = GetDisplayNameFromVehicleModel(model):lower()
		local plate = GetVehicleNumberPlateText(veh)
		plate = plate:gsub("%s+", "")
		return plate,name,VehToNet(veh),lock,GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z)),veh, model
	end
end

-- try to re-own the nearest vehicle
function tvRP.tryOwnNearestVehicle(radius)
  local veh = tvRP.getNearestVehicle(radius)
  if veh then
    local user_id, vname = tvRP.getVehicleInfos(veh)
    if user_id and user_id == tvRP.getUserId() then
      if vehicles[vname] ~= veh then
        vehicles[vname] = veh
      end
    end
  end
end

function tvRP.fixeNearestVehicle(radius)
  local veh = tvRP.getNearestVehicle(radius)
  if IsEntityAVehicle(veh) then
    SetVehicleFixed(veh)
  end
end

function tvRP.replaceNearestVehicle(radius)
  local veh = tvRP.getNearestVehicle(radius)
  if IsEntityAVehicle(veh) then
    SetVehicleOnGroundProperly(veh)
  end
end

-- try to get a vehicle at a specific position (using raycast)
function tvRP.getVehicleAtPosition(x,y,z)
  x = x+0.0001
  y = y+0.0001
  z = z+0.0001

  local ray = CastRayPointToPoint(x,y,z,x,y,z+4,10,PlayerPedId(),0)
  local a, b, c, d, ent = GetRaycastResult(ray)
  return ent
end

-- return ok,name
function tvRP.getNearestOwnedVehicle(radius)
  tvRP.tryOwnNearestVehicle(radius) -- get back network lost vehicles

  local px,py,pz = tvRP.getPosition()
  local min_dist
  local min_k
  for k,v in pairs(vehicles) do
    local x,y,z = table.unpack(GetEntityCoords(v[2],true))
    local dist = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)

    if dist <= radius+0.0001 then
      if not min_dist or dist < min_dist then
        min_dist = dist
        min_k = k
      end
    end
  end

  if min_k then
    return true,min_k
  end

  return false,""
end

-- return ok,x,y,z
function tvRP.getAnyOwnedVehiclePosition()
  for k,v in pairs(vehicles) do
    if IsEntityAVehicle(v[2]) then
      local x,y,z = table.unpack(GetEntityCoords(v[2],true))
      return true,x,y,z
    end
  end

  return false,0,0,0
end

-- return x,y,z
function tvRP.getOwnedVehiclePosition(name)
  local vehicle = vehicles[name]
  local x,y,z = 0,0,0

  if vehicle then
    x,y,z = table.unpack(GetEntityCoords(vehicle[2],true))
  end

  return x,y,z
end

-- return owned vehicle handle or nil if not found
function tvRP.getOwnedVehicleHandle(name)
  local vehicle = vehicles[name]
  if vehicle then
    return vehicle[2]
  end
end

-- eject the ped from the vehicle
function tvRP.ejectVehicle()
  local ped = PlayerPedId()
  if IsPedSittingInAnyVehicle(ped) then
    local veh = GetVehiclePedIsIn(ped,false)
    TaskLeaveVehicle(ped, veh, 4160)
  end
end

function tvRP.isInVehicle()
  local ped = PlayerPedId()
  return IsPedSittingInAnyVehicle(ped) 
end

-- vehicle commands
function tvRP.vc_openDoor(name, door_index)
  local vehicle = vehicles[name]
  if vehicle then
    SetVehicleDoorOpen(vehicle[2],door_index,0,false)
  end
end

function tvRP.vc_closeDoor(name, door_index)
  local vehicle = vehicles[name]
  if vehicle then
    SetVehicleDoorShut(vehicle[2],door_index)
  end
end

function tvRP.vc_detachTrailer(name)
  local vehicle = vehicles[name]
  if vehicle then
    DetachVehicleFromTrailer(vehicle[2])
  end
end

function tvRP.vc_detachTowTruck(name)
  local vehicle = vehicles[name]
  if vehicle then
    local ent = GetEntityAttachedToTowTruck(vehicle[2])
    if IsEntityAVehicle(ent) then
      DetachVehicleFromTowTruck(vehicle[2],ent)
    end
  end
end

function tvRP.vc_detachCargobob(name)
  local vehicle = vehicles[name]
  if vehicle then
    local ent = GetVehicleAttachedToCargobob(vehicle[2])
    if IsEntityAVehicle(ent) then
      DetachVehicleFromCargobob(vehicle[2],ent)
    end
  end
end

function tvRP.vc_toggleEngine(name)
  local vehicle = vehicles[name]
  if vehicle then
    local running = Citizen.InvokeNative(0xAE31E7DF9B5B132E,vehicle[2]) -- GetIsVehicleEngineRunning
    SetVehicleEngineOn(vehicle[2],not running,true,true)
    if running then
      SetVehicleUndriveable(vehicle[2],true)
    else
      SetVehicleUndriveable(vehicle[2],false)
    end
  end
end

function tvRP.vc_toggleLock(name)
  local vehicle = vehicles[name]
  if vehicle then
    local veh = vehicle[2]
    local locked = GetVehicleDoorLockStatus(veh) >= 2
    if locked then -- unlock
      SetVehicleDoorsLockedForAllPlayers(veh, false)
      SetVehicleDoorsLocked(veh,1)
      SetVehicleDoorsLockedForPlayer(veh, PlayerId(), false)
      tvRP.notify("Vehicle unlocked.")
    else -- lock
      SetVehicleDoorsLocked(veh,2)
      SetVehicleDoorsLockedForAllPlayers(veh, true)
      tvRP.notify("Vehicle locked.")
    end
  end
end

RegisterCommand("vehhash", function(source, args, raw)
	local mhash = GetHashKey(args[1])
	local ped = PlayerPedId()
	local c = 0
	while not HasModelLoaded(mhash) and c < 5 do
		RequestModel(mhash)
		Citizen.Wait(100)
		c = c+1
	end
	if HasModelLoaded(mhash) then
		local nveh = CreateVehicle(mhash,GetEntityCoords(ped),GetEntityHeading(ped),false,false)
		vRP.prompt("","{ ['name'] = '"..args[1].."', ['hash'] = "..GetEntityModel(nveh)..", ['banned'] = false },")
		SetModelAsNoLongerNeeded(mhash)
		SetEntityAsNoLongerNeeded(nveh)
		DeleteEntity(nveh)
	end
end)
local cfg = {}

local surgery_male = { model = "mp_m_freemode_01" }
local surgery_female = { model = "mp_f_freemode_01" }

for i=0,19 do
  surgery_female[i] = {0,0}
  surgery_male[i] = {0,0}
end


cfg.cloakroom_types = {
  ["policia"] = {
    _config = { permissions = {"police.cloakroom"} },
    ["Homem"] = {
      [3] = {30,0},
      [4] = {25,2},
      [6] = {24,0},
      [8] = {58,0},
      [11] = {55,0},
      ["p2"] = {2,0}
    },
    ["Mulher"] = {
      [3] = {35,0},
      [4] = {30,0},
      [6] = {24,0},
      [8] = {6,0},
      [11] = {48,0},
      ["p2"] = {2,0}
    }
  },
  ["Lixeiro"] = {
    _config = { permissions = {"lixo.perm"} },
    ["Homem"] = {
			[1] = { 0,0 }, -- Mascara
			[5] = { -1,0 }, -- Mochila
			[7] = { -1,0 }, -- Indefinido
			[3] = { 0,0 },  -- Braço
			[4] = { 36,0 }, -- Calça
			[8] = { 59,0 }, -- Blusa
			[6] = { 35,0 }, -- Tenis
			[11] = { 89,1 }, -- Camisa
			[9] = { -1,0 },  -- Colete
			[10] = { -1,0 },
			["p0"] = { 5,0 }, -- capacete
			["p1"] = { 19,5 }, -- oculos
			["p2"] = { -1,0 },
			["p6"] = { -1,0 },
			["p7"] = { -1,0 }
    },
    ["Mulher"] = {
      [3] = {35,0},
      [4] = {30,0},
      [6] = {24,0},
      [8] = {6,0},
      [11] = {48,0},
      ["p2"] = {2,0}
    }
  },
}

cfg.cloakrooms = {
  {"policia",  458.733, -993.372, 30.000},
  {"Lixeiro", -321.586, -1545.913, 31.019},
}

return cfg

local cfg = {}

cfg.policia = {
    ['Delegacia Praça'] = {
        ['blip'] = {nome = 'Delegacia', id = 60, cor = 3, x = 458.407, y = -990.927, z = 30.689},
        ['cofre'] = {x = 23.886, y = -1105.905, z = 29.797},
        ['servico'] = {
            ['entrar'] = {x = 458.407, y = -990.927, z = 30.689},
            ['uniforme'] = {
                ['mp_m_freemode_01'] = {
                    [3] = {30,0},
                    [4] = {25,2},
                    [6] = {24,0},
                    [8] = {58,0},
                    [11] = {55,0},
                    ['p2'] = {2,0},
                    ['p0'] = {46,0}
                },
                ['mp_f_freemode_01'] = {
                    [3] = {35,0},
                    [4] = {30,0},
                    [6] = {24,0},
                    [8] = {6,0},
                    [11] = {48,0},
                    ['p2'] = {2,0},
                    ['p0'] = {45,0}
                }
            }
        },
        ['arsenal'] = {
            ['localizacao'] = {x = 452.226, y = -980.205, z = 30.689},
            ['equipamentos'] = {
                ['WEAPON_PISTOL'] = {nome = 'Pistola', tipo = 'pistola', quantidade = 99, img = 'https://vignette.wikia.nocookie.net/gtawiki/images/d/d3/Pistol.50-GTAVPC-HUD.png/revision/latest?cb=20150419121107'}, 
                ['WEAPON_COMBATPISTOL'] = {nome = 'Combat Pistol', tipo = 'pistola', quantidade = 99, img = 'https://vignette.wikia.nocookie.net/gtawiki/images/0/0c/Pistol50-GTAV-HUD.png/revision/latest?cb=20140823221130' }, 
                ['WEAPON_CARBINERIFLE'] = {nome = 'Carbine Rifle', tipo = 'rifle', quantidade = 99, img = 'https://vignette.wikia.nocookie.net/gtawiki/images/7/7a/CarbineRifle-GTAVPC-HUD.png/revision/latest/scale-to-width-down/185?cb=20150419121949' }, 
                ['WEAPON_ASSAULTRIFLE'] = { nome = 'Assault Rifle', tipo = 'rifle', quantidade = 99, img = 'https://i.imgur.com/IUEUsJk.png' }
            }
        },
        ['garagem'] = {
            ['acessar'] = {x = 452.772, y = -1020.803, z = 28.347},
            ['spawn'] = {
                {x = 427.565, y = -1028.308, z = 28.986, h = 2.475},
                {x = 431.230, y = -1027.749, z = 28.920, h = 2.475},
                {x = 434.916, y = -1027.306, z = 28.853, h = 2.475},
                {x = 439.292, y = -1027.312, z = 28.777, h = 2.475},
                {x = 442.362, y = -1026.780, z = 28.719, h = 2.475},
                {x = 445.764, y = -1026.235, z = 28.654, h = 2.475},
            }
        }
    },
}

cfg.prisao = {
    ['uniforme'] = {
        ['mp_m_freemode_01'] = {
            [3] = {0,0,2},
            [4] = {3,7,2},
            [6] = {34,0,2},
            [8] = {15,0,2},
            [11] = {1,11,2},
            ['p0'] = {8,0},
            ['p1'] = {0,0},
            ['p2'] = {6,0},
            ['p6'] = {2,0}
        },
        ['mp_f_freemode_01'] = {
            [3] = {35,0},
            [4] = {30,0},
            [6] = {24,0},
            [8] = {6,0},
            [11] = {48,0},
            ['p2'] = {2,0},
            ['p0'] = {45,0}
        }
    }
}

cfg.ilegais = {
    ["folhacoca"] = true,
    ["podecocaina"] = true,
    ["cocaina"] = true,
    ["heroina"] = true,
    ["plantademaconha"] = true,
    ["maconha"] = true,
    ["dinheirosujo"] = true,
	["wbody|WEAPON_DAGGER"] = true,
	["wbody|WEAPON_BAT"] = true,
	["wbody|WEAPON_BOTTLE"] = true,
	["wbody|WEAPON_CROWBAR"] = true,
	["wbody|WEAPON_FLASHLIGHT"] = true,
	["wbody|WEAPON_GOLFCLUB"] = true,
	["wbody|WEAPON_HAMMER"] = true,
	["wbody|WEAPON_HATCHET"] = true,
	["wbody|WEAPON_KNUCKLE"] = true,
	["wbody|WEAPON_KNIFE"] = true,
	["wbody|WEAPON_MACHETE"] = true,
	["wbody|WEAPON_SWITCHBLADE"] = true,
	["wbody|WEAPON_NIGHTSTICK"] = true,
	["wbody|WEAPON_WRENCH"] = true,
	["wbody|WEAPON_BATTLEAXE"] = true,
	["wbody|WEAPON_POOLCUE"] = true,
	["wbody|WEAPON_STONE_HATCHET"] = true,
	["wbody|WEAPON_PISTOL"] = true,
	["wbody|WEAPON_COMBATPISTOL"] = true,
	["wbody|WEAPON_APPISTOL"] = true,
	["wbody|WEAPON_CARBINERIFLE"] = true,
	["wbody|WEAPON_SMG"] = true,
	["wbody|WEAPON_PUMPSHOTGUN_MK2"] = true,
	["wbody|WEAPON_STUNGUN"] = true,
	["wbody|WEAPON_NIGHTSTICK"] = true,
	["wbody|WEAPON_SNSPISTOL"] = true,
	["wbody|WEAPON_MICROSMG"] = true,
	["wbody|WEAPON_ASSAULTRIFLE"] = true,
	["wbody|WEAPON_FIREEXTINGUISHER"] = true,
	["wbody|WEAPON_FLARE"] = true,
	["wbody|WEAPON_REVOLVER"] = true,
	["wbody|WEAPON_PISTOL_MK2"] = true,
	["wbody|WEAPON_VINTAGEPISTOL"] = true,
	["wbody|WEAPON_MUSKET"] = true,
	["wbody|WEAPON_GUSENBERG"] = true,
	["wbody|WEAPON_ASSAULTSMG"] = true,
	["wbody|WEAPON_COMBATPDW"] = true,
	["wbody|WEAPON_SPECIALCARBINE_MK2"] = true,
	["wbody|WEAPON_PISTOL50"] = true,
	["wbody|WEAPON_REVOLVER_MK2"] = true,
	["wammo|WEAPON_DAGGER"] = true,
	["wammo|WEAPON_BAT"] = true,
	["wammo|WEAPON_BOTTLE"] = true,
	["wammo|WEAPON_CROWBAR"] = true,
	["wammo|WEAPON_FLASHLIGHT"] = true,
	["wammo|WEAPON_GOLFCLUB"] = true,
	["wammo|WEAPON_HAMMER"] = true,
	["wammo|WEAPON_HATCHET"] = true,
	["wammo|WEAPON_KNUCKLE"] = true,
	["wammo|WEAPON_KNIFE"] = true,
	["wammo|WEAPON_MACHETE"] = true,
	["wammo|WEAPON_SWITCHBLADE"] = true,
	["wammo|WEAPON_NIGHTSTICK"] = true,
	["wammo|WEAPON_WRENCH"] = true,
	["wammo|WEAPON_BATTLEAXE"] = true,
	["wammo|WEAPON_POOLCUE"] = true,
	["wammo|WEAPON_STONE_HATCHET"] = true,
	["wammo|WEAPON_PISTOL"] = true,
	["wammo|WEAPON_COMBATPISTOL"] = true,
	["wammo|WEAPON_APPISTOL"] = true,
	["wammo|WEAPON_CARBINERIFLE"] = true,
	["wammo|WEAPON_SMG"] = true,
	["wammo|WEAPON_PUMPSHOTGUN_MK2"] = true,
	["wammo|WEAPON_STUNGUN"] = true,
	["wammo|WEAPON_NIGHTSTICK"] = true,
	["wammo|WEAPON_SNSPISTOL"] = true,
	["wammo|WEAPON_MICROSMG"] = true,
	["wammo|WEAPON_ASSAULTRIFLE"] = true,
	["wammo|WEAPON_FIREEXTINGUISHER"] = true,
	["wammo|WEAPON_FLARE"] = true,
	["wammo|WEAPON_REVOLVER"] = true,
	["wammo|WEAPON_PISTOL_MK2"] = true,
	["wammo|WEAPON_VINTAGEPISTOL"] = true,
	["wammo|WEAPON_MUSKET"] = true,
	["wammo|WEAPON_GUSENBERG"] = true,
	["wammo|WEAPON_ASSAULTSMG"] = true,
	["wammo|WEAPON_SPECIALCARBINE_MK2"] = true,
	["wammo|WEAPON_PISTOL50"] = true,
	["wammo|WEAPON_REVOLVER_MK2"] = true,
	["wammo|WEAPON_COMBATPDW]"] = true,
}

cfg.veiculos = {
    ['Garagem LSPD 1'] = {
        -- Carros
        { modelo = 'bmwpm', nome = 'BMW', tipo = 'carro', quantidade = 1000, img = 'https://i.imgur.com/00I8B0G.png' },
        { modelo = 'rocam', nome = 'PM Rocam', tipo = 'moto', quantidade = 1000, img = 'https://i.imgur.com/1io7Cus.png' },
        { modelo = 'riot', nome = 'Caminhão Blindado', tipo = 'carro', quantidade = 1000, img = 'https://i.imgur.com/c5Dn0fi.png' },
        { modelo = 'pbus', nome = 'Onibus Blindado', tipo = 'carro', quantidade = 1000, img = 'https://i.imgur.com/U2evSuY.png' },
        { modelo = 'x5pm', nome = 'BMW X6', tipo = 'carro', quantidade = 1000, img = 'https://i.imgur.com/PsadI37.png' },
        { modelo = 'aguiapm', nome = 'Águia PM', tipo = 'carro', quantidade = 1000, img = 'https://imgur.com/6CQq98l' },
    }
}

return cfg
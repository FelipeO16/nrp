local cfg = {}

cfg.ems = {
    ["Hospital"] = {
        ['blip'] = {nome = "Hospital", id = 61, cor = 1, x = 299.217, y = -584.727, z = 43.260},
        ['cofre'] = {x = 23.886, y = -1105.905, z = 29.797},
        ['servico'] = {
            ['entrar'] = {x = 310.762, y = -599.333, z = 43.291},
            ['uniforme'] = {
                ["mp_m_freemode_01"] = {
                    [3] = {92,0},
                    [4] = {9,3},
                    [6] = {21,0},
                    [8] = {15,0},
                    [11] = {13,3}
                },
                ["mp_f_freemode_01"] = {
                    [3] = {35,0},
                    [4] = {30,0},
                    [6] = {24,0},
                    [8] = {6,0},
                    [11] = {48,0},
                    ["p2"] = {2,0},
                    ["p0"] = {45,0}
                }
            }
        },
        ['garagem'] = {
            ['acessar'] = {x = 309.801, y = -602.812, z = 43.291},
            ['spawn'] = {
                {x = 296.033, y = -604.757, z = 43.313, h = 69.128},
                {x = 293.549, y = -609.324, z = 43.351, h = 69.128},
            }
        }
    },
}

cfg.veiculos = {
    ["Garagem EMS 1"] = {
        { modelo = "Ambulance", nome = "Ambulancia", tipo = "carro", quantidade = 99, img = "https://vignette.wikia.nocookie.net/gtawiki/images/e/ee/Ambulance-GTAV-front-LSMC.png/revision/latest/scale-to-width-down/350?cb=20160116221217" },
    }
}

return cfg
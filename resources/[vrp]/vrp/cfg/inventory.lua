
local cfg = {}

cfg.inventario_peso_padrao = 10 -- peso padrão que o usuário irá começar
cfg.inventario_peso_por_level = 1 -- peso para um inventário de usuário por level (sem unidade, mas pensando em "kg" é uma boa norma)

-- peso padrão para bau dos carros
cfg.default_vehicle_chest_weight = 50

-- define o peso de um veiculo pelo model (letra minúscula)
cfg.vehicle_chest_weights = {
  ["monster"] = 250
}

-- lista de bau estatico (map of name => {.title,.blipid,.blipcolor,.weight, .permissions (optional)})
cfg.static_chest_types = {
  ["Bau"] = { -- example of a static chest
    title = "Bau inicial",
    blipid = 205,
    blipcolor = 5,
    weight = 100
  }
}

-- coordenadas dos baus estaticos
cfg.static_chests = {
  --[[ {"chest", 1855.13940429688,3688.68579101563,34.2670478820801} ]]
}

return cfg

local cfg = {}

--[[
	** Onde encontrar blip e cor: https://wiki.gtanet.work/index.php?title=Blips
	Modelo Garagem
		info
			-- Tipos (carro|moto|caminhao|heli) tem que ser no formato 'tipo=true'
			-- ID é o id do blip
			-- cor é a cor do blip
			-- home = nome da casa (somente usar se for garagem de casa)
		
		coords = {x = x,y = y,z = z}
		
		spawn
			coordenadas da vaga onde cada carro vai spawnar, multiplas vagas são suportadas.
		
	-- Exemplo
	["Nome da Garagem"] = {
		info = {tipo = {carro = true}, id = 357, cor = 3},
		coords = {x = 55.43, y = -876.19, z = 30.66 },
		spawn = {
			{x = 50.66, y = -873.02, z = 30.45, h = 159.65}, 
			{x = 47.34, y = -871.81, z = 30.45, h = 247.610},
			{x = 44.17, y = -870.50, z = 30.45, h = 159.65},
		}
	},
	
	-- Exemplo 2
	["Nome da Garagem"] = {
		info = {tipo = {carro = tru, moto = truee}, id = 357, cor = 3, home="Mansao 1"},
		coords = {x = 55.43, y = -876.19, z = 30.66 },
		spawn = {
			{x = 50.66, y = -873.02, z = 30.45, h = 159.65}, 
			{x = 47.34, y = -871.81, z = 30.45, h = 247.610},
			{x = 44.17, y = -870.50, z = 30.45, h = 159.65},
		}
	},
]]

cfg.garagem = {
	["Garagem 1"] = {
		info = { nome= "Garagem", tipo = {carro = true, moto = true, caminhao = true}, id = 357, cor = 3},
		coords = {x = 55.43, y = -876.19, z = 30.66 },
		spawn = {
			{x = 50.66, y = -873.02, z = 30.45, h = 159.65}, 
			{x = 47.34, y = -871.81, z = 30.45, h = 247.610},
			{x = 44.17, y = -870.50, z = 30.45, h = 159.65},
	
		}
	}
}

cfg.rent = {
	["Mecânico"] = {
		perm = "mecanico.permissao",
		coords = {
			{x = 888.97, y = -1028.11, z = 35.12}
		},
		carros = {
			"flatbed",
			"towtruck",
			"towtruck2",
			"slamvan3",

		},
		spawn = {
			{ x = 893.31, y = -1023.89, z = 35.06, h = 270.14 },
			{ x = 903.01, y = -1028.97, z = 35.06, h = 359.74 },
		}
	},
	["Taxista"] = {
		perm = "taxista.permissao",
		coords = {
			{x = 895.36, y = -179.28, z = 74.70}
		},
		carros = {
			"taxi",

		},
		spawn = {
			{ x = 900.05, y = -180.84, z = 73.02, h = 237.93},
			{ x = 898.10, y = -183.93, z = 72.94, h = 237.93}
		}
	},
}
return cfg
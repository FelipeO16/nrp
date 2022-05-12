local cfg = {}

cfg.gunshop = {
    ["Loja de Armas (Praça 2)"] = {
        info = { nome = "Loja de Armas", id = 110, cor = 75, x = 22.018, y = -1106.823, z = 29.810 },
        comprar = {x = 20.241, y = -1106.540, z = 29.797},
        cofre = {
            ["posicao"] = { x = 23.886, y = -1105.905, z = 29.797 },
            ["limite"] = 500000
        },
        estoque = {
            ["WEAPON_PISTOL"] = {nome = "Pistola", quantidade = 99, preco = 1000, descricao = "Aqui vai a descricao da arma selecionada", img = "https://vignette.wikia.nocookie.net/gtawiki/images/d/d3/Pistol.50-GTAVPC-HUD.png/revision/latest?cb=20150419121107" }
        },
        preco = 1958000,
        a_venda = true
    },
    ["Loja de Armas (Praça)"] = {
        info = { nome = "Loja de Armas", id = 110, cor = 75, x = 252.290, y = -50.132, z = 69.941 },
        comprar = {x = 252.914, y = -48.187, z = 69.941},
        cofre = {
            ["posicao"] = { x = 253.364, y = -51.809, z = 69.941 },
            ["limite"] = 500000
        },
        estoque = {
            ["WEAPON_PISTOL"] = {nome = "Pistola", quantidade = 90, preco = 1000, descricao = "Aqui vai a descricao da arma selecionada", img = "https://vignette.wikia.nocookie.net/gtawiki/images/d/d3/Pistol.50-GTAVPC-HUD.png/revision/latest?cb=20150419121107"}, 
            ["WEAPON_COMBATPISTOL"] = {nome = "Combat Pistol", quantidade = 80, preco = 1500, descricao = "Aqui vai a descricao da arma selecionada", img = "https://vignette.wikia.nocookie.net/gtawiki/images/0/0c/Pistol50-GTAV-HUD.png/revision/latest?cb=20140823221130" }, 
            ["WEAPON_CARBINERIFLE"] = {nome = "Carbine Rifle", quantidade = 70, preco = 25000, descricao = "Aqui vai a descricao da arma selecionada", img = "https://vignette.wikia.nocookie.net/gtawiki/images/7/7a/CarbineRifle-GTAVPC-HUD.png/revision/latest/scale-to-width-down/185?cb=20150419121949" }, 
            ["WEAPON_ASSAULTRIFLE"] = { nome = "Assault Rifle", quantidade = 60, preco = 35000, descricao = "Aqui vai a descricao da arma selecionada", img = "https://i.imgur.com/IUEUsJk.png" }
        },
        preco = 1250000,
        a_venda = true
    }
}

return cfg
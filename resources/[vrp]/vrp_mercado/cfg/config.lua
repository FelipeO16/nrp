local cfg = {}

cfg.mercado = {
    ["Mercado (Praça 2)"] = {
        info = { nome = "Mercadinho", id = 52, cor = 2, x = -48.298, y = -1757.389, z = 29.420 },
        comprar = {x = -53.419, y = -1757.285, z = 29.439},
		assalto = {tempoAssalto = 200 , policiais = 2, porcentagemAssalto = 70},
        cofre = {
            ["posicao"] = { x = -43.296, y = -1748.408, z = 29.000 },
            ["limite"] = 200000
        },
        estoque = {
            ["cafe"] = {quantidade = 99, preco = 1000},
        },
        preco = 1958000,
        a_venda = true
    },
    ["Mercado (Praça)"] = {
        info = { nome = "Mercadinho", id = 52, cor = 2, x = 25.794, y = -1345.307, z = 29.497},
        comprar = {x = 29.210, y = -1350.065, z = 29.330},
		assalto = {tempoAssalto = 200 , policiais = 2, porcentagemAssalto = 70},
        cofre = {
            ["posicao"] = { x = 28.227, y = -1339.133, z = 29.000 },
            ["limite"] = 200000
        },
        estoque = {
            ["caldo"] = {quantidade = 90, preco = 1000},
        },
        preco = 1250000,
        a_venda = true
    }
}

return cfg
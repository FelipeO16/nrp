local cfg = {}

cfg.limite = 2

cfg.concessionaria = {
    ['Concessionaria'] = {
        info = {
            nome = "Concessionaria",
            id = 225,
            cor = 62,
            x = -29.842,
            y = -1104.661,
            z = 26.422
        },
        estoque = {
            ["t20"] = {
                nome = "T20",
                tipo = "carro",
                precocarro = 600000,
                pesocarro = 50,
                imagemcarro = "",
                show = true
            },
            ["bati"] = {
                nome = "bati",
                tipo = "moto",
                precocarro = 120000,
                pesocarro = 50,
                imagemcarro = "https://images.vexels.com/media/users/3/243502/isolated/lists/2538d955e76a172308979f140f69384e-conjunto-de-motocicleta-4.png",
                show = true
            }
        }
    }
}

return cfg

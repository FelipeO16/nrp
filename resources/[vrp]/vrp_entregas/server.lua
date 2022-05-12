local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local cfg = module("vrp_entregas", "cfg/config")

vRPcs = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_entregas",vRPcs)
Proxy.addInterface("vrp_entregas",vRPcs)

vRP._prepare("sRP/fabricas",[[
    CREATE TABLE IF NOT EXISTS vrp_entregas(
        id INTEGER AUTO_INCREMENT,
        nome VARCHAR(255),
        quantidade TEXT,
        CONSTRAINT pk_fabricas PRIMARY KEY(id)
    )
]])

vRP._prepare("sRP/inserir_empresa","INSERT INTO vrp_entregas(nome, quantidade) VALUES(@nome, @quantidade)")
vRP._prepare("sRP/selecionar_empresa","SELECT * FROM vrp_entregas")

async(function()
    vRP.execute("sRP/fabricas")
end)

local fabrica = cfg.fabrica

function criarCasa()
    local rows = vRP.query("sRP/selecionar_empresa")
    for k,v in pairs(fabrica) do
        if #rows == 0 then
            vRP.execute("sRP/inserir_empresa", {
                nome = fabrica[k].nome,
                quantidade = json.encode(fabrica[k].quantidade)
            })
        end
    end
    return false
end

Citizen.CreateThread(function()
    criarCasa()
end)
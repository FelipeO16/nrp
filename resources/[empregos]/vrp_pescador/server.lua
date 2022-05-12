local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPjob = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_pescador",vRPjob)
Proxy.addInterface("vrp_pescador",vRPjob)

local Vestido = false

local peixes = {
    {id = "sardinha", preco = 10},
    {id = "peixegato", preco = 5},
    {id = "salmao", preco = 5},
    {id = "corvina", preco = 5}
}

function vRPjob.Permissao()
    local user_id = vRP.getUserId(source)
    return vRP.hasPermission(user_id, "pesca.perm")
end

function vRPjob.VaraDePescar()
    local user_id = vRP.getUserId(source)
    return vRP.hasPermission(user_id, "#varadepescar.1")
end

function vRPjob.pescarPeixe()
    local source = source
    local user_id = vRP.getUserId(source)
    local quantidade = math.random(1, 10)
    local peixe = peixes[math.random(1, #peixes)]
    
    if ((vRP.getInventoryWeight(user_id)+vRP.getItemWeight(peixe.id)) <= vRP.getInventoryMaxWeight(user_id)) then
        vRP.giveInventoryItem(user_id,peixe.id,quantidade,true)
        vRP.varyExp(user_id, "exp", "level", 1)
    else
        vRPclient.notify(vRP.getUserSource(user_id), "~r~Seu inventory esta cheio.")
    end
end

function vRPjob.VenderPeixeSV()
	local source = source
    local user_id = vRP.getUserId(source)
    for k,v in pairs(peixes) do
        local peixe = peixes[k]
        local peixeAmount = vRP.getInventoryItemAmount(user_id, peixe.id)
        if peixeAmount ~= 0 then
            local amount = peixeAmount * peixe.preco
            vRP.giveMoney(user_id, amount)
            vRP.tryGetInventoryItem(user_id, peixe.id, peixeAmount, false)
            vRPclient._notify(source, "Você vendeu "..peixe.id.." por "..amount.." !")
        end
    end
end

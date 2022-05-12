local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_roupas")
vRPloja = Tunnel.getInterface("vrp_roupas")

RegisterServerEvent("LojaDeRoupas:Comprar")
AddEventHandler("LojaDeRoupas:Comprar", function(preco)
    local user_id = vRP.getUserId(source)
    if preco then
        if vRP.tryPayment(user_id, preco) then
            vRPclient.notify(source, "[Loja de Roupas] Você fez um pagamento de: R$"..preco)
            TriggerClientEvent('LojaDeRoupas:ReceberCompra', source, true)
        else
            vRPclient.notify(source, "[Loja de Roupas] Você não tem dinheiro suficiente")
            TriggerClientEvent('LojaDeRoupas:ReceberCompra', source, false)
        end
    end
end)


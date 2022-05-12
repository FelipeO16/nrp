local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

yFK = {}
Tunnel.bindInterface("yang_fuckyou",yFK)
yBS =  Proxy.getInterface("vRP")


function yFK.endMe()
	yBS.ban(yBS.getUserId(source), "É a própria mente de um homem, e não seu inimigo ou adversário, que o seduz para caminhos maléficos.")
end
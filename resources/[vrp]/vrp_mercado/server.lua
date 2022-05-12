local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local cfg = module("vrp_mercado", "cfg/config")

vRPmc = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_mercado",vRPmc)
Proxy.addInterface("vrp_mercado",vRPmc)

exports['GHMattiMySQL']:QueryAsync([[
    CREATE TABLE IF NOT EXISTS vrp_mercado(
      id int(11) NOT NULL AUTO_INCREMENT,
      id_dono int(11) DEFAULT NULL,
      nome VARCHAR(255) DEFAULT NULL,
      preco INTEGER DEFAULT NULL,
      a_venda BOOLEAN DEFAULT NULL,
      estoque TEXT,
      cofre INTEGER,
      cofreLimite INTEGER,
      CONSTRAINT pk_mercado PRIMARY KEY(id)
    )
]])

vRP._prepare("NL/inserir_mercados","INSERT INTO vrp_mercado(id_dono, nome, preco, a_venda, estoque, cofre, cofreLimite) VALUES(@id_dono, @nome, @preco, @a_venda, @estoque, @cofre, @cofreLimite)")
vRP._prepare("NL/get_estoque_mercado","SELECT estoque FROM vrp_mercado WHERE nome = @nome")
vRP._prepare("NL/set_estoque_mercado","UPDATE vrp_mercado SET estoque = @estoque WHERE nome = @nome")
vRP._prepare("NL/get_cofre_mercado","SELECT cofre, cofreLimite FROM vrp_mercado WHERE nome = @nome")
vRP._prepare("NL/set_cofre_mercado","UPDATE vrp_mercado SET cofre = @cofre WHERE nome = @nome")
vRP._prepare("NL/comprar_mercado","UPDATE vrp_mercado SET id_dono = @id_dono, a_venda = @a_venda WHERE nome = @nome")
vRP._prepare("NL/selecionar_mercado_notvenda","SELECT * FROM vrp_mercado WHERE a_venda = 0 AND id_dono <> 0")
vRP._prepare("NL/selecionar_mercado","SELECT * FROM vrp_mercado")
vRP._prepare("NL/selecionar_mercado_nome","SELECT * FROM vrp_mercado WHERE nome = @nome")


Citizen.CreateThread(function()
  CriarProdutos()
end)

local mercado = cfg.mercado

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function vRPmc.dono()
  local user_id = vRP.getUserId(source)
  return user_id
end

function vRPmc.PermGroup()
  local user_id = vRP.getUserId(source)
  return vRP.hasPermission(user_id, "pesca.perm")
end

function getEstoque(nome)
  local rows = vRP.query("NL/get_estoque_mercado", {nome = nome})
  if #rows > 0 then
    return json.decode(rows[1].estoque)
  else
    return {}
  end
end

function setEstoque(nome,estoque)
  vRP.execute("NL/set_estoque_mercado", {nome = nome, estoque = json.encode(estoque)})
end

function getCofre(nome)
  local rows = vRP.query("NL/get_cofre_mercado", {nome = nome})
  if #rows > 0 then
    return json.decode(rows[1].cofre), rows[1].cofreLimite
  else
    return {}
  end
end

function setCofre(nome,cofre,source)
  vRP.execute("NL/set_cofre_mercado", {nome = nome, cofre = cofre})
  enviarLojas()
end

function CriarProdutos()
	local rows = vRP.query("NL/selecionar_mercado")
	for k,v in pairs(mercado) do
		if #rows == 0 then
		vRP.execute("NL/inserir_mercados", {
			['id_dono'] = 0,
			['nome'] = k,
			['preco'] = mercado[k].preco,
			['a_venda'] = mercado[k].a_venda,
			['estoque'] = json.encode(mercado[k].estoque),
			['cofre'] = 0,
			['cofreLimite'] = mercado[k].cofre.limite
			})
		end
	end
	return false
end

function getMercado(nome)
  local rows = vRP.query("NL/selecionar_mercado_nome", {nome = nome})
  for k,v in pairs(rows) do
    return v
  end
end

function enviarLojas()
  local lojas = {}
  local rows = vRP.query("NL/selecionar_mercado")
  for k,v in pairs(rows) do
    lojas[v.nome] = v
  end
  TriggerClientEvent('Mercado:receberLojas', -1, lojas)
end

function stringsplit(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

function addCommam(amount)
local formatted = amount
while true do  
  formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
  if (k==0) then
    break
  end
end
return formatted
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EVENTOS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent('Mercado:EnviarProdutos')
AddEventHandler('Mercado:EnviarProdutos', function(nome)
    local loja = {}
    local inventario = {}
    local source = source
    local user_id = vRP.getUserId(source)
    local dinheiro = addCommam(math.floor(vRP.getMoney(user_id)))
    local weight = vRP.getInventoryWeight(user_id)
    local max_weight = vRP.getInventoryMaxWeight(user_id)
    local identity = vRP.getUserIdentity(user_id)
    local data = getEstoque(nome)
    for k,v in pairs(vRP.getInventory(user_id)) do
      inventario[k] = {
        ['amount'] = v.amount,
        ['name'] = vRP.getItemName(k)
      }
    end
    for k,v in pairs(data) do
      loja[k] = {
        ['nomeLoja'] = nome,
        ['nomeProduto'] = vRP.getItemName(k),
        ['modelo'] = k,
        ['preco'] = v.preco,
        ['descricao'] = v.descricao,
        ['quantidade'] = v.quantidade
      }
    end
  TriggerClientEvent('Mercado:ReceberAnuncio', source, loja, inventario, dinheiro, weight, max_weight, identity.name.." "..identity.firstname)
end)


RegisterServerEvent('Mercado:Comprar')
AddEventHandler('Mercado:Comprar', function(nome, loja)
    local source = source
    local user_id = vRP.getUserId(source)
    local estoque = getEstoque(loja)
    local produtos = stringsplit(nome, ",")
    for k,v in pairs(produtos) do

      if estoque[v].quantidade > 0 then
        if ((vRP.getInventoryWeight(user_id)+vRP.getItemWeight(v)) <= vRP.getInventoryMaxWeight(user_id)) then
          if vRP.tryPayment(user_id, tonumber(estoque[v].preco)) then
            local cofreAtual, limite = getCofre(loja)
            --estoque[v].quantidade = estoque[v].quantidade - 1
            vRP.giveInventoryItem(user_id, v, 1)

            if (cofreAtual < limite) then
              local valorTotal = cofreAtual + tonumber(estoque[v].preco)
              setCofre(loja, valorTotal, source)
            end
            setEstoque(loja, estoque)
          else
            vRPclient._notify(source, "["..loja.."] Você não tem dinheiro suficiente")
          end
        else
          vRPclient._notify(source, "Inventário cheio!")
        end

      else
        vRPclient._notify(source, "Esse produto está sem estoque!")
      end
    end
end)

RegisterServerEvent('Mercado:RetirarDinheiro')
AddEventHandler('Mercado:RetirarDinheiro', function(nome)
  local source = source
  local user_id = vRP.getUserId(source)
  local rows = vRP.query("NL/selecionar_mercado_nome", {nome = nome})
  if user_id == rows[1].id_dono then
    if rows[1].cofre > 0 then
      vRP.giveInventoryItem(user_id, "dinheiro", rows[1].cofre)
      setCofre(nome, 0, source)
    end
  end
end)

RegisterServerEvent('Mercado:Anunciar')
AddEventHandler('Mercado:Anunciar', function(nome, produto, preco, estoque, foto)
  local source = source
  local user_id = vRP.getUserId(source)
  local amount = vRP.getInventoryItemAmount(user_id, produto)
  if amount >= estoque then
    local pegarEstoque = getEstoque(nome)
    if pegarEstoque[produto] then
      local protudoQtd = pegarEstoque[produto].quantidade
      if protudoQtd > 0 then
        protudoQtd = protudoQtd + 1
        setEstoque(nome, pegarEstoque)
        vRP.tryGetInventoryItem(user_id, produto, estoque, false)
      end
    else
      pegarEstoque[produto] = {nome = vRP.getItemName(produto), quantidade = estoque, preco = preco}
      setEstoque(nome, pegarEstoque)
      vRP.tryGetInventoryItem(user_id, produto, estoque, false)
    end
  else
    vRPclient._notify(source, "Voce nao tem essa quantidade no inventário!")
  end
end)

RegisterServerEvent('Mercado:comprarLoja')
AddEventHandler('Mercado:comprarLoja', function(nome, preco)
  local mercado = {}
  local source = source
  local user_id = vRP.getUserId(source)
  local info = getMercado(nome)

  if info.a_venda then

    if vRP.tryPayment(user_id, tonumber(preco)) then
      vRP.execute("NL/comprar_mercado", {
        ['nome'] = nome,
        ['id_dono'] = user_id,
        ['a_venda'] = false
      })
      enviarLojas()
      vRPclient._notify(source, "Parabéns! Você comprou o comércio: "..nome)
    else
      vRPclient._notify(source, "Você não tem dinheiro suficiente!")
    end

  end
end)
---------------------------------------------------------------------------------------------------------------------------
-- EVENTOS VRP
---------------------------------------------------------------------------------------------------------------------------
AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
  if user_id then
    enviarLojas()
    for uid,src in pairs(vRP.getUsers()) do
      TriggerClientEvent("Mercado:InserirUsers",source,uid,src)
    end
  end
end)

AddEventHandler("vRP:playerLeave",function(user_id, source) 
  for uid,src in pairs(vRP.getUsers()) do
    TriggerClientEvent("Mercado:RemoverUsers",source,uid)
	end
end)
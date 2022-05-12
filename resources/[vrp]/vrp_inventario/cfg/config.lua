Config = {}

Config.OpenMenu = 311 -- Key: K
Config.AntiSpamCooldown = 2
Config.Language = {
Title = "Inventário",
PleaseWait = "Por favor aguarde ...",
Error = "Ocorreu um problema.",
WarningTitle = "Atenção",
WeaponNotEquipped = "Você não tem a arma para essa munição.",
CannotBeUsed = "Este item não pode ser usado no seu inventário",
NotEnoughtSpace = "A pessoa não tem espaço em sua mochila",
NoNearby = "Não há pessoas próximas",
MochilaCheia = "Esvazie a mochila primeiro."
}

items = {}

items["maconha"] = {ftype="drogaanim", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="weed.png", action="Usar"}
items["folhamaconha"] = {ftype="drogaanim", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="weed.png", action="Usar"}
items["bombaadesiva"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="bomb.png", action="Usar"}
items["computador"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="laptop.png", action="Usar"}
items["broca"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="drill.png", action="Usar"}
items["encomenda"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="encomenda.png", action="Usar"}
items["repairkit"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="repairkit.png", action="Usar"}
items["serra"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="serra.png", action="Usar"}
items["furadeira"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="furadeira.png", action="Usar"}
items["c4"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="c4.png", action="Usar"}
items["mochila"] = {ftype="mochila",varyHunger=0, varyThirst=0, varyHealth=0,  "mochila.png", action="Colocar"}
items["mochila2"] = {ftype="mochila",varyHunger=0, varyThirst=0, varyHealth=0,  "mochila.png", action="Colocar"}
items["mochila3"] = {ftype="mochila", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0,  "mochila.png", action="Colocar"}
items["adubo"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="adubo.png", action="Usar"}
items["algemas"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="algema.png", action="Usar"}
items["alianca"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="alianca.png", action="Usar"}
items["bandagem"] = {ftype="bandagem", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="bandagem.png", action="Usar"}
items["colete"] = {ftype="armor", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="colete.png", action="Colocar"}
items["brinco"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="brinco.png", action="Usar"}
items["caixa"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="caixa.png", action="Usar"}
items["capuz"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="capuz.png", action="Usar"}
items["carregador"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="carregador.png", action="Usar"}
items["carteira"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="carteira.png", action="Usar"}
items["colar"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="colar.png", action="Usar"}
items["darkmoney"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="darkmoney.png", action="Usar"}
items["cerveja"] = {ftype="alcoolanim", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="cerveja.png", action="Beber"}
items["tequila"] = {ftype="alcoolanim", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="vodka.png", action="Beber"}
items["vodka"] = {ftype="alcoolanim", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="vodka.png", action="Beber"}
items["whisky"] = {ftype="alcoolanim", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="whisky.png", action="Beber"}
items["conhaque"] = {ftype="alcoolanim", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="conhaque.png", action="Beber"}
items["absinto"] = {ftype="alcoolanim", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="absinto.png", action="Beber"}
items["etiqueta"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="etiqueta.png", action="Usar"}
items["dinheirosujo"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="money.png", action="Usar"}
items["ferramenta"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="ferramentas.png", action="Usar"}
items["fertilizante"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="fertilizante.png", action="Usar"}
items["relogioroubado"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="relogio.png", action="Usar"}
items["pulseiraroubada"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="pulseira.png", action="Usar"}
items["anelroubado"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="alianca.png", action="Usar"}
items["colarroubado"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="colar.png", action="Usar"}
items["brincoroubado"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="brinco.png", action="Usar"}
items["carteiraroubada"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="carteira.png", action="Usar"}
items["carregadorroubado"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="carregador.png", action="Usar"}
items["tabletroubado"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="tablet.png", action="Usar"}
items["sapatosroubado"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="sapatos.png", action="Usar"}
items["vibradorroubado"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="vibrador.png", action="Usar"}
items["perfumeroubado"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="perfume.png", action="Usar"}
items["maquiagemroubada"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="maquiagem.png", action="Usar"}
items["garrafavazia"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="garrafavazia.png", action="Usar"}
items["garrafadeleite"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="milk.png", action="Usar"}
items["energetico"] = {ftype="energetico", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="energetico.png", action="Usar"}
items["componenteca"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="pecasdearmas.png", action="Usar"}
items["componentecb"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="pecasdearmas.png", action="Usar"}
items["componentecc"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="pecasdearmas.png", action="Usar"}
items["componentecd"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="pecasdearmas.png", action="Usar"}
items["componentece"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="pecasdearmas.png", action="Usar"}
items["componentema"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="pecasdearmas.png", action="Usar"}
items["componentemb"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="pecasdearmas.png", action="Usar"}
items["componentemc"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="pecasdearmas.png", action="Usar"}
items["componentemd"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="pecasdearmas.png", action="Usar"}
items["isca"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="isca.png", action="Usar"}
items["folhacoca"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="sniffing.png", action="Usar"}
items["podecocaina"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="sniffing.png", action="Usar"}
items["cocaina"] = {ftype="drogaanim", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="sniffing.png", action="Usar"}
items["meta"] = {ftype="drogaanim", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="crystalmeth.png", action="Usar"}
items["bronze"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="bronze.png", action="Usar"}
items["ouro"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="gold.png", action="Usar"}
items["prata"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="silver.png", action="Usar"}
items["rubi"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="ruby.png", action="Usar"}
items["esmeralda"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="esmeralda.png", action="Usar"}
items["safira"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="crystal.png", action="Usar"}
items["diamante"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="diamond.png", action="Usar"}
items["ferro"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="iron.png", action="Usar"}
items["ametista"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="ametista.png", action="Usar"}
items["lapislazuli"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="lapislazuli.png", action="Usar"}
items["lockpick"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="lockpick.png", action="Usar"}
items["dourado"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="fish.png", action="Usar"}
items["corvina"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="fish.png", action="Usar"}
items["salmao"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="fish2.png", action="Usar"}
items["pacu"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="fish2.png", action="Usar"}
items["pintado"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="fish3.png", action="Usar"}
items["pirarucu"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="fish3.png", action="Usar"}
items["tilapia"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="fish3.png", action="Usar"}
items["tucunare"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="fish4.png", action="Usar"}
items["lambari"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="fish4.png", action="Usar"}
items["maquiagem"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="maquiagem.png", action="Usar"}
items["masterpick"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="masterpick.png", action="Usar"}
items["militec"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="militec.png", action="Usar"}
items["orgao"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="orgao.png", action="Usar"}
items["pendrive"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="pendrive.png", action="Usar"}
items["perfume"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="perfume.png", action="Usar"}
items["placa"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="placa.png", action="Usar"}
items["polvora"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="polvora.png", action="Usar"}
items["pulseira"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="pulseira.png", action="Usar"}
items["rebite"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="rebite.png", action="Usar"}
items["relogio"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="relogio.png", action="Usar"}
items["sacodelixo"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="sacodelixo.png", action="Usar"}
items["sapatos"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="sapatos.png", action="Usar"}
items["tablet"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="tablet.png", action="Usar"}
items["tora"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="torademadeira.png", action="Usar"}
items["vibrador"] = {ftype="none", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="vibrador.png", action="Usar"}
items["pills"] = {ftype="vida", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="pills.png", action="Usar"}
items["heroina"] = {ftype="Heroina", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="heroina.png", action="Usar"}

------------------------------ARMAS-----------------------------------

items["wbody|WEAPON_DAGGER"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="adaga.png", action="Equipar"}
items["wbody|WEAPON_BAT"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="tacodebeisebol.png", action="Equipar"}
items["wbody|WEAPON_BOTTLE"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="Garrafra.png", action="Equipar"}
items["wbody|WEAPON_CROWBAR"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="pedecabra.png", action="Equipar"}
items["wbody|WEAPON_FLASHLIGHT"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="lanterna.png", action="Equipar"}
items["wbody|WEAPON_GOLFCLUB"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="tacodegolf.png", action="Equipar"}
items["wbody|WEAPON_HAMMER"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="martelo.png", action="Equipar"}
items["wbody|WEAPON_HATCHET"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="machado.png", action="Equipar"}
items["wbody|WEAPON_KNUCKLE"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="socoingles.png", action="Equipar"}
items["wbody|WEAPON_KNIFE"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="faca.png", action="Equipar"}
items["wbody|WEAPON_MACHETE"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="machete.png", action="Equipar"}
items["wbody|WEAPON_SWITCHBLADE"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="canivete.png", action="Equipar"}
items["wbody|WEAPON_NIGHTSTICK"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="cassetete.png", action="Equipar"}
items["wbody|WEAPON_WRENCH"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="chavedegrifo.png", action="Equipar"}
items["wbody|WEAPON_BATTLEAXE"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="machadodebatalha.png", action="Equipar"}
items["wbody|WEAPON_POOLCUE"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="tacodesinuca.png", action="Equipar"}
items["wbody|WEAPON_STONE_HATCHET"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="machadodepedra.png", action="Equipar"}
items["wbody|WEAPON_PISTOL"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="M1911.png", action="Equipar"}
items["wbody|WEAPON_PISTOL_MK2"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="fnfiveseven.png", action="Equipar"}
items["wbody|WEAPON_COMBATPISTOL"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="combatpistol.png", action="Equipar"}
items["wbody|WEAPON_STUNGUN"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="tazer.png", action="Equipar"}
items["wbody|WEAPON_SNSPISTOL"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="hkp7m10.png", action="Equipar"}
items["wbody|WEAPON_VINTAGEPISTOL"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="m1922.png", action="Equipar"}
items["wbody|WEAPON_REVOLVER"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="magnum44.png", action="Equipar"}
items["wbody|WEAPON_MUSKET"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="winchester22.png", action="Equipar"}
items["wbody|WEAPON_FLARE"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="sinalizador.png", action="Equipar"}
items["wbody|GADGET_PARACHUTE"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="paraquedas.png", action="Equipar"}
items["wbody|WEAPON_FIREEXTINGUISHER"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="extintor.png", action="Equipar"}
items["wbody|WEAPON_MICROSMG"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="uzi.png", action="Equipar"}
items["wbody|WEAPON_SMG"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="MP5.png", action="Equipar"}
items["wbody|WEAPON_ASSAULTSMG"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="M-TAR.png", action="Equipar"}
items["wbody|WEAPON_COMBATPDW"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="SigSauerMPX.png", action="Equipar"}
items["wbody|WEAPON_PUMPSHOTGUN_MK2"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="Remington 870.png", action="Equipar"}
items["wbody|WEAPON_PETROLCAN"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="gasolina.png", action="Equipar"}
items["wbody|WEAPON_CARBINERIFLE"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="M4A1.png", action="Equipar"}
items["wbody|WEAPON_ASSAULTRIFLE"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="ak-103.png", action="Equipar"}
items["wbody|WEAPON_GUSENBERG"] = {ftype="weapon", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="Thompson.png", action="Equipar"}

------------------------------Munição-----------------------------------

items["wammo|WEAPON_PISTOL"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="pistol_ammo.png", action="Equipar"}
items["wammo|WEAPON_PISTOL_MK2"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="balapequena.png", action="Equipar"}
items["wammo|WEAPON_COMBATPISTOL"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="balapequena.png", action="Equipar"}
items["wammo|WEAPON_STUNGUN"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="tazer.png", action="Equipar"}
items["wammo|WEAPON_SNSPISTOL"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="balapequena.png", action="Equipar"}
items["wammo|WEAPON_VINTAGEPISTOL"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="balapequena.png", action="Equipar"}
items["wammo|WEAPON_REVOLVER"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="balamedia.png", action="Equipar"}
items["wammo|WEAPON_MUSKET"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="balamedia.png", action="Equipar"}
items["wammo|WEAPON_FLARE"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="sinalizador.png", action="Equipar"}
items["wammo|GADGET_PARACHUTE"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="paraquedas.png", action="Equipar"}
items["wammo|WEAPON_FIREEXTINGUISHER"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="extintor.png", action="Equipar"}
items["wammo|WEAPON_MICROSMG"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="balapequena.png", action="Equipar"}
items["wammo|WEAPON_SMG"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="balamedia.png", action="Equipar"}
items["wammo|WEAPON_ASSAULTSMG"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="balasgrandes.png", action="Equipar"}
items["wammo|WEAPON_COMBATPDW"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="balasgrandes.png", action="Equipar"}
items["wammo|WEAPON_PUMPSHOTGUN_MK2"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="balamedia.png", action="Equipar"}
items["wammo|WEAPON_CARBINERIFLE"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="balasgrandes.png", action="Equipar"}
items["wammo|WEAPON_ASSAULTRIFLE"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="balasgrandes.png", action="Equipar"}
items["wammo|WEAPON_GUSENBERG"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="balasgrandes.png", action="Equipar"}
items["wammo|WEAPON_PETROLCAN"] = {ftype="ammo", weight=0.1, varyHunger=0, varyThirst=0, varyHealth=0, image="gasolina.png", action="Equipar"}

items["cafe"] = { ftype="bebida", weight=0.1, varyHunger = 0, varyThirst = 40, prop = "prop_ld_flow_bottle", image="cafe.png", action="Usar"}
items["cha"] = { ftype="bebida", weight=0.1, varyHunger = 0, varyThirst = 50, prop = "prop_ld_flow_bottle", image="cha.png", action="Usar"}
items["suco"] = { ftype="bebida", weight=0.1, varyHunger = 0, varyThirst = 90, prop = "prop_ld_flow_bottle", image="suco.png", action="Usar"}
items["cerveja"] = { ftype="bebida", weight=0.1, varyHunger = 0, varyThirst = 50, prop = "prop_ld_flow_bottle", image="cerveja.png", action="Usar"}
items["cocacola"] = { ftype="bebida", weight=0.1, varyHunger = 0, varyThirst = 80, prop = "prop_ld_flow_bottle", image="cocacola.png", action="Usar"}
items["vinho"] = { ftype="bebida", weight=0.1, varyHunger = 0, varyThirst = 50, prop = "prop_ld_flow_bottle", image="vinho.png", action="Usar"}
items["vodka"] = { ftype="bebida", weight=0.1, varyHunger = 0, varyThirst = 60, prop = "prop_ld_flow_bottle", image="vodka.png", action="Usar"}
items["energy"] = { ftype="bebida", weight=0.1, varyHunger = 0, varyThirst = 70, prop = "prop_ld_flow_bottle", image="energy.png", action="Usar"}
items["caldo"] = { ftype="bebida", weight=0.1, varyHunger = 0, varyThirst = 70, prop = "prop_ld_flow_bottle", image="caldo.png", action="Usar"}
items["leite"] = { ftype="bebida", weight=0.1, varyHunger = 0, varyThirst = 100, prop = "prop_ld_flow_bottle", image="leite.png", action="Usar"}
items["agua"] = { ftype="bebida", weight=0.1, varyHunger = 0, varyThirst = 100, prop = "prop_ld_flow_bottle", image="agua.png", action="Usar"}

items["hambuguer"] = { ftype="comida", weight=0.1, varyHunger = 100, varyThirst = 0, prop = "prop_cs_burger_01", image="hambuguer.png", action="Usar"}
items["tortademaca"] = { ftype="comida", weight=0.1, varyHunger =90, varyThirst = 0, prop = "prop_cs_burger_01", image="tortademaca.png", action="Usar"}
items["tortadenozes"] = { ftype="comida", weight=0.1, varyHunger = 80, varyThirst = 0, prop = "prop_cs_burger_01", image="tortadenozes.png", action="Usar"}
items["bolodecenoura"] = { ftype="comida", weight=0.1, varyHunger = 70, varyThirst = 0, prop = "prop_cs_burger_01", image="bolodecenoura.png", action="Usar"}
items["bolodequeijo"] = { ftype="comida", weight=0.1, varyHunger = 60, varyThirst = 0, prop = "prop_cs_burger_01", image="bolodequeijo.png", action="Usar"}
items["biscoito"] = { ftype="comida", weight=0.1, varyHunger = 50, varyThirst = 0, prop = "prop_cs_burger_01", image="biscoito.png", action="Usar"}
items["brigadeiro"] = { ftype="comida", weight=0.1, varyHunger = 30, varyThirst = 0, prop = "prop_cs_burger_01", image="brigadeiro.png", action="Usar"}
items["tortadelimao"] = { ftype="comida", weight=0.1, varyHunger = 80, varyThirst = 0, prop = "prop_cs_burger_01", image="tortadelimao.png", action="Usar"}
items["sorvete"] = { ftype="comida", weight=0.1, varyHunger = 60, varyThirst = 0, prop = "prop_cs_burger_01", image="sorvete.png", action="Usar"}
items["brownie"] = { ftype="comida", weight=0.1, varyHunger = 50, varyThirst = 0, prop = "prop_cs_burger_01", image="brownie.png", action="Usar"}

-- Drogas
items["pilulas"] = {ftype = "drogas", vary_health = 25, image="pilulas.png", action="Usar"}

Config.items = items

return Config
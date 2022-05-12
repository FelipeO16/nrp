local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local emprego = {
    ['CET'] = {
        ['blip'] = {nome = 'CET', id = 60, cor = 3, x = 458.407, y = -990.927, z = 30.689},
        ['cofre'] = {x = 23.886, y = -1105.905, z = 29.797},
        ['servico'] = {
            ['entrar'] = {x = 458.407, y = -990.927, z = 30.689},
            ['uniforme'] = {
                ['mp_m_freemode_01'] = {
                    [3] = {30,0},
                    [4] = {25,2},
                    [6] = {24,0},
                    [8] = {58,0},
                    [11] = {55,0},
                    ['p2'] = {2,0},
                    ['p0'] = {46,0}
                },
                ['mp_f_freemode_01'] = {
                    [3] = {35,0},
                    [4] = {30,0},
                    [6] = {24,0},
                    [8] = {6,0},
                    [11] = {48,0},
                    ['p2'] = {2,0},
                    ['p0'] = {45,0}
                }
            }
        },
        ['garagem'] = {
            ['acessar'] = {x = 452.772, y = -1020.803, z = 28.347},
            ['spawn'] = {
                {x = 427.565, y = -1028.308, z = 28.986, h = 2.475},
                {x = 431.230, y = -1027.749, z = 28.920, h = 2.475},
                {x = 434.916, y = -1027.306, z = 28.853, h = 2.475},
                {x = 439.292, y = -1027.312, z = 28.777, h = 2.475},
                {x = 442.362, y = -1026.780, z = 28.719, h = 2.475},
                {x = 445.764, y = -1026.235, z = 28.654, h = 2.475},
            }
        }
    },
}

RegisterServerEvent('CET:EntrarServico')
AddEventHandler('CET:EntrarServico', function()
    local source = source
    local user_id = vRP.getUserId(source)
    local data = vRP.getUserDataTable(user_id)
    local old_custom = vRPclient.getCustomization(source)
    local vida = vRPclient.getHealth(source)
    local users = vRP.getUsers()
    if data.emServico == "Nenhum" then
        for k,v in pairs(emprego) do
            local idle_copy = {}
            local servico = v.servico
            local uniforme = servico.uniforme

            if old_custom.modelhash == 1885233650 then
                if not data.cloakroom_idle then
                    idle_copy = vRP.save_idle_custom(source, old_custom)
                end
                
                for l,w in pairs(uniforme["mp_m_freemode_01"]) do
                    idle_copy[l] = w
                end

                vRPclient._setCustomization(source, idle_copy)
                SetTimeout(1000, function()
                    vRPclient.setHealth(source, data.health)
                end)
            else
                if not data.cloakroom_idle then
                    idle_copy = vRP.save_idle_custom(source, old_custom)
                end
                
                for l,w in pairs(uniforme["mp_f_freemode_01"]) do
                    idle_copy[l] = w
                end

                vRPclient._setCustomization(source, idle_copy)
                SetTimeout(1000, function()
                    vRPclient.setHealth(source,data.health)
                end)
            end
        end
        
        vRP._updateServico(user_id, "CET")
        vRPclient._notify(source, "Você entrou em serviço!")
    else
        vRP._updateServico(user_id, "Nenhum")
        vRP.removeCloak(source)
        SetTimeout(1000, function()
            vRPclient.setHealth(source,data.health)
        end)
        vRPclient._notify(source, "Você saiu do serviço!")
    end
end)
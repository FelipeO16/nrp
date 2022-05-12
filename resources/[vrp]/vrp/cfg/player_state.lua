
local cfg = {}

-- Define o primeiro spawn do player / respawn_position: Coordenada onde o player irá spawnar depois que morrer
cfg.spawn_enabled = true -- coloque false para desabilitar
cfg.spawn_position = {402.882, -996.537, -99.000}
cfg.respawn_position = {294.325, -1446.990, 29.966}
cfg.spawn_radius = 1

-- Seta a customização no primeiro spawn
-- link dos peds: https://wiki.fivem.net/wiki/Peds
-- mp_m_freemode_01 (male)
-- mp_f_freemode_01 (female)
cfg.default_customization = {
  model = "mp_m_freemode_01" 
}

-- init default ped parts
for i=0,19 do
  cfg.default_customization[i] = {0,0}
end

cfg.clear_phone_directory_on_death = false
cfg.lose_aptitudes_on_death = false

return cfg

-- client-side vRP configuration

local cfg = {}

cfg.iplload = true

cfg.voice_proximity = 2.0 -- default voice proximity (outside)
cfg.voice_proximity_vehicle = 2.0
cfg.voice_proximity_inside = 2.0

cfg.audio_listener_rate = 15 -- audio listener position update rate

cfg.audio_listener_on_player = false -- set the listener position on the player instead of the camera

cfg.gui = {
  anchor_minimap_width = 260,
  anchor_minimap_left = 60,
  anchor_minimap_bottom = 213
}

cfg.respawn_time = 600

-- gui controls (see https://wiki.fivem.net/wiki/Controls)
-- recommended to keep the default values and ask players to change their keys
cfg.controls = {
  phone = {
    -- PHONE CONTROLS
    up = {3,172},
    down = {3,173},
    left = {3,174},
    right = {3,175},
    select = {3,176},
    cancel = {3,177},
    open = {3,311} -- INPUT_PHONE, open general menu
  },
  request = {
    yes = {1,288}, 
    no = {1,289} 
  }
}

-- disable menu if handcuffed
cfg.handcuff_disable_menu = true

-- when health is under the threshold, player is in coma
-- set to 0 to disable coma
cfg.coma_threshold = 100

-- maximum duration of the coma in minutes
cfg.coma_duration = 10

-- if true, a player in coma will not be able to open the main menu
cfg.coma_disable_menu = false

-- see https://wiki.fivem.net/wiki/Screen_Effects
cfg.coma_effect = "DeathFailMPIn"

-- set to true to disable the default voice chat and use vRP voip instead (world channel) 
cfg.vrp_voip = false

-- radius to establish VoIP connections
cfg.voip_proximity = 100

-- connect/disconnect interval in milliseconds
cfg.voip_interval = 5000

-- desligar radar / true: desativa o radar / false: ativa o radar
cfg.radar = true

-- vRP.configureVoice settings
-- world
cfg.world_voice_config = {
  effects = {
    spatialization = { max_dist = cfg.voip_proximity }
  }
}

-- phone
cfg.phone_voice_config = {
}

-- radio
cfg.radio_voice_config = {
  effects = {
    biquad = { type = "bandpass", frequency = 1700, Q = 2, gain = 1.2 }
  }
}

return cfg


local cfg = {}

-- exp notes:
-- levels are defined by the amount of xp
-- with a step of 5: 5|15|30|50|75 (by default)
-- total exp for a specific level, exp = step*lvl*(lvl+1)/2
-- level for a specific exp amount, lvl = (sqrt(1+8*exp/step)-1)/2

--- define groups of aptitudes
--- _title: title of the group
--- map of aptitude => {title,init_exp,max_exp}
--- max_exp: -1 for infinite exp
cfg.gaptitudes = {
  ["exp"] = {
    _title = "Level",
    ["level"] = {"Level do personagem", 5, 1050}
  }
}

return cfg

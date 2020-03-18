local config = {}

config["base.keybinds"] = {}
config["base.play_music"] = true
config["base.anim_wait"] = 80 * 0.5
config["base.positional_audio"] = false
config["base.default_font"] = "kochi-gothic-subst.ttf"
config["base.quickstart_on_startup"] = false

local fs = require("util.fs")
if fs.is_file(fs.join("data/font", "MS-Gothic.ttf")) then
   config["base.default_font"] = "MS-Gothic.ttf"
end

-- private variables
config["base._save_id"] = nil

-- Don't overwrite existing values in the current config.
config.on_hotload = function(old, new)
   for k, v in pairs(new) do
      if old[k] == nil then
         old[k] = v
      end
   end
end

return config

--- @module Gui

local draw = require("internal.draw")
local config = require("internal.config")
local sound_manager = require("internal.global.sound_manager")

local Gui = {}

--- Plays a sound. You can optionally provide a position, so that if
--- positional audio is enabled in the settings then it will be panned
--- according to the relative position of the player.
---
--- @tparam id:base.sound sound_id
--- @tparam[opt] int x
--- @tparam[opt] int y
--- @tparam[opt] int channel
function Gui.play_sound(sound_id, x, y, channel)
   local coords = draw.get_coords()

   if config["base.positional_audio"] and x ~= nil and y ~= nil then
      local sx, sy = coords:tile_to_screen(x, y)
      sound_manager.get():play(sound_id, sx, sy, channel)
   else
      sound_manager.get():play(sound_id, nil, nil, channel)
   end
end

--- Plays a sound looped in the background.
---
--- @tparam id:base.sound sound_id
--- @see Gui.stop_background_sound
function Gui.play_background_sound(sound_id)
   sound_manager.get():play_looping(sound_id)
end

--- Stops playing a sound that was started with
--- Gui.play_background_sound.
---
--- @tparam id:base.sound sound_id
--- @see Gui.play_background_sound
function Gui.stop_background_sound(sound_id)
   sound_manager.get():stop_looping(sound_id)
end

--- Plays music.
---
--- @tparam id:base.music music_id
function Gui.play_music(music_id)
   if not config["base.play_music"] then
      sound_manager.get():stop_music()
      return
   end

   sound_manager.get():play_music(music_id)
end

--- Stops the currently playing music.
function Gui.stop_music()
   sound_manager.get():stop_music()
end

return Gui

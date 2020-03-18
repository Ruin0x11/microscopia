local sound_manager = require("internal.sound_manager")

local manager

return {
   get = function()
      if manager == nil then
         local data = require("internal.data")
         local lists = {
            sound = data["base.sound"],
            music = data["base.music"]
         }
         manager = sound_manager:new(lists)
      end
      return manager
   end
}

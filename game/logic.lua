local TestUI = require("api.gui.menu.TestUI")

local logic = {}

function logic.main_loop()
   local going = true

   while going do
      local _, canceled = TestUI:new():query()
      if canceled == "canceled" then
         going = false
      end
   end

   return "quit"
end

return logic

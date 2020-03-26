local logic = {}

function logic.main_loop()
   local field = require("internal.global.field")

   local going = true

   while going do
      local _, canceled = field:query()
      if canceled == "canceled" then
         going = false
      end
   end

   return "quit"
end

return logic

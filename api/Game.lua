local Game = {}

function Game.state()
   local field = require("internal.global.field")

   return field.state
end

function Game.is_simulation_paused()
   return Game.state() == "dialog"
end

return Game

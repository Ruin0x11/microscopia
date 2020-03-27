local Input = require("api.Input")
local Repl = require("api.Repl")
local draw = require("internal.draw")
local logic = require("game.logic")

local game = {}

local function startup()
   rawset(_G, "pause", function(...) Repl.pause(...) end)
   rawset(_G, "data", require("internal.data"))
   rawset(_G, "config", require("internal.config"))
   rawset(_G, "save", require("internal.global.save"))

   require("game.data")

   Input.reload_keybinds()
end

function game.loop()
   startup()

   local cb = logic.main_loop

   local going = true

   while going do
      local success, action = xpcall(cb, debug.traceback)
      if not success then
         local err = action
         coroutine.yield(err)
      else
         if action == "main_loop" then
            cb = logic.main_loop
         elseif action == "quit" then
            going = false
         end
      end
   end
end

function game.draw()
   local going = true

   while going do
      local ok, ret = xpcall(draw.draw_layers, debug.traceback)

      if not ok then
         going = coroutine.yield(ret)
      else
         going = coroutine.yield()
      end
   end
end

return game

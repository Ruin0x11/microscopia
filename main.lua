require("boot")

local Draw = require("api.Draw")

local env = require("internal.env")
local game = require("game")
local debug_server = require("internal.debug_server")
local input = require("internal.input")
local draw = require("internal.draw")
local draw_stats = require("internal.global.draw_stats")
--local tick = require("thirdparty.tick")

local loop_coro = nil
local draw_coro = nil
local server = nil

function love.load(arg)
   love.filesystem.setIdentity(env.PROGRAM_NAME)
   draw.init()
   Draw.set_font(12)
   --tick.framerate = 30

   server = debug_server:new()
   server:start()

   loop_coro = coroutine.create(game.loop)
   draw_coro = coroutine.create(game.draw)
end

local halt = false
local pop_draw_layer = false
local halt_error = ""

local function stop_halt()
   love.keypressed = input.keypressed

   halt = false
end

local function start_halt()
   input.halt_input()
   love.keypressed = function(key, scancode, isrepeat)
      local keys = table.set {"return", "escape", "space"}
      if keys[key] then
         stop_halt()
      elseif key == "backspace" then
         pop_draw_layer = true
         stop_halt()
      elseif key == "f9" then
         love.event.quit(true)
      end
   end

   halt = true
end

function love.update(dt)
   input.poll_joystick_axes()

   draw_stats.frame_start = true

   if env.server_needs_restart then
      if server then
         server:stop()
      end
      server = debug_server:new()
      server:start()
      env.server_needs_restart = false
   end

   if server then
      local ok, cmd_name = server:step(dt)
      if not ok then
         -- Coroutine is dead. Restart server.
         -- server = debug_server:new()
         -- server:start()
      else
         if halt and (cmd_name == "run" or cmd_name == "hotload") then
            stop_halt()
         end
      end
   end

   if draw.needs_wait() then
      return
   end

   if halt then
      return
   end

   local ok, err = coroutine.resume(loop_coro, dt, pop_draw_layer)
   pop_draw_layer = false
   if not ok or err ~= nil then
      print("Error in loop:\n\t" .. debug.traceback(loop_coro, err))
      print()
      if not ok then
         -- Coroutine is dead. No choice but to throw.
         error(err)
      else
         -- We can continue executing since game.loop is still alive.
         start_halt()
         halt_error = err
      end
   end

   if coroutine.status(loop_coro) == "dead" then
      print("Finished.")
      love.event.quit()
   end
end

function love.draw()
   if halt then
      draw.draw_error(halt_error)
      return
   end

   draw.draw_start()

   local going = true
   local ok, err = coroutine.resume(draw_coro, going)
   if not ok or err then
      print("Error in draw:\n\t" .. debug.traceback(draw_coro, err))
      print()
      if not ok then
         -- Coroutine is dead. No choice but to throw.
         error(err)
      else
         -- We can continue executing since game.loop is still alive.
         start_halt()
         halt_error = err
      end
   end

   love.graphics.getStats(draw_stats)

   draw.draw_end()

   env.set_hotloaded_this_frame(false)
end

--
--
-- LÖVE callbacks
--
--

love.resize = draw.resize

love.mousemoved = input.mousemoved
love.mousepressed = input.mousepressed
love.mousereleased = input.mousereleased

love.keypressed = input.keypressed
love.keyreleased = input.keyreleased

love.joystickpressed = input.joystickpressed
love.joystickreleased = input.joystickreleased

love.textinput = input.textinput

local IDrawable = require("api.gui.IDrawable")
local Log = require("api.Log")

local DrawCallbacks = class.class("DrawCallbacks", IDrawable)

function DrawCallbacks:init()
   self.key = 1
   self.callbacks = {}
end

function DrawCallbacks:add(key, update, draw, args)
   if key == nil then
      key = self.key
      self.key = self.key + 1
   end

   local state = args or {}

   self.callbacks[key] = {
      state = state,
      update = coroutine.create(function(dt, state)
            while true do
               local finished = update(dt, state)
               if finished then break end
               dt = coroutine.yield()
            end
      end),
      draw = coroutine.create(function(state)
            while true do
               draw(state)
               coroutine.yield()
            end
      end)
   }
end

function DrawCallbacks:remove(tag)
   if self.callbacks[tag] == nil then
      Log.debug("Tried to stop draw callback '%s' but it didn't exist.", tag)
      return
   end

   self.callbacks[tag] = nil
end

local function resume_coroutine(thread, draw_x, draw_y, frame_delta)
   local ok, err = coroutine.resume(thread, draw_x, draw_y, frame_delta)
   local is_dead = coroutine.status(thread) == "dead"
   if is_dead or not ok then
      if err then
         Log.error("Error in draw callback: %s", debug.traceback(thread, err))
      end
      return false
   end
   return true
end

function DrawCallbacks:draw()
   local dead = {}

   -- TODO: order by priority
   for key, co in pairs(self.callbacks) do
      local going = resume_coroutine(co.draw, co.state)
      if not going then
         -- Coroutine error; stop drawing now
         dead[#dead+1] = key
      end
   end

   table.remove_keys(self.callbacks, dead)
end

function DrawCallbacks:update(dt)
   local dead = {}

   for key, co in pairs(self.callbacks) do
      local going = resume_coroutine(co.update, dt, co.state)
      if not going then
         dead[#dead+1] = key
      end
   end

   table.remove_keys(self.callbacks, dead)
end

return DrawCallbacks

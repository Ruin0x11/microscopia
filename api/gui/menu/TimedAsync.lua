local Log = require("api.Log")
local queue = require("util.queue")
local TimedAsync = class.class("TimedAsync")

function TimedAsync:init(dt, resolve)
   self.resolve = nil
   self.rest = queue:new()
   self:and_then(dt, resolve)
   self:_next()
end

function TimedAsync:and_then(dt, resolve)
   assert(dt and resolve)
   if dt == "forever" then
      dt = math.huge
   end
   self.rest:push({ dt=dt, resolve=resolve })
   return self
end

function TimedAsync:_next()
   if self.rest:len() == 0 then
      self.resolve = nil
      return
   end

   local entry = self.rest:pop()
   local dt = entry.dt
   local resolve = entry.resolve
   self.resolve = coroutine.create(function(_dt, a, b, c, d, e, f, g)
         while true do
            dt = dt - _dt
            if dt <= 0 then
               break
            end
            resolve(_dt, dt, a, b, c, d, e, f, g)
            _dt, a, b, c, d, e, f, g = coroutine.yield()
         end
   end)
end

function TimedAsync:invalidate()
   self.resolve = nil
   self.rest:clear()
end

function TimedAsync:update(dt, ...)
   local is_dead = self.resolve == nil or coroutine.status(self.resolve) == "dead"
   if is_dead then
      self:_next()
   end

   if self.resolve == nil then
      return
   end

   local ok, err = coroutine.resume(self.resolve, dt, ...)
   if not ok then
      Log.error("Error in async callback:\n\t%s", debug.traceback(self.resolve, err))
      self:invalidate()
   end

   return self.rest:len() > 0
end

return TimedAsync

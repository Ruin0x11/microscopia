local queue = class.class("queue")

function queue:init()
   self._len = 0
   self._ordered = {}
   self._buffer = {}
end

function queue:push(obj)
   self._len = self._len + 1
   self._buffer[#self._buffer+1] = obj
end

function queue:pop()
   while #self._buffer > 0 do
      self._ordered[#self._ordered+1] = self._buffer[#self._buffer]
      self._buffer[#self._buffer] = nil
   end

   self._len = self._len - 1

   local obj = self._ordered[#self._ordered]
   self._ordered[#self._ordered] = nil
   return obj
end

function queue:len()
   return self._len
end

function queue:clear()
   self._len = 0
   self._ordered = {}
   self._buffer = {}
end

return queue

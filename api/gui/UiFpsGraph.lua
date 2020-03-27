local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local CircularBuffer = require("api.CircularBuffer")

local UiFpsGraph = class.class("UiFpsGraph", IUiElement)

function UiFpsGraph:init(color)
   self.max = 0
   self.min = 0
   self.use_min = true
   self.step = 1
   self.points = CircularBuffer:new(2)
   self.color = color or {0, 0, 255, 128}
end

function UiFpsGraph:relayout(x, y, width, height)
   self.x = x
   self.y = y
   local size = math.max(math.floor(self.width / self.step), 2)
   if size ~= self.points.max_length then
      self.points = CircularBuffer:new(size)
   end
   self.width = width
   self.height = height
end

function UiFpsGraph:update()
end

function UiFpsGraph:clear()
   self.max = 0
   self.points = CircularBuffer:new(2)
end

function UiFpsGraph:add_point(n)
   self.points:push(n)
   -- self.max = math.max(self.max, n)
   -- self.min = math.min(self.min, n)

   self.max = self.points:get(1)
   self.min = self.points:get(1)
   for _, point in self.points:iter() do
      self.max = math.max(self.max, point)
      self.min = math.min(self.min, point)
   end
end

function UiFpsGraph:draw()
   Draw.set_color(255, 255, 255)
   Draw.line_rect(self.x, self.y, self.width, self.height)

   Draw.set_color(self.color)
   for i, point in self.points:iter_reverse() do
      local x = self.x + self.width - (i * self.step) + 1
      local ratio
      if self.use_min then
         ratio = 1 - ((point - self.min) / (self.max - self.min))
      else
         ratio = 1 - (point / self.max)
      end
      Draw.line(x,
                self.y + self.height - 2,
                x,
                self.y + self.height * ratio)
   end
end

return UiFpsGraph

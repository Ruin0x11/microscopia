local Draw = require("api.Draw")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")

local MenuLayer = class.class("MenuLayer", IUiLayer)

MenuLayer:delegate("input", IInput)

function MenuLayer:init()
   self.input = InputHandler:new()
   self.bg = nil
   self.buttons = {}

   local w = 200
   local h = 50
   for i = 1, 10 do
      local node = {
         display_name = "Test " .. i,
         x = 20,
         y = 20 + (i-1) * (h + 4),
         hovered = false,
         pressed = false,
      }
      node.mouse_area = self.input:add_mouse_area(node.x, node.y, w, h)
      node.mouse_area.on_hovered = function(_, hovered) node.hovered = hovered end
      node.mouse_area.on_pressed = function(_, pressed) node.pressed = pressed end

      self.buttons[#self.buttons+1] = node
   end
end

function MenuLayer:make_keymap()
   return {
      shift = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }
end

function MenuLayer:on_query()
end

function MenuLayer:relayout(x, y)
end

function MenuLayer:update(dt)
   if self.canceled then
      return nil, "canceled"
   end
end

local function button(x, y, w, h, text, color)
   Draw.set_color(color)
   Draw.filled_rect(x+1, y+1, w-1, h-1)
   Draw.set_font(14)
   Draw.set_color(255, 255, 255)
   Draw.line(x, y, x+w-1, y)
   Draw.line(x, y+h, x+w-1, y+h)
   Draw.line(x, y, x, y+h-1)
   Draw.line(x+w, y, x+w, y+h-1)
   Draw.text(text, x + (w / 2) - Draw.text_width(text) / 2, y + (h / 2) - Draw.text_height() / 2)
end

function MenuLayer:draw()
   local w = 200
   local h = 50
   for i, b in ipairs(self.buttons) do
      local dx = 0
      local dy = 0
      local color = {0, 0, 0}
      if b.hovered then
         color = {100, 100, 100}
      end
      if b.pressed then
         dx = 1
         dy = 1
      end
      button(b.x + dx, b.y + dy, w, h, b.display_name, color)
   end
end

return MenuLayer

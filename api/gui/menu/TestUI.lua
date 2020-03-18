local Draw = require("api.Draw")
local Gui = require("api.Gui")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")

local TestUI = class.class("TestUI", IUiLayer)

TestUI:delegate("input", IInput)

function TestUI:init()
   self.input = InputHandler:new()
   self.input:halt_input()
end

function TestUI:make_keymap()
   return {
      shift = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }
end

function TestUI:on_query()
   Gui.play_music("base.anotherworld")
end

function TestUI:relayout(x, y)
   self.image = love.graphics.newImage("data/graphic/bg1.jpg")
end

function TestUI:update()
   if self.canceled then
      return nil, "canceled"
   end
end

local function button(x, y, w, h, text)
   Draw.set_color(0, 0, 0)
   Draw.filled_rect(x+1, y+1, w-1, h-1)
   Draw.set_font(14)
   Draw.set_color(255, 255, 255)
   Draw.line(x, y, x+w-1, y)
   Draw.line(x, y+h, x+w-1, y+h)
   Draw.line(x, y, x, y+h-1)
   Draw.line(x+w, y, x+w, y+h-1)
   Draw.text(text, x + (w / 2) - Draw.text_width(text) / 2, y + (h / 2) - Draw.text_height() / 2)
end

function TestUI:draw()
   Draw.image_filled(self.image, 0, 0, Draw.get_width(), Draw.get_height())
   local w = 200
   local h = 50
   for i=0,10-1 do
      button(20, 20 + i * (h + 4), w, h, "Test " .. i)
   end
end

return TestUI

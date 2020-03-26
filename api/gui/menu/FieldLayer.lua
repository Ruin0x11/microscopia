local Draw = require("api.Draw")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")

local FieldLayer = class.class("FieldLayer", IUiLayer)

FieldLayer:delegate("input", IInput)

function FieldLayer:init()
   self.input = InputHandler:new()
   self.bg = nil
end

function FieldLayer:make_keymap()
   return {
      shift = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }
end

function FieldLayer:on_query()
end

function FieldLayer:relayout(x, y)
   self.bg = love.graphics.newImage("data/graphic/bg/business00.jpg")
end

function FieldLayer:update(dt)
   if self.canceled then
      return nil, "canceled"
   end
end

function FieldLayer:draw()
   Draw.image_filled(self.bg, 0, 0, Draw.get_width(), Draw.get_height())
end

return FieldLayer

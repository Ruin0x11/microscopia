local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Node = require("api.Node")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")

local MenuLayer = class.class("MenuLayer", IUiLayer)

MenuLayer:delegate("input", IInput)

local function make_button(w, h, color)
   local canvas = love.graphics.newCanvas(w, h)
   love.graphics.setCanvas(canvas)
   Draw.set_color(color)
   Draw.filled_rect(1, 2, w-2, h-3)
   Draw.set_font(14)
   Draw.set_color(255, 255, 255)
   Draw.line(1, 1, w-1, 1)
   Draw.line(1, h-1, w-1, h-2)
   Draw.line(1, 1, 0, h-2)
   Draw.line(w, 1, w, h-2)
   love.graphics.setCanvas()
   return love.graphics.newImage(canvas:newImageData())
end

function MenuLayer:init()
   self.active = false
   self.input = InputHandler:new()
   self.bg = nil
   self.buttons = {}
   self.canvas_normal = make_button(200, 50, {0, 0, 0})
   self.canvas_hovered = make_button(200, 50, {100, 100, 100})
end

function MenuLayer:do_focus(focused)
   self.active = focused
end

function MenuLayer:add_button(name, cb, image)
   local w = 200
   local h = 50
   local i = #self.buttons

   Draw.set_font(12)
   local button = {
      display_name = Draw.make_text(name),
      text_width = Draw.text_width(name),
      x = 20,
      y = 20 + i * (h + 4),
      hovered = false,
      pressed = false,
      image = image,
   }
   button.mouse_area = self.input:add_mouse_area(button.x, button.y, w, h)
   button.mouse_area.on_hovered = function(_, key, hovered)
      button.hovered = hovered
      if not hovered then
         button.pressed = false
      end
   end
   button.mouse_area.on_pressed = function(_, key, pressed)
      button.pressed = pressed
      if not pressed then
         if key == 1 then
            cb()
         end
      end
   end

   self.buttons[#self.buttons+1] = button
end

function MenuLayer:clear_buttons()
   for _, button in ipairs(self.buttons) do
      self.input:remove_mouse_area(button.mouse_area)
   end
   self.buttons = {}
end

function MenuLayer:refresh_nodes(game)
   self:clear_buttons()

   if game.node.parent then
      self:add_button("Go Back", function()
                         Gui.play_sound("base.back")
                         game:goto_node(game.node.parent)
      end)
   end

   for _, child in Node.children(game.node) do
      if child.visible_in == nil or child.visible_in == "menu" then
         local image
         if child.image then
            image = love.graphics.newImage(child.image)
         end
         self:add_button(child.name, function() Node.activate(child) end, image)
      end
   end
end

function MenuLayer:add_node(node)
end

function MenuLayer:remove_node(node)
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

function MenuLayer:draw()
   if not self.active then
      return
   end

   local w = 200
   local h = 50

   Draw.set_color(255, 255, 255)
   for _, b in ipairs(self.buttons) do
      local dx = 0
      local dy = 0
      local text_dx = 0
      local canvas = self.canvas_normal
      if b.hovered then
         canvas = self.canvas_hovered
      end
      if b.pressed then
         dx = 1
         dy = 1
      end
      Draw.set_font(14)
      local line_width = b.text_width
      if b.image then
         line_width = line_width + b.image:getWidth()
         text_dx = b.image:getWidth()
      end

      Draw.image(canvas, b.x + dx, b.y + dy)
      if b.image then
         Draw.image(b.image, b.x + dx + 16, b.y + dy + (h / 2) - b.image:getHeight() / 2)
      end
      Draw.text(b.display_name, b.x + dx + text_dx + (w / 2) - line_width / 2, b.y + dy + (h / 2) - Draw.text_height() / 2)
   end
end

return MenuLayer

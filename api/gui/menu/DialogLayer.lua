local Draw = require("api.Draw")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local queue = require("util.queue")

local DialogLayer = class.class("DialogLayer", IUiLayer)

DialogLayer:delegate("input", IInput)

function DialogLayer:init()
   self.active = false

   self.dialogs = queue:new()
   self.cur_dialog = nil
   self.cur_index = 1
   self.actor = nil
   self.text = {}
   self.padding = 20

   self.input = InputHandler:new()
   local keymap = self:make_keymap()
   self.input:bind_keys(keymap)
   self.input:bind_mouse(keymap)
end

function DialogLayer:push_dialog(dialog)
   self.dialogs:push(dialog)
end

function DialogLayer:len()
   return self.dialogs:len()
end

function DialogLayer:make_keymap()
   return {
      enter = function() self:step_dialog() end,
      raw_mouse_1_pressed = function()
         self:step_dialog()
      end
   }
end

function DialogLayer:clear()
   self.dialogs = queue:new()
   self.cur_dialog = nil
   self.cur_index = 1
   self.actor = nil
   self.text = {}
end

function DialogLayer:step_dialog()
   repeat
      if self.cur_dialog == nil or self.cur_dialog[self.cur_index] == nil then
         if self.dialogs:len() == 0 then
            return
         end
         self.cur_dialog = self.dialogs:pop()
         self.cur_index = 1
      else
         self.cur_index = self.cur_index + 1
      end

      while self.cur_dialog[self.cur_index] do
         local t = self.cur_dialog[self.cur_index]
         if type(t) == "table" then
            if t.actor then
               if t.actor == "__none__" then
                  self.actor = nil
               else
                  self.actor = t.actor
               end
            end
         else
            break
         end
         self.cur_index = self.cur_index + 1
      end
   until self.cur_dialog ~= nil and self.cur_dialog[self.cur_index]

   local _, wrapped = Draw.wrap_text(tostring(self.cur_dialog[self.cur_index]), self.width - self.padding * 2)
   Draw.set_font(14)
   self.text = {}
   for _, line in ipairs(wrapped) do
      self.text[#self.text+1] = Draw.make_text(line)
   end
end

function DialogLayer:do_focus(focused)
   if focused then
      self.active = true
      self:step_dialog()
   else
      self.active = false
      self:clear()
   end
end

function DialogLayer:on_query()
end

function DialogLayer:relayout(x, y)
   self.width = Draw.get_width()
   self.height = 200
   self.x = 0
   self.y = Draw.get_height() - self.height
end

function DialogLayer:update(dt)
   if not self.active or self.cur_dialog == nil then
      self:clear()
      return true
   end

   local t = self.cur_dialog[self.cur_index]
   if not t then
      return true
   end
end

function DialogLayer:draw()
   if not self.active then
      return
   end

   Draw.set_font(14)
   Draw.set_color(80, 80, 80, 220)
   Draw.filled_rect(self.x, self.y, self.width, self.height)
   if self.actor then
      Draw.set_color(40, 40, 40, 220)
      Draw.filled_rect(self.x, self.y - 24, Draw.text_width(self.actor) + self.padding * 2, 24)
   end

   Draw.set_color(255, 255, 255)
   local y = self.y + self.padding
   for _, line in ipairs(self.text) do
      Draw.text(line, self.x + self.padding, y)
      y = y + Draw.text_height()
   end
   if self.actor then
      Draw.text(self.actor, self.x + self.padding, self.y - 20)
   end
end

return DialogLayer

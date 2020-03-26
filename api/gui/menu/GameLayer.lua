local Draw = require("api.Draw")
local DrawCallbacks = require("api.gui.menu.DrawCallbacks")
local Gui = require("api.Gui")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")

local GameLayer = class.class("GameLayer", IUiLayer)

GameLayer:delegate("input", IInput)

function GameLayer:init()
   self.input = InputHandler:new()
   self.input:halt_input()

   -- "list", "field", "dialog"
   self.mode = "list"

   self.draw_callbacks = DrawCallbacks:new()

   self.popups = {}
end

function GameLayer:make_keymap()
   return {
      shift = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }
end

function GameLayer:init_draw_callbacks()
   local function popups_update(dt)
      local dead = {}
      for i, entry in ipairs(self.popups) do
         for _, cb in ipairs(entry.cbs) do
            cb:update(dt, entry)
         end
         entry.dt = entry.dt - dt
         if entry.dt <= 0 then
            dead[#dead+1] = i
         end
      end
      table.remove_indices(self.popups, dead)
   end
   local function popups_draw()
      for _, entry in ipairs(self.popups) do
         Draw.set_color(entry.shadow)
         Draw.text(entry.text, entry.x + entry.dx+1, entry.y + entry.dy+1)
         Draw.set_color(entry.color)
         Draw.text(entry.text, entry.x + entry.dx, entry.y + entry.dy)
      end
   end
   self.draw_callbacks:add("popups", popups_update, popups_draw)
end

function GameLayer:on_query()
   self:init_draw_callbacks()
   -- Gui.play_music("base.anotherworld")
end

function GameLayer:relayout(x, y)
   self.image = love.graphics.newImage("data/graphic/bg/business00.jpg")
end

function GameLayer:update(dt)
   self.draw_callbacks:update(dt)

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

function GameLayer:draw()
   Draw.image_filled(self.image, 0, 0, Draw.get_width(), Draw.get_height())
   local w = 200
   local h = 50
   for i=0,10-1 do
      button(20, 20 + i * (h + 4), w, h, "Test " .. i)
   end

   self.draw_callbacks:draw()
end

function GameLayer.on_hotload(old, new)
   local field = require("internal.global.field")
   field:init_draw_callbacks()
   class.hotload(old, new)
end

return GameLayer

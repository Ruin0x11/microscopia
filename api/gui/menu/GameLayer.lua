local Draw = require("api.Draw")
local DrawCallbacks = require("api.gui.menu.DrawCallbacks")
local FieldLayer = require("api.gui.menu.FieldLayer")
local MenuLayer = require("api.gui.menu.MenuLayer")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")

local GameLayer = class.class("GameLayer", IUiLayer)

GameLayer:delegate("input", IInput)

function GameLayer:init()
   -- "menu", "field", "dialog"
   self.mode = "menu"

   self.field = FieldLayer:new()
   self.menu = MenuLayer:new()

   self.draw_callbacks = DrawCallbacks:new()

   self.popups = {}

   self.input = InputHandler:new()
   self.input:forward_to(self.menu)
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
   self.field:relayout(x, y)
   self.menu:relayout(x, y)
end

function GameLayer:update(dt)
   self.field:update(dt)
   self.menu:update(dt)

   self.draw_callbacks:update(dt)

   if self.canceled then
      return nil, "canceled"
   end
end

function GameLayer:draw()
   self.field:draw()
   self.menu:draw()

   self.draw_callbacks:draw()
end

function GameLayer.on_hotload(old, new)
   local field = require("internal.global.field")
   field:init_draw_callbacks()
   class.hotload(old, new)
end

return GameLayer

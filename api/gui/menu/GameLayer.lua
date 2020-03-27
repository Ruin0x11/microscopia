local Draw = require("api.Draw")
local DrawCallbacks = require("api.gui.menu.DrawCallbacks")
local FieldLayer = require("api.gui.menu.FieldLayer")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local Log = require("api.Log")
local UiFpsCounter = require("api.gui.UiFpsCounter")
local DialogLayer = require("api.gui.menu.DialogLayer")
local MenuLayer = require("api.gui.menu.MenuLayer")
local Node = require("api.Node")
local logic = require("game.logic")

local GameLayer = class.class("GameLayer", IUiLayer)

GameLayer:delegate("input", IInput)

function GameLayer:init()
   -- "menu", "field", "battle", "dialog"
   self.state = "menu"
   self.prev_state = nil

   self.field = FieldLayer:new()
   self.menu = MenuLayer:new()
   self.dialog = DialogLayer:new()

   self.draw_callbacks = DrawCallbacks:new()

   self.popups = {}

   self.input = InputHandler:new()

   self.node = nil
   self.next_node = nil

   self.fps = UiFpsCounter:new()
end

function GameLayer:make_keymap()
   return {
      shift = function() self.canceled = true end,
      escape = function() self.canceled = true end,
      restart = function() love.event.quit("restart") end,
      reinit = function() logic.start_game() end,
      switch_view = function() self:switch_view() end
   }
end

function GameLayer:switch_view()
   if self.state == "menu" then
      self:focus_field()
   elseif self.state == "field" then
      self:focus_menu()
   elseif self.state == "battle" then
   end
end

function GameLayer:goto_node(node)
   -- TODO: deinit things like physics when not in same node,
   -- reinitialize when returning
   if self.next_node ~= nil then
      Log.warn("Overwriting next node.")
   end
   self.next_node = node
   self:focus_menu()
end

function GameLayer:refresh_nodes()
   self.field:refresh_nodes(self)
   self.menu:refresh_nodes(self)
end

function GameLayer:add_node(node)
   self.field:add_node(node)
   self.menu:add_node(node)
end

function GameLayer:remove_node(node)
   self.field:remove_node(node)
   self.menu:remove_node(node)
end

function GameLayer:push_dialog(dialog)
   self.dialog:push_dialog(dialog)
end

function GameLayer:start_battle()
   self.state = "battle"
   self.menu:do_focus(false)
   self.field:do_focus(true)
   self.dialog:do_focus(false)
   self.input:forward_to(self.field)
end

function GameLayer:focus_menu()
   self.state = "menu"
   self.menu:do_focus(true)
   self.field:do_focus(false)
   self.dialog:do_focus(false)
   self.input:forward_to(self.menu)
end

function GameLayer:focus_field()
   self.state = "field"
   self.menu:do_focus(false)
   self.field:do_focus(true)
   self.dialog:do_focus(false)
   self.input:forward_to(self.field)
end

function GameLayer:focus_dialog()
   self.prev_state = self.state
   self.state = "dialog"
   self.menu:do_focus(false)
   self.field:do_focus(false)
   self.dialog:do_focus(true)
   self.input:forward_to(self.dialog)
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
         Draw.set_font(14)
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
   self:focus_menu()
   -- Gui.play_music("base.anotherworld")
end

function GameLayer:relayout(x, y)
   self.field:relayout(x, y)
   self.menu:relayout(x, y)
   self.dialog:relayout(x, y)

   self.fps:relayout(x, y)
end

function GameLayer:update_state(dt)
   if self.dialog:len() > 0 and self.state ~= "dialog" then
      self:focus_dialog()
   end

   local field_done = self.field:update(dt)
   self.menu:update(dt)
   local dialog_done = self.dialog:update(dt)

   if self.state == "dialog" then
      if dialog_done then
         if self.prev_state == "field" or self.prev_state == "battle" then
            self:focus_field()
         else
            self:focus_menu()
         end
         self.prev_state = nil
      end
   elseif self.state == "battle" then
      if field_done then
         self.focus_menu()
      end
   end
end

function GameLayer:update(dt)
   if self.next_node then
      if self.node then
         Node.proc(self.node, "on_exit")
      end
      self.node = self.next_node
      self.next_node = nil
      self:refresh_nodes()
      Node.proc(self.node, "on_enter")
   end

   self:update_state(dt)

   self.draw_callbacks:update(dt)
   self.fps:update(dt)

   if self.canceled then
      return nil, "canceled"
   end
end

function GameLayer:draw()
   self.field:draw()
   self.menu:draw()
   self.dialog:draw()

   self.draw_callbacks:draw()
   self.fps:draw()

   Draw.set_font(12)
   Draw.set_color(255, 255, 255)
   Draw.text_shadowed(self.state, 10, Draw.get_height() - Draw.text_height() - 10)
end

function GameLayer.on_hotload(old, new)
   local field = require("internal.global.field")
   field:init_draw_callbacks()
   class.hotload(old, new)
end

return GameLayer

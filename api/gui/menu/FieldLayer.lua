local Draw = require("api.Draw")
local Game = require("api.Game")
local Node = require("api.Node")
local Input = require("api.Input")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local ecs = require("internal.ecs")

local FieldLayer = class.class("FieldLayer", IUiLayer)

FieldLayer:delegate("input", IInput)

function FieldLayer:init()
   self.active = false
   self.bg = nil
   self.ecs = ecs:new()
   self.battle = false

   self.weapons = {}

   self.input = InputHandler:new()
   local keymap = self:make_keymap()
   self.input:bind_keys(keymap)
   self.input:bind_mouse(keymap)
end

function FieldLayer:make_keymap()
   return {
      shift = function() self.canceled = true end,
      escape = function() self.canceled = true end,
      raw_mouse_1_pressed = function()
         if self.weapons[1] then
            self.weapons[1].activated = true
         end
      end
   }
end

local function wall(x, y, polygon)
   return {
      name = "Wall",

      compo_shape = true,
      hidden = true,
      shapes = {{
         type = "polygon",
         polygon = polygon,
      }},

      compo_physics = true,
      x = x,
      y = y,
      body_type = "static",
   }
end

function FieldLayer:refresh_nodes(game)
   if game.node.bg then
      self.bg = love.graphics.newImage(game.node.bg)
   else
      self.bg = nil
   end

   self.ecs:clear_entities()

   self.ecs:add_entity(wall(-50, 0, {0, 0, 50, 0, 50, Draw.get_height(), 0, Draw.get_height()}))
   self.ecs:add_entity(wall(Draw.get_width(), 0, {0, 0, 50, 0, 50, Draw.get_height(), 0, Draw.get_height()}))
   self.ecs:add_entity(wall(0, -50, {0, 0, 0, 50, Draw.get_width(), 50, Draw.get_width(), 0}))
   self.ecs:add_entity(wall(0, Draw.get_height(), {0, 0, 0, 50, Draw.get_width(), 50, Draw.get_width(), 0}))

   for _, child in Node.children(game.node) do
      self.ecs:add_entity(child)
   end

   self.ecs:update(0)
end

function FieldLayer:select_weapon(id)
   local player = Node.player()
   if player.equipment.weapon then
      self.weapons[1] = player.equipment.weapon
      self.ecs:add_entity(player.equipment.weapon)
   end
end

function FieldLayer:add_player()
   local player = Node.player()
   player.x = Draw.get_width() / 2
   player.y = Draw.get_height() / 2
   self.ecs:add_entity(player)
   self:select_weapon(1)
end

function FieldLayer:remove_player()
   local player = Node.player()
   self.ecs:remove_entity(player)
   for _, weapon in pairs(self.weapons) do
      self.ecs:remove_entity(weapon)
   end
end

function FieldLayer:do_focus(focused)
   if not self.active and focused then
      self:add_player()
   elseif self.active and not focused then
      self:remove_player()
   end

   self.active = focused

   if Game.state() == "battle" then
      self.battle = true
   else
      self.battle = false
   end
end

function FieldLayer:add_node(node)
   self.ecs:add_entity(node)
end

function FieldLayer:remove_node(node)
   self.ecs:remove_entity(node)
end

function FieldLayer:relayout(x, y)
end

function FieldLayer:update(dt)
   self.ecs:update(dt)

   if self.canceled then
      return nil, "canceled"
   end
end

function FieldLayer:draw()
   if self.bg then
      Draw.set_color(255, 255, 255)
      Draw.image_filled(self.bg, 0, 0, Draw.get_width(), Draw.get_height())
   else
      Draw.set_color(0, 0, 0)
      Draw.filled_rect(0, 0, Draw.get_width(), Draw.get_height())
   end

   Draw.set_color(255, 255, 255)
   self.ecs:draw()

   if self.battle then
      Draw.set_color(255, 100, 100)
      Draw.text_shadowed("Battle", 10, 10)
   end
end

return FieldLayer

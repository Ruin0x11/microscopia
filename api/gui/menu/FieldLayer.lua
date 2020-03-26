local Draw = require("api.Draw")
local Node = require("api.Node")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local ecs = require("internal.ecs")

local FieldLayer = class.class("FieldLayer", IUiLayer)

FieldLayer:delegate("input", IInput)

function FieldLayer:init()
   self.input = InputHandler:new()
   self.bg = nil
   self.ecs = ecs:new()
end

function FieldLayer:refresh_nodes(game)
   if game.node.bg then
      self.bg = love.graphics.newImage(game.node.bg)
   else
      self.bg = nil
   end

   self.ecs:clear_entities()

   self.ecs:add_entity {
      compo_shape = true,
      hidden = true,
      color = {255, 0, 0},
      shape = "polygon",
      polygon = {0, 0,
         50, 0,
         50, Draw.get_height(),
         0, Draw.get_height()},

      compo_physics = true,
      x = -50,
      y = 0,
      body_type = "static",
   }

   self.ecs:add_entity {
      compo_shape = true,
      hidden = true,
      color = {255, 0, 0},
      shape = "polygon",
      polygon = {0, 0,
         50, 0,
         50, Draw.get_height(),
         0, Draw.get_height()},

      compo_physics = true,
      x = Draw.get_width(),
      y = 0,
      body_type = "static",
   }

   self.ecs:add_entity {
      compo_shape = true,
      hidden = true,
      color = {255, 0, 0},
      shape = "polygon",
      polygon = {0, 0,
         0, 50,
         Draw.get_width(), 50,
         Draw.get_width(), 0},

      compo_physics = true,
      x = 0,
      y = -50,
      body_type = "static",
   }

   self.ecs:add_entity {
      compo_shape = true,
      hidden = true,
      color = {255, 0, 0},
      shape = "polygon",
      polygon = {0, 0,
         0, 50,
         Draw.get_width(), 50,
         Draw.get_width(), 0},

      compo_physics = true,
      x = 0,
      y = Draw.get_height(),
      body_type = "static",
   }

   for _, child in Node.children(game.node) do
      self.ecs:add_entity(child)
   end

   self.ecs:update(0)
end

function FieldLayer:add_node(node)
   self.ecs:add_entity(node)
end

function FieldLayer:remove_node(node)
   self.ecs:remove_entity(node)
end

function FieldLayer:make_keymap()
   return {
      shift = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }
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
end

return FieldLayer

local IDrawable = require("api.gui.IDrawable")
local tiny = require("thirdparty.tiny")

local physics_system = require("internal.system.physics_system")
local polygon_render_system = require("internal.system.polygon_render_system")
local name_render_system = require("internal.system.name_render_system")
local player_control_system = require("internal.system.player_control_system")
local weapon_control_system = require("internal.system.weapon_control_system")
local weapon_render_system = require("internal.system.weapon_render_system")
local item_render_system = require("internal.system.item_render_system")

local ecs = class.class("ecs", IDrawable)

function ecs:init()
   self._update = tiny.world()
   self._update:addSystem(player_control_system:new())
   self._update:addSystem(weapon_control_system:new())
   self._update:addSystem(physics_system:new())

   self._draw = tiny.world()
   self._draw:addSystem(name_render_system:new())
   self._draw:addSystem(item_render_system:new())
   self._draw:addSystem(polygon_render_system:new())
   self._draw:addSystem(weapon_render_system:new())
end

function ecs:add_entity(entity)
   entity.system = {}

   self._update:addEntity(entity)
   self._draw:addEntity(entity)

   return entity
end

function ecs:remove_entity(entity)
   self._update:removeEntity(entity)
   self._draw:removeEntity(entity)
end

function ecs:clear_entities()
   self._update:clearEntities()
   self._draw:clearEntities()
end

function ecs:update(dt, filter)
   self._update:update(dt, filter)
end

function ecs:draw(filter)
   self._draw:update(0, filter)
end

return ecs

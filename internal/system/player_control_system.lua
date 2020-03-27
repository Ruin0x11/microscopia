local Input = require("api.Input")
local tiny = require("thirdparty.tiny")

local player_control_system = class.class("player_control_system")
tiny.processingSystem(player_control_system)

function player_control_system:init()
   self.filter = tiny.requireAll("compo_player_control", "compo_physics")
end

function player_control_system:onAdd(e)
   e.system.player = {}
end

function player_control_system:process(e, dt)
   local mouse = Input.get_mouse_pos()
   local accel = e.accel
   local min_dist = 16
   local dist = mouse:dist(e.pos)
   if dist < min_dist then
      accel = accel * (1 - (min_dist - dist) / min_dist)
   end
   local unit = (mouse-e.pos):normalize() * accel
   e.system.physics.body:setLinearVelocity(unit.x, unit.y)
end

function player_control_system:onRemove(e)
   e.system.player = nil
end

return player_control_system

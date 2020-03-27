local Gui = require("api.Gui")
local Input = require("api.Input")
local tiny = require("thirdparty.tiny")

local weapon_control_system = class.class("weapon_control_system")
tiny.processingSystem(weapon_control_system)

function weapon_control_system:init()
   self.filter = tiny.requireAll("compo_weapon", "compo_physics", "compo_shape")
end

function weapon_control_system:onAdd(e)
   e.system.weapon = {}
   e.cur_recharge = e.cur_recharge or 0
   e.equipped = true
   e.activated = false
end

function weapon_control_system:proc_weapon_hit(weapon, target, fixtures)
   if target.compo_item then
      local _, contact = next(fixtures)

      print(contact:getPositions())
      Gui.add_effect(target.pos.x, target.pos.y, "base.hit")
      if weapon.sound_hit then
         Gui.play_sound(weapon.sound_hit)
      end
      local force = 1000
      local vec = (target.pos - weapon.pos):normalize() * force
      target.system.physics:apply_force(vec.x, vec.y, weapon.x, weapon.y)
   end
end

function weapon_control_system:process(e, dt)
   local mouse = Input.get_mouse_pos()
   e.system.physics.body:setPosition(mouse.x, mouse.y)

   if e.cur_recharge > 0 then
      e.cur_recharge = e.cur_recharge - dt
   elseif e.activated then
      if e.sound_attack then
         Gui.play_sound(e.sound_attack)
      end
      for target, fixtures in pairs(e.system.physics.collides) do
         self:proc_weapon_hit(e, target, fixtures)
      end
      if e.recharge then
         e.cur_recharge = e.recharge
      end
   end

   e.activated = false
end

function weapon_control_system:onRemove(e)
   e.system.weapon = nil
   e.equipped = false
end

return weapon_control_system

local Draw = require("api.Draw")
local tiny = require("thirdparty.tiny")

local weapon_render_system = class.class("weapon_render_system")
tiny.processingSystem(weapon_render_system)

function weapon_render_system:init()
   self.filter = tiny.requireAll("compo_weapon", "compo_shape")
end

function weapon_render_system:process(e, dt)
   Draw.text("Weapon", e.pos.x, e.pos.y)
   if e.cur_recharge > 0 then
      Draw.set_color(50, 50, 50)
      Draw.filled_rect(e.pos.x - 50, e.pos.y + 10, 100, 10)
      Draw.set_color(130, 130, 130)
      Draw.filled_rect(e.pos.x, e.pos.y + 10, (1 - (e.cur_recharge / e.recharge)) * 50, 10)
      Draw.filled_rect(e.pos.x - 50 + (e.cur_recharge / e.recharge) * 50, e.pos.y + 10, (1 - (e.cur_recharge / e.recharge)) * 50, 10)
   end
end

return weapon_render_system

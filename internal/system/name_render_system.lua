local Draw = require("api.Draw")
local tiny = require("thirdparty.tiny")

local name_render_system = class.class("name_render_system")
tiny.processingSystem(name_render_system)

function name_render_system:init()
   self.filter = tiny.requireAll("compo_physics", "name")
end

function name_render_system:onAdd(e)
   Draw.set_font(12)
   e.system.name = {
      text = Draw.make_text(e.name)
   }
end

function name_render_system:process(e, dt)
   if e.hidden or e.equipped or e.compo_player_control then
      return
   end

   Draw.set_font(12)
   local w = Draw.text_width(e.name)
   local h = 20

   Draw.set_color(0, 0, 0)
   Draw.filled_rect(e.pos.x - w / 2 - 1, e.pos.y + h - 1, w + 2, Draw.text_height() + 2)
   Draw.set_color(255, 255, 255)
   Draw.text(e.system.name.text, e.pos.x - w / 2, e.pos.y + Draw.text_height() * 1.5 + 1)
end

function name_render_system:onRemove(e)
   e.system.name = nil
end

return name_render_system

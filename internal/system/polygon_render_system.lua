local Draw = require("api.Draw")
local tiny = require("thirdparty.tiny")

local polygon_render_system = class.class("polygon_render_system")
tiny.processingSystem(polygon_render_system)

function polygon_render_system:init()
   self.filter = tiny.requireAll("compo_shape", "compo_render_shape")
end

function polygon_render_system:process(e, dt)
   if e.hidden then
      return
   end

   if e.shape == "circle" then
      Draw.set_color(e.color)
      Draw.line_circle(e.x, e.y, e.radius)
   elseif e.shape == "polygon" then
      Draw.set_color(e.color)
      Draw.line_polygon(e.x, e.y, e.polygon)
   end
end

return polygon_render_system

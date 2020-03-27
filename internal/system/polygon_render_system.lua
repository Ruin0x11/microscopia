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

   for _, shape in ipairs(e.shapes) do
      Draw.set_color(shape.color or e.color or {255, 255, 255})
      if shape.type == "circle" then
         Draw.line_circle(e.pos.x, e.pos.y, shape.radius)
      elseif shape.type == "polygon" then
         Draw.line_polygon(e.pos.x, e.pos.y, shape.polygon, e.rotation)
      end
   end
end

return polygon_render_system

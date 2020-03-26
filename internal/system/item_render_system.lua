local Draw = require("api.Draw")
local tiny = require("thirdparty.tiny")

local item_render_system = class.class("item_render_system")
tiny.processingSystem(item_render_system)

function item_render_system:init()
   self.filter = tiny.requireAll("compo_item")
end

function item_render_system:onAdd(e)
   local image = love.graphics.newImage(e.image)
   e.system.item = {
      image = image,
      dx = -(image:getWidth() / 2),
      dy = -(image:getHeight() / 2)
   }
end

function item_render_system:process(e, dt)
   if e.hidden then
      return
   end

   Draw.set_font(12)
   Draw.set_color(e.color)
   Draw.image(e.system.item.image, e.x + e.system.item.dx, e.y + e.system.item.dy)
end

function item_render_system:onRemove(e)
   e.system.item = nil
end

return item_render_system

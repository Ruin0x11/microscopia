local Draw = require("api.Draw")
local Node = require("api.Node")

data:add_type {
   name = "event",
   fields = {
      {
         name = "callback",
         type = "function"
      }
   }
}

data:add {
   _type = "base.event",
   _id = "scatter",

   callback = function(node)
      for _, child in Node.children(node) do
         if child.system.physics then
            child.system.physics:apply_force(math.random(-500, 500), math.random(-500, 500))
         end
      end
   end
}

data:add {
   _type = "base.event",
   _id = "start",

   callback = function(node)
      Node.add(node, {
                  name = "学食",
                  compo_location = true,
                  visible_in = "menu",
                  bg = "/data/graphic/bg/gakusyoku01.jpg",
                  image = "/data/graphic/chip/jelly.png",
      })

      for i = 1, 10 do
         local proto = {
            compo_shape = true,
            shapes = {{
                  type = "circle",
                  radius = 16,
                  color = {255, 255, 255, 0},
                  restitution = 0.9,
            }},
            name = "メロンパン",

            compo_render_shape = true,

            compo_physics = true,
            x = math.random(0, Draw.get_width()),
            y = math.random(0, Draw.get_height()),
            body_type = "dynamic",

            compo_item = true,
            image = "/data/graphic/chip/melon_pan.png",
         }
         node.events = {
            on_enter = {
               "base.scatter"
            }
         }
         Node.add(node, proto)
      end
   end
}

for i=0,100 do
   Gui.add_popup(math.random(0, Draw.get_width()), math.random(0, Draw.get_height()), "asdf", Color.random())
end

Node.clear(Node.current())

for i=1, 100 do
   local e = Node.add(Node.current(), {
      compo_shape = true,
      shape = "circle",
      radius = 10,
      color = {255, 255, 255},
      name = "Test thing " .. i,

      compo_render_shape = true,

      compo_physics = true,
      x = math.random(0, Draw.get_width()),
      y = math.random(0, Draw.get_height()),
      body_type = "dynamic",
      restitution = 0.9,

      compo_item = true,
      image = "/data/graphic/chip/melon_pan.png",

      bg = "/data/graphic/bg/gakusyoku01.jpg",
   })
   Node.current().events = {
      on_enter = {
         "base.scatter"
      }
   }
end

field:refresh_nodes()

-- Local Variables:
-- elona-next-always-send-to-repl: t
-- End:

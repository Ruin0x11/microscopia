local Gui = require("api.Gui")
local Node = require("api.Node")

local Tools = {}

function Tools.sound_test()
   local node = Node.create {
      name = "Sound Test",
      compo_location = true,
      bg = "/data/graphic/bg/kankyou01.jpg"
   }
   for _, dat in data["base.sound"]:iter() do
      Node.add(node, {
                  name = dat._id,

                  compo_activator = true,
                  on_activate = function() Gui.play_sound(dat._id) end
      })
   end
   node.parent = Node.current()
   Node.goto_node(node)
end

function Tools.music_test()
   local node = Node.create {
      name = "Music Test",
      compo_location = true,
      bg = "/data/graphic/bg/kankyou01.jpg"
   }
   Node.add(node, {
               name = "Stop Music",

               compo_activator = true,
               on_activate = Gui.stop_music
   })
   for _, dat in data["base.music"]:iter() do
      Node.add(node, {
                  name = dat._id,

                  compo_activator = true,
                  on_activate = function() Gui.play_music(dat._id) end
      })
   end
   node.parent = Node.current()
   Node.goto_node(node)
end

return Tools

data:add {
   _type = "base.node",
   _id = "mynode",

   compos = {
      physics = {},
      base_stats = {
         -- copy on recalculate
         hp = 100,
         mp = 100
      },
      effects = {
         "base.effect1",
      },
      events = {
         on_reload = {
            "base.on_reload1",
            function(self)
               print("test")
            end
         }
      }
   }
}

data:add {
   _type = "base.effect",
   _id = "effect1",

   compos = {
   }
}

local Gui = require("api.Gui")
local Node = require("api.Node")

local node = Node.current()

Node.proc(node, "on_reload")

Gui.add_effect(25, 25, "explod", {depth=1.0})

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

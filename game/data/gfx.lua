local Draw = require("api.Draw")
local Timer = require("thirdparty.timer")

data:add_type {
   name = "gfx",
   fields = {
      {
         name = "draw",
         type = "function"
      },
      {
         name = "update",
         type = "function"
      }
   }
}


data:add {
   _type = "base.gfx",
   _id = "hit",

   create = function(args)
      args.radius = 0.0
      args.color = {255, 255, 255, 255}
      args.timer = Timer.new()
      args.timer:script(function(wait)
            args.timer:tween(0.4, args, { radius = 50.0, }, "out-cubic")
            wait(0.5)
            args.timer:tween(0.2, args.color, { [4] = 0 }, "linear")
      end)
      return args
   end,

   update = function(dt, args)
      args.timer:update(dt)
      if next(args.timer.functions) == nil then
         return true
      end
   end,

   draw = function(args)
      Draw.set_color(args.color)
      Draw.line_circle(args.x, args.y, args.radius)
   end
}

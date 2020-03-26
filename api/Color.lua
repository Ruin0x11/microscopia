local Color = {}

local function mod(v, percent)
   return math.clamp(v+(v*percent/100), 0, 1)
end

function Color.mod(color, percent)
   return {
      mod(color[1], percent),
      mod(color[2], percent),
      mod(color[3], percent),
   }
end

function Color.brighten(color, percent)
   return Color.mod(color, percent)
end

function Color.darken(color, percent)
   return Color.mod(color, -percent)
end

function Color.random()
   return { math.random(0, 255), math.random(0, 255), math.random(0, 255) }
end

return Color

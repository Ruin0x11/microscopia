data:add_type {
   name = "music",
   fields = {
      {
         name = "file",
         type = "string",
         template = true
      }
   }
}

local music = {
   _0 = "0.mid",
   anotherworld = "anotherworld.mid",
   gameover = "gameover.mid",
   whitream = "tym00.mid"
}

for k, v in pairs(music) do
   data:add {
      _type = "base.music",
      _id = k,
      file = ("data/sound/%s"):format(v)
   }
end

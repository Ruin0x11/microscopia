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
   anotherworld = "anotherworld.mid"
}

for k, v in pairs(music) do
   data:add {
      _type = "base.music",
      _id = k,
      file = ("data/sound/%s"):format(v)
   }
end

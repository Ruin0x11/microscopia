data:add_type {
   name = "sound",
   fields = {
      {
         name = "file",
         type = "string",
         template = true
      }
   }
}

local sound = {
   pop1 = "1.wav",
   pop2 = "2.wav",
   awa = "awa.wav",
   b = "b.wav",
   back = "back.wav",
   bara = "bara.wav",
   bin = "bin.wav",
   bom2 = "bom2.wav",
   box = "box.wav",
   camp = "camp.wav",
   coin = "COIN.WAV",
   cry = "cry.wav",
   damage = "damage.wav",
   damage2 = "damage2.wav",
   death = "death.WAV",
   door = "door.wav",
   enemy = "enemy.wav",
   gameover = "gameover.wav",
   great = "great.wav",
   happy = "happy.wav",
   hissatu = "hissatu.wav",
   hit = "hit.wav",
   holl = "holl.wav",
   item_get = "ITEM_GET.wav",
   item_get2 = "item_get2.wav",
   kagi_machine = "kagi_machine.wav",
   kaifuku = "KAIFUKU.WAV",
   kane = "kane.wav",
   sword = "KEN.WAV",
   key = "key.wav",
   key2 = "key2.wav",
   lv = "lv.wav",
   lvup = "lvup.wav",
   lvup2 = "lvup2.wav",
   mes = "mes.wav",
   no = "no.wav",
   noise00 = "noise00.wav",
   ok = "ok.wav",
   open = "open.wav",
   open2 = "open2.wav",
   oyatu = "oyatu.wav",
   paper2 = "paper2.wav",
   pi = "pi.wav",
   point = "point.wav",
   rare = "rare.wav",
   reload = "reload.wav",
   save = "save.wav",
   se192 = "SE192.ogg",
   stage = "stage.wav",
   start = "start.WAV",
   suka = "suka.wav",
   taberu = "TABERU.WAV",
   track = "track.wav",
   text = "text.wav",
   up = "up.wav",
   victory = "victory.wav",
   walk2 = "walk2.wav",
   ya = "ya.wav",
}

for k, v in pairs(sound) do
   data:add {
      _type = "base.sound",
      _id = k,
      file = ("data/sound/%s"):format(v)
   }
end

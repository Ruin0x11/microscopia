Color = require("api.Color")

for i=0,100 do
   Gui.add_popup(math.random(0, Draw.get_width()), math.random(0, Draw.get_height()), "asdf", Color.random())
end

-- Local Variables:
-- elona-next-always-send-to-repl: t
-- End:

local Log = require("api.Log")
local config = require("internal.config")
local data = require("internal.data")
local draw = require("internal.draw")

local Input = {}

function Input.reload_keybinds()
   Log.info("Reloading keybinds.")

   local kbs = config["base.keybinds"]
   for _, kb in data["base.keybind"]:iter() do
      local id = kb._id

      -- allow omitting "base." if the keybind is provided by the base
      -- mod.
      if string.match(id, "^base%.") then
         id = string.split(id, ".")[2]
      end

      if kbs[id] == nil then
         kbs[id] = {
            primary = kb.default,
            alternate = kb.default_alternate,
         }
      end
   end

   local layer = draw.get_layer(0)
   if layer then
      layer:focus()
   end
end

function Input.back_to_field()
   local layers = table.set {
      "MainHud",
      "field_layer",
      "MainTitleMenu"
   }
   while not layers[draw.get_layer(0).__class.__name] do
      draw.pop_layer()
   end
end

return Input

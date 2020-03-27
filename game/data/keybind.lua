local Input = require("api.Input")
local Env = require("api.Env")

data:add_type {
   name = "keybind",
   fields = {
      {
         name = "default",
         type = "string"
      },
      {
         name = "default_alternate",
         type = "string?"
      }
   }
}

local function add_keybinds(raw)
   local kbs = {}
   for id, default in pairs(raw) do
      if type(default) == "table" then
         local rest = table.deepcopy(default)
         table.remove(rest, 1)
         kbs[#kbs+1] = { _id = id, default = default[1], default_alternate = rest }
      else
         kbs[#kbs+1] = { _id = id, default = default }
      end
   end
   data:add_multi("base.keybind", kbs)
end

local keybinds = {
   cancel = "shift",
   escape = "escape",
   quit = "escape",
   restart = "f9",
   reinit = "f8",
   switch_view = "tab",
   north = {"up", "kp8"},
   south = {"down", "kp2"},
   west = {"left", "kp4"},
   east = {"right", "kp6"},
   northwest = "kp7",
   northeast = "kp9",
   southwest = "kp1",
   southeast = "kp3",

   repl = "`",
   repl_page_up = {"pageup", "ctrl_u"},
   repl_page_down = {"pagedown", "ctrl_d"},
   repl_first_char = {"home", "ctrl_a"},
   repl_last_char = {"end", "ctrl_e"},
   repl_paste = "ctrl_v",
   repl_cut = "ctrl_x",
   repl_copy = "ctrl_c",
   repl_clear = "ctrl_l",
   repl_complete = "tab",
}

add_keybinds(keybinds)

if Env.is_hotloading() then
   Input.reload_keybinds()
end

local Node = require("api.Node")
local save_store = require("internal.save_store")

local logic = {}

function logic.start_game()
   save_store.clear()

   local sword = Node.create {
      name = "Sword",

      compo_shape = true,
      shapes = {{
         type = "polygon",
         polygon = {-5, -60, -5, 60, 5, 60, 5, -60},
         is_sensor = true,
         categories = { "overlay" },
         masks = { "player" }
      }},
      color = {0, 255, 255},

      compo_render_shape = true,

      compo_physics = true,
      body_type = "dynamic",
      restitution = 0.0,

      compo_item = true,
      image = "/data/graphic/chip/sword.png",

      compo_equipment = true,

      compo_weapon = true,
      recharge = 5.0,
      sound_attack = "base.sword"
   }

   local fist = Node.create {
      name = "fist",

      compo_shape = true,
      shapes = {{
         type = "circle",
         radius = 7,
         is_sensor = true,
         categories = { "overlay" },
         masks = { "player" }
      }},
      color = {0, 255, 255},

      compo_render_shape = true,

      compo_physics = true,
      body_type = "dynamic",
      restitution = 0.0,

      compo_weapon = true,
      recharge = 0.1,
      sound_hit = "base.damage"
   }

   save.base.player = Node.create {
      name = "Player",

      compo_shape = true,
      shapes = {{
         type = "circle",
         radius = 10,
         color = {255, 255, 255},
         is_sensor = true,
         categories = { "player" },
         masks = { "overlay" }
      }},

      compo_render_shape = true,

      compo_player_control = true,
      accel = 500,

      compo_physics = true,
      body_type = "dynamic",
      restitution = 0.0,

      compo_being = true,
      equipment = {
         weapon = sword
      }
   }

   local field = require("internal.global.field")
   field:goto_node(Node.create {
      name = "Test",
      children = {},
      events = {
         on_create = {
            "base.start"
         }
      },

      compo_location = true,
      bg = "data/graphic/bg/business00.jpg",
   })
end

function logic.main_loop()
   local field = require("internal.global.field")

   logic.start_game()

   local going = true
   while going do
      local _, canceled, err = field:query()
      if canceled == "canceled" then
         going = false
      elseif canceled == "error" then
         coroutine.yield(err)
      end
   end

   return "quit"
end

return logic

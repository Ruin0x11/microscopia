local Log = require("api.Log")
local IMouseInput = require("api.gui.IMouseInput")

local bump = require("thirdparty.bump")
local input = require("internal.input")

local MouseHandler = class.class("MouseHandler", IMouseInput)

function MouseHandler:init()
   self.bindings = {}
   self.this_frame = {}
   self.forwards = {}
   self.movement = nil
   self.mouse_areas = {}
   self.bump = bump.newWorld()
   self.x = -1
   self.y = -1
end

function MouseHandler:receive_mouse_button(x, y, button, pressed)
   for _, forward in ipairs(self.forwards) do
      forward:receive_mouse_button(x, y, button, pressed)
   end
   self.this_frame[button] = {x = x, y = y, pressed = pressed}
end

function MouseHandler:receive_mouse_movement(x, y, dx, dy)
   for _, forward in ipairs(self.forwards) do
      forward:receive_mouse_movement(x, y, dx, dy)
   end
   self.movement = {x = x, y = y, dx = dx, dy = dy}
   self.x = x
   self.y = y
end

function MouseHandler:bind_mouse(bindings)
   self.bindings = bindings
end

function MouseHandler:add_mouse_area(x, y, width, height)
   local area = {}
   area.move = function(_, _x, _y, _width, _height)
      self.bump:update(area, _x, _y, _width, _height)
   end
   self.mouse_areas[area] = {pressed = false, hovered = false}
   self.bump:add(area, x, y, width, height)
   return area
end

function MouseHandler:remove_mouse_area(area)
   self.mouse_areas[area] = nil
   self.bump:remove(area)
end

function MouseHandler:forward_to(handlers)
   if not handlers[1] then
      handlers = { handlers }
   end
   for _, handler in ipairs(handlers) do
      assert(class.is_an(IMouseInput, handler))
   end
   self.forwards = handlers
end

function MouseHandler:focus()
   input.set_mouse_handler(self)
end

function MouseHandler:halt_input()
end

function MouseHandler:update_repeats()
end

function MouseHandler:run_mouse_action(button, x, y, pressed)
   if Log.has_level("trace") then
      Log.trace("Mouse button: %s %s %s %s %s", button, x, y, pressed, self)
   end

   local areas, len = self.bump:queryPoint(x, y)
   if len > 0 then
      local area = areas[1]
      local area_data = self.mouse_areas[area]
      if area.on_pressed then
         if pressed and not area_data.pressed then
            area:on_pressed(true)
            area_data.pressed = true
         elseif not pressed and area_data.pressed then
            area:on_pressed(false)
            area_data.pressed = false
         end
      end
      return true
   end

   local func = self.bindings[button]
   if func then
      return true, func(x, y, pressed)
   else
      for _, forward in ipairs(self.forwards) do
         local did_something, first_result = forward:run_mouse_action(button, x, y, pressed)
         if did_something then
            return did_something, first_result
         end
      end
   end

   return false, nil
end

function MouseHandler:run_mouse_movement_action(x, y, dx, dy)
   if Log.has_level("trace") then
      Log.trace("Mouse movement: %s %s %s %s %s", x, y, dx, dy, self)
   end

   local func = self.bindings["moved"]
   if func then
      return true, func(x, y, dx, dy)
   else
      for _, forward in ipairs(self.forwards) do
         local did_something, first_result = forward:run_mouse_movement_action(x, y, dx, dy)
         if did_something then
            return did_something, first_result
         end
      end
   end

   return false, nil
end

function MouseHandler:update_mouse_hovers(x, y)
   local areas, len = self.bump:queryPoint(x, y)
   local hovered = table.set(areas)

   for area, area_data in pairs(self.mouse_areas) do
      if area.on_hovered then
         if hovered[area] and not area_data.hovered then
            area:on_hovered(true)
            area_data.hovered = true
         elseif not hovered[area] and area_data.hovered then
            area:on_hovered(false)
            area_data.hovered = false
         end
      end
   end

   for _, forward in ipairs(self.forwards) do
      forward:update_mouse_hovers(x, y)
   end
end

function MouseHandler:run_actions()
   local ran = {}
   for k, v in pairs(self.this_frame) do
      self:run_mouse_action(k, v.x, v.y, v.pressed)
   end

   if self.movement then
      self:run_mouse_movement_action(self.movement.x,
                                     self.movement.y,
                                     self.movement.dx,
                                     self.movement.dy)
   end

   self:update_mouse_hovers(self.x, self.y)

   self.this_frame = {}
   self.movement = nil
end

return MouseHandler

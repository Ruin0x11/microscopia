local Env = require("api.Env")
local Log = require("api.Log")
local IDrawable = require("api.gui.IDrawable")
local IInput = require("api.gui.IInput")

local draw = require("internal.draw")

local IUiLayer = class.interface("IUiLayer",
                                 {
                                    relayout = "function",
                                    make_keymap = "function",
                                 },
                                 { IDrawable, IInput })

function IUiLayer:default_z_order()
   return 100000
end

--- Starts drawing this UI layer and switches input focus to it.
---
--- @treturn[opt] any The value returned by the layer's `update`
--- function. Always nil if the layer was canceled, but not
--- necessarily non-nil if it was not canceled.
--- @treturn[opt] string Equals "canceled" if the layer was canceled
--- out of.
function IUiLayer:query(z_order)
   class.assert_is_an(IUiLayer, self)

   if draw.is_layer_active(self) then
      Log.warn("Draw layer '%s' is already being queried.")
      return nil, "canceled"
   end

   if z_order == nil then
      z_order = self:default_z_order() or 100000
   end

   self:bind_keys(self:make_keymap())

   local dt = 0
   local abort = false

   local ok, result = xpcall(draw.push_layer, debug.traceback, self, z_order)
   if not ok then
      error(result)
   end

   ok, result = pcall(function() return self:on_query() end)
   if not ok or (ok and result == false) then
      draw.pop_layer()
      if not ok then
         error(result)
      end
      return
   end

   local success, res, canceled

   while true do
      if abort then
         Log.error("Draw error encountered, removing layer.")
         local Input = require("api.Input")
         Input.back_to_field()
      end

      -- Check if the layer has modified the internal state of the
      -- layer stack, and if so bail out immediately so the focus
      -- can be restored to the current layer. Otherwise the game
      -- will be stuck in this loop forever waiting for user input,
      -- which might not be able to be provided if the focused
      -- layer was switched already.
      local current = draw.get_layer(0)
      if current ~= self then
         current:focus()
         current:halt_input()
         return nil, "canceled"
      end

      success, res, canceled = xpcall(
         function()
            local ran = self:run_actions(dt)
            return self:update(dt, ran)
         end,
         debug.traceback)
      if not success then
         Log.error("Error on query: %s", res)
         res = nil
         canceled = "error"
         break
      end
      if res or canceled then break end
      dt, abort = coroutine.yield()
   end

   ok, result = pcall(function()
         self:halt_input()
         self:release()
   end)

   if not ok then
      Log.error("Error releasing UI layer: %s", result)
   end

   draw.pop_layer()

   return res, canceled
end

function IUiLayer:release()
end

function IUiLayer:on_query()
end

function IUiLayer:on_hotload_layer()
end

return IUiLayer

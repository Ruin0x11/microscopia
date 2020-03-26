--- @module Repl

local Env = require("api.Env")
local SaveFs = require("api.SaveFs")
local draw = require("internal.draw")
local env = require("internal.env")
local repl = require("internal.repl")
local fs = require("util.fs")

local Repl = {}

local repl_layer = nil

local function setup_repl()
   local ReplLayer = require("api.gui.menu.ReplLayer")

   local repl_env, history = Repl.generate_env()

   repl_layer = ReplLayer:new(repl_env, { history = history })
end

function Repl.send(code)
   if repl_layer == nil then
      setup_repl()
   end

   return repl_layer:execute(code)
end

function Repl.query()
   if repl_layer == nil then
      setup_repl()
   end

   -- The repl could get hotloaded, so keep it in an upvalue.
   local layer = repl_layer
   layer:query()

   if layer then
      layer:save_history()
   end
end

function Repl.get()
   return repl_layer
end

function Repl.reset()
   repl_layer = nil
end

function Repl.clear()
   repl_layer:clear()
end

function Repl.print(text, color)
   repl_layer:print(text, color)
end

--- Queues a code block that runs the next time execution enters the
--- player's control. If the code returns a turn result, it is used as
--- the player's turn.
function Repl.defer_execute(code)
   repl_layer:defer_execute(code)
end

function Repl.generate_env(locals)
   locals = locals or {}

   local repl_env = env.generate_sandbox("repl")
   local apis = repl.require_all_apis("api", true)
   repl_env = table.merge(repl_env, apis)

   repl_env = table.merge(repl_env, _G)
   repl_env = table.merge(repl_env, repl.require_all_apis("internal", true))
   repl_env = table.merge(repl_env, repl.require_all_apis("game"))
   repl_env = table.merge(repl_env, repl.require_all_apis("util"))

   repl_env._traceback = debug.traceback("", nil, 2)

   repl_env["save"] = require("internal.global.save")

   local history = {}
   if SaveFs.exists("data/repl_history") then
      local ok
      ok, history = SaveFs.read("data/repl_history")
      if not ok then
         error(history)
      end
   end

   local vars = { normal = repl_env, locals = locals }

   -- For REPL completion, we need a list of the keys in this
   -- environment. Because the environment is a proxy with no actual
   -- keys, we can't calculate the list from the outside. To solve
   -- this, generate the list of keys up front and update it in the
   -- __newindex metamethod.
   local keys = table.merge(table.keys(vars.locals), table.keys(vars.normal))

   local env_proxy = setmetatable({}, {
         __index = function(self, ind)
            if rawget(vars.locals, ind) then
               return rawget(vars.locals, ind)
            end
            return rawget(vars.normal, ind)
         end,
         __newindex = function(self, ind, val)
            if rawget(vars.locals, ind) then
               rawset(vars.locals, ind, val)
            else
               rawset(vars.normal, ind, val)
            end
            if val == nil then
               table.iremove_value(keys, ind)
            else
               keys[#keys+1] = ind
            end
         end,
         __keys = keys
   })

   if fs.exists("repl_startup.lua") then
      local chunk = love.filesystem.load("repl_startup.lua")
      setfenv(chunk, env_proxy)
      chunk()
   end

   return env_proxy, history
end

local paused = false

--- Stops execution at the point this function is called and starts
--- the REPL with all local variables in scope captured in its
--- environment. If any modifications are made to local variables,
--- they will be reflected when execution resumes.
function Repl.pause()
   if Env.is_headless() or paused then
      return
   end
   paused = true

   local locals = repl.capture_locals(1)
   local repl_env, history = Repl.generate_env(locals)

   local mod, loc = env.find_calling_mod(1)
   local loc_string = ""
   if loc then
      loc_string = loc_string .. (" in %s on line %d"):format(fs.normalize(loc.short_src), loc.linedefined)
   end
   if mod then
      loc_string = loc_string .. (" (mod: `%s`)"):format(mod)
   end

   local mes = ("Breakpoint%s.\nLocals: %s"):format(loc_string, table.concat(table.keys(locals), ", "))
   local params = {
      history = history,
      color = {65, 17, 17, 192},
      message = mes
   }

   local ok, err = pcall(function()
         require("api.gui.menu.ReplLayer"):new(repl_env, params):query()
   end)

   repl.restore_locals(1, locals)

   paused = false

   if not ok then
      error(err)
   end
end

return Repl

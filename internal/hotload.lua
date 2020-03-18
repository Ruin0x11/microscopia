local env = require("internal.env")

local hotload = {}

local hotloaded_data = {}

local function clear_hotloaded_data()
   hotloaded_data = {}
end
local function add_hotloaded_data(_, args)
   hotloaded_data[#hotloaded_data+1] = args.entry
end

-- Pass a list of everything hotloaded when hotloading finishes.
-- Event.register("base.on_hotload_begin", "Clear hotloaded data list", clear_hotloaded_data)
-- Event.register("base.on_hotload_prototype", "Add to hotloaded data list", add_hotloaded_data)


--- Reloads a path or a class required from a path that has been
--- required already by updating its table in-place. If either the
--- result of `require` or the existing item in package.loaded are not
--- tables, the existing item is overwritten instead.
-- @tparam string|table path
-- @tparam bool also_deps If true, also hotload any nested
-- dependencies loaded with `require` that any hotloaded chunk tries
-- to load.
-- @treturn table
function hotload.hotload(path_or_class, also_deps)
   if type(path_or_class) == "table" then
      local path = env.get_require_path(path_or_class)
      if path == nil then
         error("Unknown require path for " .. tostring(path_or_class))
      end

      path_or_class = path
   end

   -- pcall(Event.trigger, "base.on_hotload_begin", {path_or_class=path_or_class,also_deps=also_deps})

   local ok, result = xpcall(env.hotload_path, debug.traceback, path_or_class, also_deps)

   -- pcall(Event.trigger, "base.on_hotload_end", {hotloaded_data=hotloaded_data,path_or_class=path_or_class,also_deps=also_deps,ok=ok,result=result})

   if not ok then
      error(result)
   end

   return result
end

return hotload

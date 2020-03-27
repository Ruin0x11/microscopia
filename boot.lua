_CONSOLE = false
_IS_LOVEJS = jit == nil

local dir_sep = package.config:sub(1,1)
local is_windows = dir_sep == "\\"

package.path = package.path .. ";./thirdparty/?.lua;./?/init.lua"

class = require("util.class")

require("ext")

inspect = require("thirdparty.inspect")
fun = require("thirdparty.fun")
cpml = require("thirdparty.cpml")

if is_windows then
   -- Do not buffer stdout for Emacs compatibility.
   -- Requires LOVE's source to be modified to use stdin/stdout pipes
   -- on Windows.
   io.stdout:setvbuf("no")
   io.stderr:setvbuf("no")
end

if _IS_LOVEJS then
   -- hack to satisfy strict.lua
   jit = nil
end

-- prevent new globals from here on out.
require("thirdparty.strict")

-- Hook the global `require` to support hotloading.
require("internal.env").hook_global_require()

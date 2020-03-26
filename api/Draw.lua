--- Functions for drawing things on the screen.
---
--- These functions must only be used from a drawing context - either
--- the draw() callback of an IDrawable or within a deferred draw
--- callback.
---
--- @module Draw
local draw = require("internal.draw")
local Env = require("api.Env")

local Draw = {}

--- @function Draw.layer_count
Draw.layer_count = draw.layer_count

--- @function Draw.get_layer
Draw.get_layer = draw.get_layer

--- @function Draw.set_root
Draw.set_root = draw.set_root

--- @function Draw.get_coords
Draw.get_coords = draw.get_coords

--- @function Draw.get_tiled_width
Draw.get_tiled_width = draw.get_tiled_width

--- @function Draw.get_tiled_height
Draw.get_tiled_height = draw.get_tiled_height

--- @function Draw.with_canvas
Draw.with_canvas = draw.with_canvas

--- @function Draw.set_font
Draw.set_font = draw.set_font

--- @function Draw.run
Draw.run = draw.run


--- @function Draw.get_width
Draw.get_width = love.graphics.getWidth

--- @function Draw.get_height
Draw.get_height = love.graphics.getHeight

--- @function Draw.create_canvas
Draw.create_canvas = love.graphics.newCanvas

--- Sets the current drawing color. You can provide a table of up to  four
--- values or four separate integers.
---
--- @tparam int|color r
--- @tparam[opt] int g
--- @tparam[opt] int b
--- @tparam[opt] int a
function Draw.set_color(r, g, b, a)
   if type(r) == "table" then
      love.graphics.setColor(
         r[1] / 255,
         r[2] / 255,
         r[3] / 255,
         (r[4] or 255) / 255)
   else
      love.graphics.setColor(
         r / 255,
         g / 255,
         b / 255,
         (a or 255) / 255)
   end
end

function Draw.set_background_color(r, g, b, a)
   love.graphics.setBackgroundColor(r, g, b, a)
end

--- @tparam int|color r
--- @tparam[opt] int g
--- @tparam[opt] int b
--- @tparam[opt] int a
function Draw.clear(r, g, b, a)
   if type(r) == "table" then
      love.graphics.clear(
         r[1] / 255,
         r[2] / 255,
         r[3] / 255,
         (r[4] or 255) / 255)
   else
      love.graphics.clear(
         (r or 0) / 255,
         (b or 0) / 255,
         (g or 0) / 255,
         (a or 0) / 255)
   end
end

--- Draws text.
---
--- @tparam string str
--- @tparam int x
--- @tparam int y
--- @tparam[opt] color color
--- @tparam[opt] int size
function Draw.text(str, x, y, color, size)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   if size then
      Draw.set_font(size)
   end
   if str.typeOf and str:typeOf("Text") then
      love.graphics.draw(str, x, y)
   else
      love.graphics.print(str, x, y)
   end
end

--- Draws a filled rectangle.
---
--- @tparam int x
--- @tparam int y
--- @tparam int width
--- @tparam int height
--- @tparam[opt] color color
function Draw.filled_rect(x, y, width, height, color)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   love.graphics.polygon("fill", x, y, x + width, y, x + width, y + height, x, y + height)
end

--- Draws a rectangle using lines.
---
--- @tparam int x
--- @tparam int y
--- @tparam int width
--- @tparam int height
--- @tparam[opt] color color
function Draw.line_rect(x, y, width, height, color)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   love.graphics.polygon("line", x, y, x + width, y, x + width, y + height, x, y + height)
end

--- @tparam int x
--- @tparam int y
--- @tparam table vertices
--- @tparam[opt] float rotation
--- @tparam[opt] color color
function Draw.line_polygon(x, y, vertices, rotation, color)
   rotation = rotation or 0.0
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   local v = {}
   for i=1,#vertices, 2 do
      local dx = x * math.cos(-rotation) + y * math.sin(-rotation)
      local dy = y * math.cos(-rotation) - x * math.sin(-rotation)
      v[#v+1] = vertices[i] + dx
      v[#v+1] = vertices[i+1] + dy
   end
   love.graphics.polygon("line", v)
end

--- @tparam int x
--- @tparam int y
--- @tparam float radius
--- @tparam[opt] color color
function Draw.line_circle(x, y, radius, color)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   love.graphics.circle("line", x, y, radius)
end

--- Draws a line.
---
--- @tparam int x1
--- @tparam int y1
--- @tparam int x2
--- @tparam int y2
--- @tparam[opt] color color
function Draw.line(x1, y1, x2, y2, color)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   love.graphics.line(x1, y1 + 1, x2, y2 + 1)
end

--- Returns the width of the provided text using the current font or a
--- font of the given size.
---
--- @tparam string text
--- @tparam[opt] int size
--- @treturn int Width in pixels.
function Draw.text_width(text, size)
   text = text or " "
   if size then
      Draw.set_font(size)
   end
   return love.graphics.getFont():getWidth(text)
end

--- Returns the height in pixels of the current font.
---
--- @tparam[opt] int size
--- @treturn int Height in pixels.
function Draw.text_height()
   return love.graphics.getFont():getHeight()
end

--- Wraps the given text according to a wrap limit in pixels using the
--- current font.
---
--- @tparam string text
--- @tparam int wraplimit Maximum width in pixels.
function Draw.wrap_text(text, wraplimit)
   return love.graphics.getFont():getWrap(text, wraplimit)
end

function Draw.image(image, x, y, width, height, color, centered, rotation)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   x = math.floor(x)
   y = math.floor(y)
   local sx = 1
   local sy = 1
   if width and image.getWidth then
      sx = width / image:getWidth()
   end
   if height and image.getHeight then
      sy = height / image:getHeight()
   end
   local ox, oy
   if centered then
      ox = (image:getWidth()) / 2
      oy = (image:getHeight()) / 2
   end

   -- Sprite batches will ignore the width and height of
   -- love.graphics.draw; we have to manually set the scissor.
   local do_scissor = image.typeOf and image:typeOf("SpriteBatch") and width and height
   if do_scissor then
      love.graphics.setScissor(x, y, width, height)
   end

   local result = love.graphics.draw(image, x, y, math.rad(rotation or 0), sx, sy, ox, oy)

   if do_scissor then
      love.graphics.setScissor()
   end

   return result
end

function Draw.image_region(image, quad, x, y, width, height, color, centered, rotation)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   x = math.floor(x)
   y = math.floor(y)
   local sx = 1
   local sy = 1
   local _, _, qw, qh = quad:getViewport()
   if width then
      sx = width / qw
   end
   if height then
      sy = height / qh
   end
   local ox, oy
   if centered then
      ox = (width or qw) / 2
      oy = (width or qh) / 2
   end
   return love.graphics.draw(image, quad, x, y, math.rad(rotation or 0), sx, sy, ox, oy)
end

function Draw.image_stretched(image, x, y, tx, ty, color, centered, rotation)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   x = math.floor(x)
   y = math.floor(y)
   local sx = 1
   local sy = 1
   if tx and ty then
      sx = (tx - x) / image:getWidth()
      sy = (ty - y) / image:getHeight()
   end
   return love.graphics.draw(image, x, y, math.rad(rotation or 0), sx, sy)
end

function Draw.image_region_stretched(image, quad, x, y, tx, ty, color, centered, rotation)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   x = math.floor(x)
   y = math.floor(y)
   local sx = 1
   local sy = 1
   local _, _, qw, qh = quad:getViewport()
   if tx and ty then
      sx = (tx - x) / qw
      sy = (ty - y) / qh
   end
   return love.graphics.draw(image, quad, x, y, math.rad(rotation or 0), sx, sy)
end

function Draw.image_scaled(image, x, y, sx, sy, color, centered, rotation)
   if color then
      Draw.set_color(color[1], color[2], color[3], color[4])
   end
   x = math.floor(x)
   y = math.floor(y)
   return love.graphics.draw(image, x, y, math.rad(rotation or 0), sx, sy)
end

function Draw.image_filled(image, x, y)
   local scale = math.max(Draw.get_width() / image:getWidth(), Draw.get_height() / image:getHeight())
   return love.graphics.draw(image, x or 0, y or 0, 0, scale, scale)
end

-- local atlases = require("internal.global.atlases")
--
-- function Draw.make_chip_batch(atlas)
--    local the_atlas = atlases.get()[atlas]
--    if not the_atlas then
--       error(("Atlas '%s' doesn't exist."):format(atlas))
--    end
--    return the_atlas:make_batch()
-- end

function Draw.chip(chip, x, y, width, height, color, centered, rotation)
end

--- Waits the specified number of milliseconds. Be careful with this
--- function since you can easily freeze the game if the provided
--- duration is too large.
---
--- @tparam int msecs Duration in milliseconds.
function Draw.wait(msecs)
   love.timer.sleep(msecs / 1000)
end

function Draw.add_async_callback(cb)
   if type(cb) ~= "function" then
      error("Callback must be a function.")
   end

   error("unimplemented")
end

-- TODO: sanitize
Draw.yield = coroutine.yield

--- Draws shadowed text.
---
--- @tparam string str
--- @tparam int x
--- @tparam int y
--- @tparam[opt] color color
--- @tparam[opt] color shadow_color
function Draw.text_shadowed(str, x, y, color, shadow_color)
   color = color or {255, 255, 255}
   shadow_color = shadow_color or {0, 0, 0}
   Draw.set_color(shadow_color[1], shadow_color[2], shadow_color[3], shadow_color[4])
   for dx=-1,1 do
      for dy=-1,1 do
         Draw.text(str, x + dx, y + dy)
      end
   end
   Draw.text(str, x, y, color)
end

--- Converts from milliseconds to the number of frames elapsed in that
--- time. By default, assumes a refresh rate of 60 FPS.
---
--- @tparam int msecs
--- @tparam[opt] int framerate
function Draw.msecs_to_frames(msecs)
   -- TODO: assumes 60 FPS
   local framerate = 60
   local msecs_per_frame = (1 / framerate or 60) * 1000
   local frames = msecs / msecs_per_frame
   return frames
end

function Draw.load_image_data(path)
   return love.image.newImageData(path)
end

local supports_subtract = Env.os() ~= "Android"

function Draw.set_blend_mode(mode, alphamode)
   -- BUG: Graphics hardware on mobile devices doesn't always seem to
   -- support the "subtract" blending mode. In this case, we should
   -- color the shadow black and blend as "alpha" instead.
   if mode == "subtract" and not supports_subtract then
      mode = "alpha"
   end

   love.graphics.setBlendMode(mode, alphamode)
end

function Draw.make_text(text)
   return love.graphics.newText(love.graphics.getFont(), text)
end

return Draw

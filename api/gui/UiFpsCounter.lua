local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local UiFpsGraph = require("api.gui.UiFpsGraph")
local draw_stats = require("internal.global.draw_stats")
local Env = require("api.Env")

local UiFpsCounter = class.class("UiFpsCounter", IUiElement)

function UiFpsCounter:init()
   self.show_draw_stats = true
   self.ms = 0
   self.frames = 0
   self.text = Draw.make_text()
   self.threshold = 0
   self.prev_fps = 0
   self.prev_ram = 0
   self.now = Env.get_time()
   self.buff = ""

   self.fps_graph = UiFpsGraph:new({0, 0, 255, 128})
   self.ram_graph = UiFpsGraph:new({255, 0, 0, 128})
   self.ram_diff_graph = UiFpsGraph:new({0, 255, 0, 128})
end

function UiFpsCounter:relayout(x, y, width, height)
   self.x = Draw.get_width() - Draw.text_width(self.buff) - 5
   self.y = y or self.y
end

function UiFpsCounter:draw()
   Draw.set_color(255, 255, 255)
   Draw.set_font(14)

   Draw.text_shadowed(self.text, self.x, 5)

   self.fps_graph:draw()
   self.ram_graph:draw()
   self.ram_diff_graph:draw()
end

function UiFpsCounter:update()
   if not draw_stats.frame_start then
      return
   end

   local now = Env.get_time()
   local dt = now - self.now
   self.now = now
   self.ms = self.ms + dt * 1000

   self.frames = self.frames + 1
   draw_stats.frame_start = false

   if self.ms >= self.threshold then
      local fps = self.frames / (self.ms / 1000)
      local ram = collectgarbage("count") / 1024
      local diff = ram - self.prev_ram
      Draw.set_font(14)
      local buff = string.format("FPS: %02.2f\nRAM: %04.2fMB \nRMD: %04.4fMB", fps, ram, diff)
      self.frames = 0
      self.ms = 0

      self.fps_graph:add_point(fps)
      self.ram_graph:add_point(ram)
      self.ram_diff_graph:add_point(diff)

      if self.show_draw_stats and draw_stats.drawcalls then
         buff = buff .. string.format("\nDRW: %d\nCNV: %d\nTXTR: %04.2fMB\nIMG: %d\nCNVS: %d\nFNTS: %d",
                                                draw_stats.drawcalls,
                                                draw_stats.canvasswitches,
                                                draw_stats.texturememory / 1024 / 1024,
                                                draw_stats.images,
                                                draw_stats.canvases,
                                                draw_stats.fonts)
      end

      Draw.set_font(14)
      local relayout = self.buff == ""
      self.buff = buff
      self.text = Draw.make_text(self.buff)
      local x = self.x - 105

      if relayout then
         self:relayout()
      end
      self.fps_graph:relayout(x, 5, 100, 40)
      self.ram_graph:relayout(x, 5 + 45, 100, 40)
      self.ram_diff_graph:relayout(x, 5 + 45 + 45, 100, 40)

      self.prev_fps = fps
      self.prev_ram = ram
      self.prev_diff = diff
   end
end

return UiFpsCounter

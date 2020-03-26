local tiny = require("thirdparty.tiny")

local METER_PX = 64

local physics_system = class.class("physics_system")
tiny.processingSystem(physics_system)

function physics_system:init()
   self.filter = tiny.requireAll("compo_physics", "compo_shape")

   love.physics.setMeter(METER_PX)
   self.physics_world = love.physics.newWorld(0, 0, true)
end

function physics_system:onAdd(e)
   local dat = {}
   dat.body = love.physics.newBody(self.physics_world, e.x, e.y, e.body_type or "dynamic")
   if e.shape == "circle" then
      dat.shape = love.physics.newCircleShape(e.radius)
   elseif e.shape == "polygon" then
      dat.shape = love.physics.newPolygonShape(e.polygon)
   else
      error("unknown shape " .. tostring(e.shape))
   end
   dat.fixture = love.physics.newFixture(dat.body, dat.shape, 1)
   dat.fixture:setRestitution(e.restitution or 0.0)
   dat.apply_force = function(self, fx, fy, x, y)
      if x then
         self.body:applyForce(fx, fy, x, y)
      else
         self.body:applyForce(fx, fy)
      end
   end
   e.system.physics = dat
end

function physics_system:onRemove(e)
   e.system.physics.body:destroy()
   e.system.physics = nil
end

local update = physics_system.update
function physics_system:update(dt)
   self.physics_world:update(dt)
   update(self, dt)
end

function physics_system:process(e, dt)
   e.x = e.system.physics.body:getX()
   e.y = e.system.physics.body:getY()
   e.rotation = e.system.physics.body:getAngle()
end

return physics_system

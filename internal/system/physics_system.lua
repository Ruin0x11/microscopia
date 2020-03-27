local Draw = require("api.Draw")
local Log = require("api.Log")
local Game = require("api.Game")

local tiny = require("thirdparty.tiny")

local METER_PX = 64

local physics_system = class.class("physics_system")
tiny.processingSystem(physics_system)

function physics_system.begin_contact(a, b, coll)
   local entity_a = a:getUserData().entity
   local entity_b = b:getUserData().entity
   local ca = entity_a.system.physics.collides
   local cb = entity_b.system.physics.collides
   ca[entity_b] = ca[entity_b] or {}
   ca[entity_b][b] = coll
   cb[entity_a] = ca[entity_a] or {}
   cb[entity_a][a] = coll
end

function physics_system.end_contact(a, b, coll)
   local entity_a = a:getUserData().entity
   local entity_b = b:getUserData().entity
   local ca = entity_a.system.physics.collides
   local cb = entity_b.system.physics.collides
   ca[entity_b][b] = nil
   if next(ca[entity_b]) == nil then
      ca[entity_b] = nil
   end
   cb[entity_a][a] = nil
   if next(cb[entity_a]) == nil then
      cb[entity_a] = nil
   end
end

function physics_system.pre_solve(a, b, coll)
end

function physics_system.post_solve(a, b, coll, normalimpulse, tangentimpulse)
end

local function wrap(t, n)
   return function(...) return t[n](...) end
end

function physics_system:init()
   self.filter = tiny.requireAll("compo_physics", "compo_shape")

   love.physics.setMeter(METER_PX)
   self.physics_world = love.physics.newWorld(0, 0, true)
   self.physics_world:setSleepingAllowed(false)
   self.physics_world:setCallbacks(wrap(physics_system, "begin_contact"),
                                   wrap(physics_system, "end_contact"),
                                   wrap(physics_system, "pre_solve"),
                                   wrap(physics_system, "post_solve"))
end

local CATEGORIES = {
   default = 1,
   player = 2,
   overlay = 3
}

local function make_fixture(dat, shape, e)
   local fixture = {}
   if shape.type == "circle" then
      fixture.shape = love.physics.newCircleShape(shape.radius)
   elseif shape.type == "polygon" then
      fixture.shape = love.physics.newPolygonShape(shape.polygon)
   else
      error("unknown shape " .. tostring(shape.type))
   end
   fixture.fixture = love.physics.newFixture(dat.body, fixture.shape, 1)
   fixture.fixture:setRestitution(shape.restitution or 0.0)
   fixture.fixture:setFriction(shape.friction or 100.0)
   if shape.is_sensor then
      fixture.fixture:setSensor(true)
   end
   fixture.fixture:setUserData({entity = e})
   if shape.categories then
      local categories = fun.iter(shape.categories):map(function(c) return CATEGORIES[c] end):to_list()
      fixture.fixture:setCategory(table.unpack(categories))
   end
   if shape.masks then
      local masks = fun.iter(shape.masks):map(function(c) return CATEGORIES[c] end):to_list()
      fixture.fixture:setMask(table.unpack(masks))
   end
   return fixture
end

function physics_system:onAdd(e)
   e.pos = e.pos or cpml.vec2.new(e.x or math.random(0, Draw.get_width()), e.y or math.random(0, Draw.get_height()))
   e.x = nil
   e.y = nil

   local dat = {}
   dat.body = love.physics.newBody(self.physics_world, e.pos.x, e.pos.y, e.body_type or "dynamic")
   if e.rotation then
      dat.body:setAngle(e.rotation)
   end
   dat.body:setLinearDamping(e.damping or 5, e.damping or 5)
   dat.body:setMass(e.mass or 1)

   local fixtures = {}
   for _, shape in ipairs(e.shapes) do
      fixtures[#fixtures+1] = make_fixture(dat, shape, e)
   end
   dat.fixtures = fixtures

   dat.collides = {}

   dat.apply_force = function(self, fx, fy, x, y)
      if x then
         self.body:applyForce(fx, fy, x, y)
      else
         self.body:applyForce(fx, fy)
      end
   end
   dat.set_pos = function(self, x, y)
      self.body:setPos(x, y)
   end
   e.system.physics = dat
end

function physics_system:onRemove(e)
   e.system.physics.body:destroy()
   e.system.physics = nil
end

local update = physics_system.update
function physics_system:update(dt)
   if Game.is_simulation_paused() then
      return
   end

   self.physics_world:update(dt)
   update(self, dt)
end

function physics_system:process(e, dt)
   local body = e.system.physics.body
   e.pos.x = body:getX()
   e.pos.y = body:getY()
   e.rotation = body:getAngle()
end

return physics_system

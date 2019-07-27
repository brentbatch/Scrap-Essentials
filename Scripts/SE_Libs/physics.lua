local version = 1.0

-- Prefix: sm.physics.

-- Commands:
	-- addVelocity(body, velocity, global, offset)
	-- creationAddVelocity(in_body, velocity)
	-- addAngularVelocity(body, velocity, global)

-- Improved:
	-- shape:addVelocity(velocity, global, offset)
	-- body:addVelocity(velocity, global, offset)
	-- body:creationAddVelocity(velocity)
	-- body:addAngularVelocity(velocity, global)





--[[
	Copyright (c) 2019 Scrap Essentials Team
]]--

-- Version check
if sm.__SE_Version.physics and version <= sm.__SE_Version.physics then return end



-- Add velocity for shapes/bodies
function sm.physics.addVelocity(body, velocity, global, offset)
	global = global or false
	offset = offset or sm.vec3.new(0,0,0)
	assert(type(body) == "Shape" or type(body) == "Body", "addVelocity: argument 1, Shape or Body expected! got: "..type(body))
	assert(type(velocity) == "Vec3", "addVelocity: argument 2, Vec3 expected! got: "..type(velocity))
	assert(type(global) == "boolean", "addVelocity: argument 3, boolean expected! got: "..type(global))
	assert(type(offset) == "Vec3", "addVelocity: argument 4, Vec3 expected! got: "..type(offset))
	sm.physics.applyImpulse(body, velocity * body.mass, global, offset)
end

-- Add velocity for vehicles
function sm.physics.creationAddVelocity(in_body, velocity, global)
	assert(type(in_body) == "Body", "creationAddVelocity: argument 1, Body expected! got: "..type(in_body))
	assert(type(velocity) == "Vec3", "creationAddVelocity: argument 2, Vec3 expected! got: "..type(velocity))
	for i, body in pairs(in_body:getCreationBodies()) do sm.physics.applyImpulse(body, velocity * body.mass, global) end
end

--Add angular velocity for bodies
function sm.physics.addAngularVelocity(body, a_velocity, global)
	global = global or false
	assert(type(body) == "Body", "addAngularVelocity: argument 1, Body expected! got: "..type(body))
	assert(type(a_velocity) == "Vec3", "addAngularVelocity: argument 2, Vec3 expected! got: "..type(a_velocity))
	assert(type(global) == "boolean", "addAngularVelocity: argument 3, boolean expected! got: "..type(global))
	sm.physics.applyTorque(body, a_velocity * body:getMOI(a_velocity), global)
end

table.insert(sm.__SE_UserDataImprovements_Server, function(self)
	self.shape.addVelocity = function(body, velocity, global, offset) return sm.physics.addVelocity(body, velocity, global, offset) end
	self.shape.body.addVelocity = function(body, velocity, global, offset) return sm.physics.addVelocity(body, velocity, global, offset) end
	self.shape.body.creationAddVelocity = function(in_body, velocity, global) return sm.physics.creationAddVelocity(in_body, velocity, global) end
	self.shape.body.addAngularVelocity = function(body, a_velocity, global) return sm.physics.addAngularVelocity(body, a_velocity, global) end
end)



sm.__SE_Version.physics = version
print("'physics' library version "..tostring(version).." successfully loaded.")
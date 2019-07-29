local version = 1.0

-- Prefix: sm.vec3.

-- Commands:
	-- normalize(vector) -- Normalizes vector
	-- copy(vector) -- Copies a vector, so it isn't referenced
	-- parallel(vector, vector) -- Returns component of vector that's parallel to vector
	-- tangent(vector, vector) -- Returns component of vector that's tangent to vector
	-- localize(vector, shape) -- Represents vector in shape's coordinate system from world's coordinate system
	-- delocalize(vector, shape) -- Represents vector in world's coordinate system from shape's coordinate system
	-- random() -- Returns a vector with random direction


-- Improved:
	-- vector:normalize()
	-- vector:copy()
	-- vector:parallel(vector)
	-- vector:tangent(vector)
	-- vector:localize(shape)
	-- vector:delocalize(shape)





--[[
	 Copyright (c) 2019 Scrap Essentials Team
]]--

-- Version check
if sm.__SE_Version.vec3 and version <= sm.__SE_Version.vec3 then return end



-- Working normalize
function sm.vec3.normalize(vector1)
	assert(type(vector1) == "Vec3", "normalize: argument 1, Vec3 expected! got: "..type(vector1))
	return vector1:length2() == 0 and vector1 or vector1 * ( 1 / vector1:length())
end

-- Copy vector
function sm.vec3.copy(vector1)
	assert(type(vector1) == "Vec3", "copy: argument 1, Vec3 expected! got: "..type(vector1))
	return sm.vec3.new(vector1.x, vector1.y, vector1.z)
end

-- Parallel element
function sm.vec3.parallel(vector1, vector2)
	assert(type(vector1) == "Vec3", "parallel: argument 1, Vec3 expected! got: "..type(vector1))
	assert(type(vector2) == "Vec3", "parallel: argument 2, Vec3 expected! got: "..type(vector2))
	local vec = vector2:normalize()
	return vec * vec:dot(vector1)
end

-- Tangent element
function sm.vec3.tangent(vector1, vector2)
	assert(type(vector1) == "Vec3", "tangent: argument 1, Vec3 expected! got: "..type(vector1))
	assert(type(vector2) == "Vec3", "tangent: argument 2, Vec3 expected! got: "..type(vector2))
	local vec = vector2:normalize()
	return vector1 - vec * vec:dot(vector1)
end

-- Localize
function sm.vec3.localize(vector1, shape)
	assert(type(vector1) == "Vec3", "localize: argument 1, Vec3 expected! got: "..type(vector1))
	assert(type(shape) == "Shape", "localize: argument 2, Shape expected! got: "..type(shape))
	return sm.vec3.new(shape:getRight():dot(vector1), shape:getAt():dot(vector1), shape:getUp():dot(vector1))
end

-- Delocalize
function sm.vec3.delocalize(vector1, shape)
	assert(type(vector1) == "Vec3", "delocalize: argument 1, Vec3 expected! got: "..type(vector1))
	assert(type(shape) == "Shape", "delocalize: argument 2, Shape expected! got: "..type(shape))
	return shape:getRight() * vector1.x + shape:getAt() * vector1.y + shape:getUp() * vector1.z
end

-- Random direction vector
function sm.vec3.random()
	local angle = sm.noise.randomRange(0, 2 * math.pi)
	local z = sm.noise.randomRange(-1, 1)
	local temp = math.sqrt(1 - z*z)
	return sm.vec3.new(temp * math.cos(angle), temp * math.sin(angle), z)
end

sm.vec3.new(0,0,0).normalize = sm.vec3.normalize
sm.vec3.new(0,0,0).copy = sm.vec3.copy
sm.vec3.new(0,0,0).parallel = sm.vec3.parallel
sm.vec3.new(0,0,0).tangent = sm.vec3.tangent
sm.vec3.new(0,0,0).localize = sm.vec3.localize
sm.vec3.new(0,0,0).delocalize = sm.vec3.delocalize



sm.__SE_Version.vec3 = version
print("'vec3' library version "..tostring(version).." successfully loaded.")
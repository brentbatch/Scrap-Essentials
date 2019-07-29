local version = 1.0

-- Prefix: sm.body.

-- Commands:
	--sm.body.getCOM(body) -- Returns the center of mass of the body
	--sm.body.getCreationCOM(body) -- Returns the center of mass of the creation
	--sm.body.getMOI(body, axis) -- Returns the moment of inertia of the body on the axis
	--sm.body.getCreationMOI(body, axis) -- Returns the moment of inertia of the creation on the axis

-- Improved:
	--body:getCOM()
	--body:getCreationCOM()
	--body:getMOI(axis)
	--body:getCreationMOI(axis)





--[[
	Copyright (c) 2019 Scrap Essentials Team
]]--

-- Version check
if sm.__SE_Version.body and version <= sm.__SE_Version.body then return end



local COM = {}
local MOI = {}

-- Body's center of mass
function sm.body.getCOM(body)
	assert(type(body) == "Body", "getCOM: argument 1, Body expected! got: "..type(body))
	if (not COM[body.id]) then COM[body.id] = {} end
	-- First iteration or change detected
	if ((not COM[body.id].tick)or((COM[body.id].tick < sm.game.getCurrentTick())and(sm.body.hasChanged(body, COM[body.id].tick)))or(not sm.exists(COM[body.id].shape))) then
		if (not COM[body.id].body) then COM[body.id].body = body end -- AUTO DELETE
		local shapes = body:getShapes()
		COM[body.id].shape = shapes[1]
		local mass = 0
		local center = sm.vec3.new(0, 0, 0)
		for i, shape in pairs(shapes) do
			center = center + shape:getWorldPosition() * shape:getMass()
			mass = mass + shape:getMass()
		end
		center = center * (1 / mass) --VectorBug
		local displacement = center - COM[body.id].shape:getWorldPosition()
		COM[body.id].vector = displacement:localize(COM[body.id].shape)
		COM[body.id].tick = sm.game.getCurrentTick()
		return center
	end
	return COM[body.id].shape:getWorldPosition() + COM[body.id].vector:delocalize(COM[body.id].shape)
end

-- Vehicle's center of mass
function sm.body.getCreationCOM(in_body)
	assert(type(in_body) == "Body", "getCreationCOM: argument 1, Body expected! got: "..type(in_body))
	local bodies = in_body:getCreationBodies()
	local mass = 0
	local center = sm.vec3.new(0, 0, 0)
	for i, body in pairs(bodies) do
		center = center + body:getCOM() * body.mass
		mass = mass + body.mass
	end
	center = center * (1 / mass) --VectorBug
	return center
end

-- Creation's moment of inertia
function sm.body.getMOI(body, in_axis)
	assert(type(body) == "Body", "getMOI: argument 1, Body expected! got: "..type(body))
	assert(type(in_axis) == "Vec3", "getMOI: argument 2, Vec3 expected! got: "..type(in_axis))
	if (not MOI[body.id]) then MOI[body.id] = {} end
	if (not MOI[body.id].inertia) then MOI[body.id].inertia = {} end
	if (not MOI[body.id].tick) then MOI[body.id].tick = 0 end
	if (not MOI[body.id].body) then MOI[body.id].body = body end -- AUTO DELETE
	local shapes = body:getShapes()
	MOI[body.id].shape = shapes[1]
	in_axis = in_axis:localize(MOI[body.id].shape)
	in_axis = in_axis:normalize()
	if ((not MOI[body.id].tick)or(sm.body.hasChanged(body, MOI[body.id].tick))) then
		MOI[body.id].inertia.xx = 0
		MOI[body.id].inertia.yy = 0
		MOI[body.id].inertia.zz = 0
		MOI[body.id].inertia.xy = 0
		MOI[body.id].inertia.yz = 0
		MOI[body.id].inertia.xz = 0
		for i, shape in pairs(shapes) do
			local center = body:getCOM()
			local box = shape:getBoundingBox()
			local mass = shape.mass / (box.x * 4 * box.y * 4 * box.z * 4)
			local pos = shape:getWorldPosition()
			for x = box.x * 2, box.x * -2 + 1, -1 do
				local position = pos + shape:getRight() * (x / 4 - 0.125)
				for y = box.y * 2, box.y * -2 + 1, -1 do
					position = position + shape:getAt() * (y / 4 - 0.125)
					for z = box.z * 2, box.z * -2 + 1, -1 do
						position = position + shape:getUp() * (z / 4 - 0.125)
						local dif = position - center
						dif = dif:localize(MOI[body.id].shape)
						MOI[body.id].inertia.xx = MOI[body.id].inertia.xx + mass * (dif.y * dif.y + dif.z * dif.z)
						MOI[body.id].inertia.yy = MOI[body.id].inertia.yy + mass * (dif.x * dif.x + dif.z * dif.z)
						MOI[body.id].inertia.zz = MOI[body.id].inertia.zz + mass * (dif.x * dif.x + dif.y * dif.y)
						MOI[body.id].inertia.xy = MOI[body.id].inertia.xy - mass * dif.x * dif.y
						MOI[body.id].inertia.yz = MOI[body.id].inertia.yz - mass * dif.y * dif.z
						MOI[body.id].inertia.xz = MOI[body.id].inertia.xz - mass * dif.x * dif.z
					end
				end
			end
		end
		MOI[body.id].tick = sm.game.getCurrentTick()
	end
	return in_axis.x * (in_axis.x * MOI[body.id].inertia.xx + in_axis.y * MOI[body.id].inertia.xy + in_axis.z * MOI[body.id].inertia.xz) + in_axis.y * (in_axis.x * MOI[body.id].inertia.xy + in_axis.y * MOI[body.id].inertia.yy + in_axis.z * MOI[body.id].inertia.yz) + in_axis.z * (in_axis.x * MOI[body.id].inertia.xz + in_axis.y * MOI[body.id].inertia.yz + in_axis.z * MOI[body.id].inertia.zz)
end

-- Creation's moment of inertia
--WHY WOULD ANYONE EVER NEED THIS
--YOU CAN'T APPLY TORQUE TO A WHOLE VEHICLE AT ONE TIME ANYWAYS
--ALSO !RESOURCE INTENSIVE!
function sm.body.getCreationMOI(in_body, in_axis)
	assert(type(in_body) == "Body", "getMOI: argument 1, Body expected! got: "..type(in_body))
	assert(type(in_axis) == "Vec3", "getMOI: argument 2, Vec3 expected! got: "..type(in_axis))
	local inertia = {}
	local shapes = in_body:getShapes()
	in_axis = in_axis:localize(shapes[1])
	in_axis = in_axis:normalize()
	inertia.xx = 0
	inertia.yy = 0
	inertia.zz = 0
	inertia.xy = 0
	inertia.yz = 0
	inertia.xz = 0
	for i, body in pairs(in_body:getCreationBodies()) do
		local shapes = body:getShapes()
		for n, shape in pairs(shapes) do
			local center = body:getCOM()
			local box = shape:getBoundingBox()
			local mass = shape.mass / (box.x * 4 * box.y * 4 * box.z * 4)
			local pos = shape:getWorldPosition()
			for x = box.x * 2, box.x * -2 + 1, -1 do
				local position = pos + shape:getRight() * (x / 4 - 0.125)
				for y = box.y * 2, box.y * -2 + 1, -1 do
					position = position + shape:getAt() * (y / 4 - 0.125)
					for z = box.z * 2, box.z * -2 + 1, -1 do
						position = position + shape:getUp() * (z / 4 - 0.125)
						local dif = position - center
						dif = dif:localize(shapes[1])
						inertia.xx = inertia.xx + mass * (dif.y * dif.y + dif.z * dif.z)
						inertia.yy = inertia.yy + mass * (dif.x * dif.x + dif.z * dif.z)
						inertia.zz = inertia.zz + mass * (dif.x * dif.x + dif.y * dif.y)
						inertia.xy = inertia.xy - mass * dif.x * dif.y
						inertia.yz = inertia.yz - mass * dif.y * dif.z
						inertia.xz = inertia.xz - mass * dif.x * dif.z
					end
				end
			end
		end
	end
	return in_axis.x * (in_axis.x * inertia.xx + in_axis.y * inertia.xy + in_axis.z * inertia.xz) + in_axis.y * (in_axis.x * inertia.xy + in_axis.y * inertia.yy + in_axis.z * inertia.yz) + in_axis.z * (in_axis.x * inertia.xz + in_axis.y * inertia.yz + in_axis.z * inertia.zz)
end

table.insert(sm.__SE_UserDataImprovements_Server, function(self)
	self.shape.body.getCOM = function(body) return sm.body.getCOM(body) end
	self.shape.body.getCreationCOM = function(body) return sm.body.getCreationCOM(body) end
	self.shape.body.getMOI = function(body, _1) return sm.body.getMOI(body, _1) end
	self.shape.body.getCreationMOI = function(body, _1) return sm.body.getCreationMOI(body, _1) end
end)

sm.__SE_Version.body = version
print("'body' library version "..tostring(version).." successfully loaded.")
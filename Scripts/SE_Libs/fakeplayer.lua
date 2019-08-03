local version = 1.3

--[[
	requires: table.lua
	
	prefix: sm.fakePlayer.
	
	API:
		sm.fakePlayer.createFake( shape, customId(=0) )
			creates a new fake player (globaly available shape) and asigns it a custom ID
			- shape: the shape to make fake (userdata: Shape)
			- customId: custom ID to asign to fake (number, nil(=0) or string)
		
		sm.fakePlayer.deleteFake( shape, customId(=0) )
			deletes a specific fake player
			- shape: the shape to delete (userdata: Shape)
			- customId: custom id to look for shape (number, nil(=0) or string)
		
		sm.fakePlayer.clearFake( shape )
			clears all instances of the shape from the fakePlayers
			!!! use this in scriptclass.server_onDestroy() !!!
			- shape: the shape to clear (userdata: Shape)
		
		sm.fakePlayer.getFakes( sorted )
			returns a list of fake players (userdata: Shape), if none will return empty table
			- sorted: return table sorted by custom Id's and shape Id's (boolean or nil)
			example return (sorted = true):
				{[231] = {myId = shapeA, anotherId = shapeA}, [527] = {[10] = shapeB}}
				notice: in this example 231 is the id of shapeA and 527 the id of shapeB (asigned by the game)
			example return (sorted = false or nil):
				{[1] = shapeA, [2] = shapeA, [3] = shapeB}
				notice: this is the same table as in the previous example, but incremented with a natural increment and no sub-tables
				
		it is possible to feed the createFake() function a table with a similar structure as the userdata to make
		custom locations. Please note that some mods require a lot of data for it to work properly, most missing
		data gets a default value asigned, but it is still adviced to fill in as many as you can.
		It is adviced to make use of functions like :getWorldPosition() instead of .worldPosition, as the function
		is less likely to break a script (as long as you actually only set those to be a function) and they allow
		you to still change variables after they are already inserted (the function has acces to all variables of
		the scope its defined in).
]]--





--[[
	Copyright (c) 2019 Scrap Essentials Team
]]--

-- Version check
if sm.__SE_Version.fakeplayer and version <= sm.__SE_Version.fakeplayer then return end

sm.fakePlayer = {}
local fakes = {}

function sm.fakePlayer.createFake( shape, id )
	assert(type(shape) == "Shape" or type(shape) == "table", "createFake, parameter1: shape or table expected! got: "..type(shape))
	assert(type(id) == "number" or type(id) == "nil" or type(id) == "string", "createFake, parameter2: number or string expected! got: "..type(id))
	assert(shape.id, "createFake, parameter1: shape has no .id field!")
	
	if type(shape) == "table" then
		shape.shapeUuid = shape.shapeUuid or sm.uuid.getNil()
		shape.color = shape.color or sm.color.new( 0x00000000 )
		shape.mass = shape.mass or 0
		shape.material = shape.material or "none"
		shape.worldPosition = shape.worldPosition or sm.vec3.zero()
		shape.localPosition = shape.localPosition or sm.vec3.zero()
		shape.worldRotation = shape.worldRotation or sm.quat.identity()
		shape.velocity = shape.velocity or sm.vec3.zero()
		shape.xAxis = shape.xAxis or sm.vec3.new(1,0,0)
		shape.yAxis = shape.yAxis or sm.vec3.new(0,1,0)
		shape.zAxis = shape.zAxis or sm.vec3.new(0,0,1)
		shape.at = shape.at or sm.vec3.new(1,0,0)
		shape.right = shape.right or sm.vec3.new(0,1,0)
		shape.up = shape.up or sm.vec3.new(0,0,1)
		
		shape.getId = shape.getId or function() return shape.id end
		shape.getShapeUuid = shape.getShapeUuid or function() return shape.shapeUuid end
		shape.getColor = shape.getColor or function() return shape.color end
		shape.getMass = shape.getMass or function() return shape.mass end
		shape.getMaterial = shape.getMaterial or function() return shape.material end
		shape.getWorldPosition = shape.getWorldPosition or function() return shape.worldPosition end
		shape.getLocalPosition = shape.getLocalPosition or function() return shape.localPosition end
		shape.getWorldRotation = shape.getWorldRotation or function() return shape.worldRotation end
		shape.getVelocity = shape.getVelocity or function() return shape.velocity end
		shape.getXAxis = shape.getXAxis or function() return shape.xAxis end
		shape.getYAxis = shape.getYAxis or function() return shape.yAxis end
		shape.getZAxis = shape.getZAxis or function() return shape.zAxis end
		shape.getAt = shape.getAt or function() return shape.at end
		shape.getRight = shape.getRight or function() return shape.right end
		shape.getUp = shape.getUp or function() return shape.up end
	end
	
	fakes[shape.id] = fakes[shape.id] or {}
	
	fakes[shape.id][id or 0] = shape
	return shape
end

function sm.fakePlayer.deleteFake( shape, id )
	assert(type(shape) == "Shape" or type(shape) == "table", "deleteFake, parameter1: shape or table expected! got: "..type(shape))
	assert(type(id) == "number" or type(id) == "nil" or type(id) == "string", "deleteFake, parameter2: number or string expected! got: "..type(id))
	assert(shape.id, "deleteFake, parameter1: shape has no .id field!")
	
	if not fakes[shape.id] or
	   not fakes[shape.id][id or 0] then 
		return 
	end
 
	fakes[shape.id][id or 0] = nil
	
	if table.size( fakes[shape.id] ) == 0 then fakes[shape.id] = nil end
end

function sm.fakePlayer.clearFake( shape )
	assert(type(shape) == "Shape" or type(shape) == "table", "clearFake: shape or table expected! got: "..type(shape))
	assert(shape.id, "clearFake, parameter1: shape has no .id field!")
	
	fakes[shape.id] = nil
end

function sm.fakePlayer.getFakes( sorted )
	if sorted then
		local tbl = {}
		for shapeId,shapes in pairs(fakes) do
			for customId,shape in pairs(shapes) do
				if not tbl[customId] then tbl[customId] = {} end
				table.insert(tbl[customId], shape)
			end
		end
		return tbl
	else
		local tbl = {}
		for shapeId,shapes in pairs(fakes) do
			for customId,shape in pairs(shapes) do
				table.insert(tbl, shape)
			end
		end
		return tbl
	end
end


sm.__SE_Version.fakeplayer = version
print("'fakeplayer' library version "..tostring(version).." successfully loaded.")
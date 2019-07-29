local version = 1.0

--[[
	prefix: sm.fakePlayer.
	
	API:
		sm.fakePlayer.createFake( shape, cid(=nil) )
			creates a new fake player from a shape and stores it under cid
			- shape: the shape to insert (userdata: Shape)
			- cid: custom id to store the shape under (number or nil)
		
		sm.fakePlayer.deleteFake( shape, cid(=nil) )
			delets a fake player from cid
			- shape: the shape to delete (userdata: Shape)
			- cid: custom id to look for shape (number or nil)
		
		sm.fakePlayer.clearFake( shape )
			clears all instances of the shape from the fakePlayers
			!!! use this in scriptclass.server_onDestroy() !!!
			- shape: the shape to clear (userdata: Shape)
		
		sm.fakePlayer.getFakes()
			returns a list of fake players (userdata: Shape) sorted by custom id, if none will return empty table
			example return:
				{["nil"] = {1 = shape}, ["313"] = {1 = shape, 5 = shape}}
]]--





--[[
	Copyright (c) 2019 Scrap Essentials Team
]]--

-- Version check
if sm.__SE_Version.fakeplayer and version <= sm.__SE_Version.fakeplayer then return end

if not sm.fakePlayer then sm.fakePlayer = {} end

function sm.fakePlayer.createFake( shape, id )
	assert(type(shape) == "Shape", "shape: shape expected! got: "..type(shape))
	assert(type(id) == "number" or type(id) == "nil", "id: number expected! got: "..type(id))
	
	if not sm.fakePlayer.fakes then sm.fakePlayer.fakes = {} end
	if not sm.fakePlayer.fakes[tostring(id)] then sm.fakePlayer.fakes[tostring(id)] = {} end
	
	if sm.fakePlayer.fakes[tostring(id)][shape.id] then return end
	sm.fakePlayer.fakes[tostring(id)][shape.id] = {
		["created"] = sm.game.getCurrentTick(),
		["shape"] = shape
	}
end

function sm.fakePlayer.deleteFake( shape, id )
	assert(type(shape) == "Shape", "shape: shape expected! got: "..type(shape))
	assert(type(id) == "number" or type(id) == "nil", "id: number expected! got: "..type(id))

	if not sm.fakePlayer.fakes then return end
	if not sm.fakePlayer.fakes[tostring(id)] then return end
	if not sm.fakePlayer.fakes[tostring(id)][shape.id] then return end

	sm.fakePlayer.fakes[tostring(id)][shape.id] = nil
	
	for cid, fakes in pairs( sm.fakePlayer.fakes ) do
		if table.size( fakes ) == 0 then sm.fakePlayer.fakes[cid] = nil end
	end
end

function sm.fakePlayer.clearFake( shape )
	assert(type(shape) == "Shape", "shape: shape expected! got: "..type(shape))

	if not sm.fakePlayer.fakes then return end

	for cid, fakes in pairs( sm.fakePlayer.fakes ) do
		fakes[shape.id] = nil
		local i = 0
		for k,v in pairs( fakes ) do
			i=i+1
		end
		if i == 0 then sm.fakePlayer.fakes[cid] = nil end
	end
end

function sm.fakePlayer.getFakes( now )
	assert(type(now) == "boolean" or type(now) == "nil", "now: boolean expected! got: "..type(now))
	
	if not sm.fakePlayer.fakes then return {} end
	
	local tbl = {}
	
	for cid, fakes in pairs( sm.fakePlayer.fakes ) do
		tbl[cid] = {}
		for id, fake in pairs( fakes ) do
			if now or fake.created < sm.game.getCurrentTick() then
				tbl[cid][id] = fake.shape
			end
		end
	end
	
	return tbl
end


sm.__SE_Version.fakeplayer = version
print("'color' library version "..tostring(version).." successfully loaded.")
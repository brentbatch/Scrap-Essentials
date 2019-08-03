dofile "SE_Loader.lua"


-- the following code prevents re-load of this file, except if in '-dev' mode.  -- fixes broken sh*t by devs.
if PlayerImitator and not sm.isDev then -- increases performance for non '-dev' users.
	return -- perform sm.checkDev(shape) in server_onCreate to set sm.isDev
end

-- required to fix printing jank, plus it has a nice layout
function tprint( tbl, indent )
	if not tbl then return end
	  
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			print(formatting)
			tprint(v, indent+1)
			else
			print(formatting .. tostring(v))
		end
	end
end


PlayerImitator = class()
PlayerImitator.maxChildCount = 0
PlayerImitator.maxParentCount = 0
PlayerImitator.connectionInput = sm.interactable.connectionType.logic
PlayerImitator.connectionOutput = sm.interactable.connectionType.logic -- none, logic, power, bearing, seated, piston, any
PlayerImitator.colorNormal = sm.color.new(0xdf7000ff)
PlayerImitator.colorHighlight = sm.color.new(0xef8010ff)


function PlayerImitator.server_onCreate(self)
	print(self.shape.worldPosition)
	sm.isDev = sm.checkDev( self.shape )
	sm.fakePlayer.createFake( self.shape ) -- puts self.shape into the fakePlayer list when spawned
end

function PlayerImitator.server_onDestroy(self)
	sm.fakePlayer.clearFake( self.shape ) -- removes self.shape from the fakePlayer list when destroyed (so its not tracked anymore)
end




PlayerTracker = class()
PlayerTracker.maxChildCount = 0
PlayerTracker.maxParentCount = 0
PlayerTracker.connectionInput = sm.interactable.connectionType.logic
PlayerTracker.connectionOutput = sm.interactable.connectionType.logic -- none, logic, power, bearing, seated, piston, any
PlayerTracker.colorNormal = sm.color.new(0xdf7000ff)
PlayerTracker.colorHighlight = sm.color.new(0xef8010ff)


function PlayerTracker.server_onFixedUpdate(self)
	local position = self.shape.worldPosition
	local fakePlayers = sm.fakePlayer.getFakes( )
	
	if fakePlayers then
		local distance = (position - fakePlayers[1]:getWorldPosition()):length() -- got distance using function getWorldPosition() instead of variable worldPosition because a faked position requires a function to be called
		local trackedFakePlayer = fakePlayers[1]
		
		-- to get closest fakePlayer:
		for k,v in pairs(fakePlayers) do
			local fakeplayerDistance =  (position - v:getWorldPosition()):length()
			if fakeplayerDistance < distance then
				fakeplayerDistance = distance
				trackedFakePlayer = v
			end
		end
		
		print(trackedFakePlayer:getWorldPosition()) -- or do whatever you want with this trackedFakePlayer
	end
end






PlayerSpoofer = class()
PlayerSpoofer.maxChildCount = 0
PlayerSpoofer.maxParentCount = 0
PlayerSpoofer.connectionInput = sm.interactable.connectionType.logic
PlayerSpoofer.connectionOutput = sm.interactable.connectionType.logic -- none, logic, power, bearing, seated, piston, any
PlayerSpoofer.colorNormal = sm.color.new(0xdf7000ff)
PlayerSpoofer.colorHighlight = sm.color.new(0xef8010ff)

function PlayerSpoofer.server_onCreate(self)
	print(self.shape.worldPosition + sm.vec3.new(0,0,1))
	
	local fakePlayer = {id = self.shape.id} -- can be local, can also be stored in self.fakePlayer
	function fakePlayer.getWorldPosition(self_fakePlayer)
		return self.shape.worldPosition + sm.vec3.new(0,0,1)
	end
	-- the function is created here, so it has acces to any variables defined in the script (or at least same location, so not ones defined after it or in a different scope).
	-- in this case, if you call the function from a different block through the fakePlayer, even though the function is called by a different block, the 'self' called will be from the block that made the function.
	-- this method works with both tables and functions, but please only use functions and variables that the game already has, or you might break other peoples mods (so no storing functions in values and other way round).
	-- the fakePlayer library will detect any tables with missing data and fill in as many placeholders as possible to prevent errors due to missing functions, but some are impossible to recreate without an actual shape.
	
	sm.fakePlayer.createFake( fakePlayer )
end


function PlayerSpoofer.server_onDestroy(self)
	sm.fakePlayer.clearFake( {id = self.shape.id} )
end

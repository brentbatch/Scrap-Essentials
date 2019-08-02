dofile "SE_Loader.lua"


-- the following code prevents re-load of this file, except if in '-dev' mode.  -- fixes broken sh*t by devs.
if PlayerImitator and not sm.isDev then -- increases performance for non '-dev' users.
	return -- perform sm.checkDev(shape) in server_onCreate to set sm.isDev
end 


PlayerImitator = class()
PlayerImitator.maxChildCount = 0
PlayerImitator.maxParentCount = 0
PlayerImitator.connectionInput = sm.interactable.connectionType.logic
PlayerImitator.connectionOutput = sm.interactable.connectionType.logic -- none, logic, power, bearing, seated, piston, any
PlayerImitator.colorNormal = sm.color.new(0xdf7000ff)
PlayerImitator.colorHighlight = sm.color.new(0xef8010ff)


function PlayerImitator.server_onCreate(self)
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
	local fakePlayers = {}								-- changes the table structure from containing id's to a simple array
	for k,v in pairs(sm.fakePlayer.getFakes()) do		-- 
		for k,v in pairs(sm.fakePlayer.getFakes()) do	-- 
			table.insert(fakePlayers, v)				-- 
		end												-- 
	end													-- 
	
	local distance = (position - fakePlayers[1]:getWorldPosition()):length() -- got distance using function getWorldPosition() instead of variable worldPosition because a faked position requires a function to be called
	local trackedFakePlayer = fakePlayers[1]
	
	for k,v in pairs(fakePlayers) do
		local fakeplayerDistance =  (position - v:getWorldPosition()):length()
		if fakeplayerDistance < distance then
			fakeplayerDistance = distance
			trackedFakePlayer = v
		end
	end
	
	print(trackedFakePlayer) -- or do whatever you want with this trackedFakePlayer
	
end






PlayerSpoofer = class()
PlayerSpoofer.maxChildCount = 0
PlayerSpoofer.maxParentCount = 0
PlayerSpoofer.connectionInput = sm.interactable.connectionType.logic
PlayerSpoofer.connectionOutput = sm.interactable.connectionType.logic -- none, logic, power, bearing, seated, piston, any
PlayerSpoofer.colorNormal = sm.color.new(0xdf7000ff)
PlayerSpoofer.colorHighlight = sm.color.new(0xef8010ff)

function PlayerSpoofer.server_onCreate(self)
	
	local fakePlayer = {id = self.shape.id} -- can be local, can also be stored in self.fakePlayer
	function fakePlayer.getWorldPosition(self_fakePlayer)
		if self_fakePlayer.lastTick == sm.game.getCurrentTick() then
			return self_fakePlayer.worldPosition
		end
		
		local fakePosition = sm.vec3.new(0,0,0)
		for k, v in pairs(self.interactable:getParents()) do
			if tostring(v.shape.color) == "eeeeeeff" then
				fakePosition.x = v.power
			elseif tostring(v.shape.color) == "7a7a7aff" then
				fakePosition.y = v.power
			elseif tostring(v.shape.color) == "222222ff" then
				fakePosition.z = v.power
			end
		end
		self_fakePlayer.worldPosition = fakePosition
		
		return self_fakePlayer.worldPosition
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

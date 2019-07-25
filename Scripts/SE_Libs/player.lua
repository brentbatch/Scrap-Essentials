local version = 1

if (sm.__SE_Version._Player or 0) >= version then return end
sm.__SE_Version._Player = version

print("Loading extra player functions")


__OLD_placeLift = __OLD_placeLift or sm.player.placeLift
local liftsPlaced = {}
local disabledLifts = {} 

function sm.player.placeLift(player,bodies,position,liftlevel,rotation) -- serverfunction
	table.insert(liftsPlaced, { player = player, bodies = bodies, position = position, liftlevel = liftlevel , rotation = rotation, placed = sm.game.getCurrentTick() })
	if not disabledLifts[player.id] then
		__OLD_placeLift(player,bodies,position,liftlevel,rotation)
	end
	--print(player,bodies,position,liftlevel,rotation)
end
function sm.player.getLiftsPlacements()
	local lifts = liftsPlaced
	liftsPlaced = {}
	return lifts
end
function sm.player.setLiftPlaceable(player, enabled)
	if not enabled or disabledLifts[player.id] then
		disabledLifts[player.id] = not enabled
	end
end

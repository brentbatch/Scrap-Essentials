local version = 1

if (sm.__SE_Version._Player or 0) >= version then return end
sm.__SE_Version._Player = version

print("Loading extra player functions")


sm.player.placeLiftO = sm.player.placeLiftO or sm.player.placeLift
sm.player.lifts = sm.player.lifts or {}
sm.player.disabledLifts = sm.player.disabledLifts or {} 

function sm.player.placeLift(player,bodies,position,liftlevel,rotation) -- serverfunction
	table.insert(sm.player.lifts, { player = player, bodies = bodies, position = position, liftlevel = liftlevel , rotation = rotation, placed = sm.game.getCurrentTick() })
	if not sm.player.disabledLifts[player.id] then
		sm.player.placeLiftO(player,bodies,position,liftlevel,rotation)
	end
	--print(player,bodies,position,liftlevel,rotation)
end
function sm.player.getLifts()
	local lifts = sm.player.lifts
	sm.player.lifts = {}
	return lifts
end
function sm.player.liftEnabled(player, enabled)
	if not enabled or sm.player.disabledLifts[player.id] then
		sm.player.disabledLifts[player.id] = not enabled
	end
end

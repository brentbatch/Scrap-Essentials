print("loading extra player functions")


if not sm.player.placeLiftO then sm.player.placeLiftO = sm.player.placeLift end
if not sm.player.lifts then sm.player.lifts = {} end
if not sm.player.disabledLifts then sm.player.disabledLifts = {} end
function sm.player.placeLift(player,bodies,position,liftlevel,rotation) -- serverfunction
	table.insert(sm.player.lifts, { player = player, bodies = bodies, position = position, liftlevel = liftlevel , rotation = rotation, placed = os.clock() })
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

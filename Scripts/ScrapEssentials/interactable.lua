
print("loaded extra interactable functions")

-- insteractable: setValue getValue
if not sm.interactable.values then sm.interactable.values = {} end -- stores values, 

function sm.interactable.setValue(interactable, value)  
	local currenttick = sm.game.getCurrentTick()
	sm.interactable.values[interactable.id] = {
		{tick = currenttick, value = {value}}, 
		sm.interactable.values[interactable.id] and (	
			sm.interactable.values[interactable.id][1] ~= nil and 
			(sm.interactable.values[interactable.id][1].tick < currenttick) and 
			sm.interactable.values[interactable.id][1].value[1] or sm.interactable.values[interactable.id][2]
		) 
		or nil
	}
end
function sm.interactable.getValue(interactable, NOW)	
	return (
		sm.exists(interactable) and (
			sm.interactable.values[interactable.id] and (
				sm.interactable.values[interactable.id][1] and 
				(sm.interactable.values[interactable.id][1].tick < sm.game.getCurrentTick() or NOW) and 
				sm.interactable.values[interactable.id][1].value[1] or 
				sm.interactable.values[interactable.id][2]
			)
		)
		or nil
	)
end

table.insert(sm.scrap_essentials, function(self)
	self.interactable.setValue = sm.interactable.setValue
	self.interactable.getValue = sm.interactable.getValue
end)

local version = 1.0

-- Required:
	-- sm.wireless.update() - add at the start of onFixedUpdate()

-- Prefix: sm.wireless.

-- Commands:

	-- addParent(interactable, frequency) --Adds a specific interactable to a specific frequency as parent
	-- deleteParent(interactable, frequency) --Deletes a specific interactable from a specific frequency
	-- (There can be only 1 parent on 1 frequency at a time)

	-- addChild(interactable, frequency) --Adds a specific interactable to a specific frequency as child
	-- deleteChild(interactable, frequency) --Deletes a specific interactable from a specific frequencys

	-- clearFrequencyParent(frequency) --Deletes the parent of a specified frequency
	-- clearFrequencyChildren(frequency) --Deletes all the children of a specified frequency
	-- clearFrequency(frequency) --Deletes both parent and children of a specified frequency

	-- frequencyCheckParents(frequency) --Checks if a frequency has a parent
	-- frequencyCheckChildren(frequency) --Checks if a frequency has any children

	-- clearInteractableParents(interactable) --Deletes all sm.wireless connections from an interactable, where it is a parent
	-- clearInteractableChildren(interactable) --Deletes all sm.wireless connections from an interactable, where it is a child
	-- clearInteractable(interactable) --Deletes all sm.wireless connections from an interactable

	-- interactableCheckParents(interactable) --Checks if an interactable is a parent on any frequency
	-- interactableCheckChildren(interactable) --Checks if an interactable is a child on any frequency





--[[
	Copyright (c) 2019 Scrap Essentials Team
]]--

-- Version check
if sm.__SE_Version.wireless and version <= sm.__SE_Version.wireless then return end



-- WIRELESS TABLE
if not sm.wireless then sm.wireless = {} end
local frequencies = {}
local interactables = {}
local delete_buffer = {}
local add_buffer = {}
local last_tick = 0

-- GETS EXECUTED AT THE START OF EACH TICK
function sm.wireless.update()
	local tick = sm.game.getCurrentTick()
	if(last_tick < tick) then
		for i, data in pairs(delete_buffer) do
			data.type(data.interactable, data.frequency)
		end
		for i, data in pairs(add_buffer) do
			data.type(data.interactable, data.frequency)
		end
		delete_buffer = {}
		add_buffer = {}
		last_tick = tick
	end
end

-- BUFFER FUNCTIONS
local AP = function(interactable, frequency)
	if(not sm.wireless.frequencyCheckParent(frequency)) then
		if(not frequencies[frequency]) then frequencies[frequency] = {} end
		frequencies[frequency].parent = interactable
		if not interactables[interactable.id] then interactables[interactable.id] = {} end
		if not interactables[interactable.id].parents then interactables[interactable.id].parents = {} end
		interactables[interactable.id].parents[frequency] = true
	end
end
local DP = function(interactable, frequency)
	if(sm.wireless.frequencyCheckParent(frequency)) then
		if(frequencies[frequency].parent.id == interactable.id) then
			frequencies[frequency].parent = nil
			if(not sm.wireless.frequencyCheckChildren(frequency)) then -- delete frequency
				frequencies[frequency] = nil
			end
			interactables[interactable.id].parents[frequency] = nil
			if(not sm.wireless.interactableCheckParents(interactable)) then -- delete parents
				interactables[interactable.id].parents = nil
				if(not sm.wireless.interactableCheckChildren(interactable)) then -- delete interactable
					interactables[interactable.id] = nil
				end
			end
		end
	end
end
local AC = function(interactable, frequency)
	if((not interactables[interactable.id])or(not interactables[interactable.id].children)or(interactables[interactable.id].children[frequency] ~= true)) then
		if(not frequencies[frequency]) then frequencies[frequency] = {} end
		if(not frequencies[frequency].children) then frequencies[frequency].children = {} end
		table.insert(frequencies[frequency].children, interactable)
		if not interactables[interactable.id] then interactables[interactable.id] = {} end
		if not interactables[interactable.id].children then interactables[interactable.id].children = {} end
		interactables[interactable.id].children[frequency] = true
	end
end
local DC = function(interactable, frequency)
	if((interactables[interactable.id])and(interactables[interactable.id].children)and(interactables[interactable.id].children[frequency])) then
		local flag = false
		for i, child in pairs(frequencies[frequency].children) do
			if(not flag) then
				if(child.id == interactable.id) then
					frequencies[frequency].children[i] = nil
					if((not sm.wireless.frequencyCheckChildren(frequency))and(not sm.wireless.frequencyCheckParent(frequency))) then -- delete frequency
						frequencies[frequency] = nil
					end
					interactables[interactable.id].children[frequency] = nil
					if(not sm.wireless.interactableCheckChildren(interactable)) then -- deleting children
						interactables[interactable.id].children = nil
						if(not sm.wireless.interactableCheckParents(interactable)) then -- deleting interactable
							interactables[interactable.id] = nil
						end
					end
					flag = true
				end
			else -- shifting children
				frequencies[frequency].children[i-1] = frequencies[frequency].children[i]
				frequencies[frequency].children[i] = nil
			end
		end
	end
end

-- ADD PARENT IN FREQUENCY
function sm.wireless.addParent(interactable, frequency)
	assert(type(interactable) == "Interactable", "addParent: interactable, Interactable expected! got: "..type(interactable))
	assert(type(frequency) == "number", "addParent: frequency, number expected! got: "..type(frequency))
	local data = {}
	data.interactable = interactable
	data.frequency = frequency
	data.type = AP
	table.insert(add_buffer, data)
end

-- DELETE PARENT FROM FREQUENCY
function sm.wireless.deleteParent(interactable, frequency)
	assert(type(interactable) == "Interactable", "deleteParent: interactable, Interactable expected! got: "..type(interactable))
	assert(type(frequency) == "number", "deleteParent: frequency, number expected! got: "..type(frequency))
	local data = {}
	data.interactable = interactable
	data.frequency = frequency
	data.type = DP
	table.insert(delete_buffer, data)
end

-- ADD CHILD IN FREQUENCY
function sm.wireless.addChild(interactable, frequency)
	assert(type(interactable) == "Interactable", "addChild: interactable, Interactable expected! got: "..type(interactable))
	assert(type(frequency) == "number", "addChild: frequency, number expected! got: "..type(frequency))
	local data = {}
	data.interactable = interactable
	data.frequency = frequency
	data.type = AC
	table.insert(add_buffer, data)
end

-- DELETE CHILD FROM FREQUENCY
function sm.wireless.deleteChild(interactable, frequency)
	assert(type(interactable) == "Interactable", "deleteChild: interactable, Interactable expected! got: "..type(interactable))
	assert(type(frequency) == "number", "deleteChild: frequency, number expected! got: "..type(frequency))
	local data = {}
	data.interactable = interactable
	data.frequency = frequency
	data.type = DC
	table.insert(delete_buffer, data)
end

-- CHECK FOR PARENT (object) ON FREQUENCY
function sm.wireless.frequencyCheckParent(frequency)
	assert(type(frequency) == "number", "frequencyCheckParent: frequency, number expected! got: "..type(frequency))
	if((frequencies[frequency])and(frequencies[frequency].parent)) then
		return true
	else
		return false
	end
end

-- CHECK FOR CHILDREN (object) OF FREQUENCY
function sm.wireless.frequencyCheckChildren(frequency)
	assert(type(frequency) == "number", "frequencyCheckChildren: frequency, number expected! got: "..type(frequency))
	if((frequencies[frequency])and(frequencies[frequency].children)) then
		for a, b in pairs(frequencies[frequency].children) do
			return true
		end
		return false
	else
		return false
	end
end

-- CHECK FOR PARENT (property) OF INTERACTABLE
function sm.wireless.interactableCheckParents(interactable)
	assert(type(interactable) == "Interactable", "interactableCheckParents: interactable, Interactable expected! got: "..type(interactable))
	if((interactables[interactable.id])and(interactables[interactable.id].parents)) then
		for a, b in pairs(interactables[interactable.id].parents) do
			return true
		end
	end
	return false
end

-- CHECK FOR CHILD (property) OF INTERACTABLE
function sm.wireless.interactableCheckChildren(interactable)
	assert(type(interactable) == "Interactable", "interactableCheckChildren: interactable, Interactable expected! got: "..type(interactable))
	if((interactables[interactable.id])and(interactables[interactable.id].children)) then
		for a, b in pairs(interactables[interactable.id].children) do
			return true
		end
	end
	return false
end

-- CLEAR PARENT IN FREQUENCY (delete frequencies' parent)
function sm.wireless.clearFrequencyParent(frequency)
	assert(type(frequency) == "number", "clearFrequencyParent: frequency, number expected! got: "..type(frequency))
	if(sm.wireless.frequencyCheckParent(frequency)) then
		local interactable = frequencies[frequency].parent
		sm.wireless.deleteParent(interactable, frequency)
		return true -- parent cleared
	end
	return false -- parent not occupied
end

-- CLEAR CHILDREN IN FREQUENCY (delete frequencies' children)
function sm.wireless.clearFrequencyChildren(frequency)
	assert(type(frequency) == "number", "clearFrequencyChildren: frequency, number expected! got: "..type(frequency))
	if(sm.wireless.frequencyCheckChildren(frequency)) then
		for i, interactable in pairs(frequencies[frequency].children) do
			sm.wireless.deleteChild(interactable, frequency)
		end
		return true -- children cleared
	end
	return false -- no children
end

-- CLEAR FREQUENCY
function sm.wireless.clearFrequency(frequency)
	assert(type(frequency) == "number", "clearFrequency: frequency, number expected! got: "..type(frequency))
	if(frequencies[frequency]) then
		local flag = sm.wireless.clearFrequencyParent(frequency)
		flag = sm.wireless.clearFrequencyChildren(frequency)
		return true -- frequency cleared
	end
	return false -- no frequency
end

-- CLEAR PARENT FOR INTERACTABLE (delete interactable as parent in its' frequencies)
function sm.wireless.clearInteractableParents(interactable)
	assert(type(interactable) == "Interactable", "clearInteractableParents: interactable, Interactable expected! got: "..type(interactable))
	if(sm.wireless.interactableCheckParents(interactable)) then
		local table1 = table.copyTable(interactables[interactable.id].parents)
		for frequency, b in pairs(table1) do
			sm.wireless.deleteParent(interactable, frequency)
		end
		return true -- interactable (as) parents cleared
	end
	return false -- interactable is not a parent
end

-- CLEAR CHILD FOR INTERACTABLE (delete interactable as child in its' frequencies)
function sm.wireless.clearInteractableChildren(interactable)
	assert(type(interactable) == "Interactable", "clearInteractableChildren: interactable, Interactable expected! got: "..type(interactable))
	if(sm.wireless.interactableCheckChildren(interactable)) then
		local table1 = table.copyTable(interactables[interactable.id].children)
		for frequency, b in pairs(table1) do
			sm.wireless.deleteChild(interactable, frequency)
		end
		return true -- interactable (as) children cleared
	end
	return false -- interactable is not a child
end

-- CLEAR INTERACTABLE
function sm.wireless.clearInteractable(interactable)
	assert(type(interactable) == "Interactable", "clearInteractable: interactable, Interactable expected! got: "..type(interactable))
	if(interactables[interactable.id]) then
		sm.wireless.clearInteractableParents(interactable)
		sm.wireless.clearInteractableChildren(interactable)
		return true -- interactable cleared
	end
	return false -- no interactable
end

-- FREQUENCY GET PARENT
function sm.wireless.frequencyGetParent(frequency)
	if frequencies[frequency] then
		return frequencies[frequency].parent
	end
end

-- FREQUENCY GET CHILDREN
function sm.wireless.frequencyGetChildren(frequency)
	if frequencies[frequency] then
		return frequencies[frequency].children
	else
		return {}
	end
end

-- INTERACTABLE GET PARENTS
function sm.wireless.interactableGetParents(interactable)
	if interactables[interactable.id] then
		return interactables[interactable.id].parents
	end
end

-- INTERACTABLE GET CHILDREN
function sm.wireless.interactableGetChildren(interactable)
	if interactables[interactable.id] then
		return interactables[interactable.id].children
	else
		return {}
	end
end

-- PRINT FREQUENCY NETWORK STATUS (all frequencies, parent and amount of children; for debuging)
function sm.wireless.printFNS(frequency)
	assert(type(frequency) == "number", "printFNS: frequency, number expected! got: "..type(frequency))
	local table1 = frequencies[frequency]
	if(table1) then		
		local text = "Frequency: " .. tostring(frequency) .. ", Parent: "
		if(table1.parent) then
			text = text .. "1"
		else
			text = text .. "0"
		end
		text = text .. ", Children: " .. tostring(table.length(table1.children)) .. "."
		print(text)
	end
end

-- PRINT INTERACTABLE NETWORK STATUS (all frequencies where interactable is a parent or child; for debuging)
function sm.wireless.printINS(id)
	assert(type(id) == "number", "printINS: id, number expected! got: "..type(id))
	local table1 = interactables[id]
	if table1 then
		local parents = table1.parents and table.length(table1.parents) or 0
		local children = table1.children and table.length(table1.children) or 0
		local text = "ID: " .. tostring(id) .. ", Parent of: " .. tostring(parents) .. ", Child of: " .. tostring(children) .. " frequencies."
		print(text)
	end
end



sm.__SE_Version.wireless = version
print("'wireless' library version "..tostring(version).." successfully loaded.")
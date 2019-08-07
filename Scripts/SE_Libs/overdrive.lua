local version = 1.0

-- Required:
	-- self.overdrive = sm.overdrive.create(self, action, properties) -- put at the start of server_onCreate(self)
	-- self.overdrive:start(interactable) -- put at the start of server_onFixedUpdate(self)
	-- self.overdrive:destroy(interactable) -- put at the start of server_onDestroy(self)

-- Other:
	-- self.overdrive:getAllParents(self) -- table of all parents
	-- self.overdrive:getAllChildren(self) -- table of all children
	-- self.overdrive:getInputs(parents) -- table: [parent.id] = value
	-- self.overdrive:getSortedInputs(parents) -- table: [value_typeype][input_typeype][naturalIncrement] = value
	-- self.overdrive:setValue(self, value) -- sets all known value functions based on supplied value (setActive, setPower, setValue)





--[[
	Copyright (c) 2019 Scrap Essentials Team
]]--

-- Version check
if sm.__SE_Version.overdrive and version <= sm.__SE_Version.overdrive then return end



if not sm.overdrive then sm.overdrive = {} end
local objects = {}
local last_tick = 0

function sm.overdrive.create(self, properties)
	local instance = {}

	-- CONSTRUCTOR
	properties = properties or {}
	objects[self.interactable.id] = {}
	objects[self.interactable.id].self = self
	objects[self.interactable.id].properties = {}
	for i, v in pairs(properties) do
		objects[self.interactable.id].properties[v] = true
	end

	local function calculate(interactable)
		assert(objects[interactable.id].self.server_onOverdrive ~= nil, "server_onOverdrive doesn't exist.")
		objects[interactable.id].self:server_onOverdrive()
		sm.overdrive.calculated[interactable.id] = true
	end

	local function continue(interactable)
		-- EXECUTE CODE IF ALL OVERDRIVE PARENTS ARE CALCULATED
		local execute = true
		for i, parent in pairs(objects[interactable.id].parents) do
			if (not sm.overdrive.calculated[parent.id])and(not objects[parent.id].properties["delay"]) then
				execute = false
			end
		end

		if execute then
			calculate(interactable)
			-- COMMAND CHILDREN TO EXECUTE THEMSELVES
			for id, child in pairs(objects[interactable.id].children) do
				if not sm.overdrive.calculated[child.id] then
					continue(child)
				end
			end
		end
	end

	function instance.getAllParents(self, data)
		-- GETS ALL PARENTS
		local parents = {}
		if not objects[data.interactable.id].properties["noWiredParents"] then
			table.addToTable(parents, data.interactable:getParents())
		end
		if objects[data.interactable.id].properties["wirelessParents"] then
			if(sm.wireless.interactableCheckChildren(data.interactable)) then
				for frequency, _ in pairs(sm.wireless.interactableGetChildren(data.interactable)) do
					if(sm.wireless.frequencyCheckParent(frequency)) then
						table.insert(parents, sm.wireless.frequencyGetParent(frequency))
					end
				end
			end
		end
		return parents
	end

	function instance.getAllChildren(self, data)
		-- GETS ALL CHILDREN
		local children = {}
		if not objects[data.interactable.id].properties["noWiredChildren"] then
			table.addToTable(children, data.interactable:getChildren())
		end
		if objects[data.interactable.id].properties["wirelessChildren"] then
			if(sm.wireless.interactableCheckParents(data.interactable)) then
				for frequency, _ in pairs(sm.wireless.interactableGetParents(data.interactable)) do
					if(sm.wireless.frequencyCheckChildren(frequency)) then
						table.addToTable(children, sm.wireless.frequencyGetChildren(frequency))
					end
				end
			end
		end
		return children
	end

	local function getParents(interactable)
		-- GETS ALL OVERDRIVE PARENTS
		local all_parents = {}
		if not objects[interactable.id].properties["noWiredParents"] then
			table.addToTable(all_parents, interactable:getParents())
		end
		if objects[interactable.id].properties["wirelessParents"] then
			if(sm.wireless.interactableCheckChildren(interactable)) then
				for frequency, _ in pairs(sm.wireless.interactableGetChildren(interactable)) do
					if(sm.wireless.frequencyCheckParent(frequency)) then
						table.insert(all_parents, sm.wireless.frequencyGetParent(frequency))
					end
				end
			end
		end
		local parents = {}
		for i, parent in pairs(all_parents) do
			if objects[parent.id] then
				table.insert(parents, parent)
			end
		end
		return parents
	end

	local function getChildren(interactable)
		-- GETS ALL OVERDRIVE CHILDREN
		local all_children = {}
		if not objects[interactable.id].properties["noWiredChildren"] then
			table.addToTable(all_children, interactable:getChildren())
		end
		if objects[interactable.id].properties["wirelessChildren"] then
			if(sm.wireless.interactableCheckParents(interactable)) then
				for frequency, _ in pairs(sm.wireless.interactableGetParents(interactable)) do
					if(sm.wireless.frequencyCheckChildren(frequency)) then
						table.addToTable(all_children, sm.wireless.frequencyGetChildren(frequency))
					end
				end
			end
		end
		local children = {}
		for i, child in pairs(all_children) do
			if objects[child.id] then
				table.insert(children, child)
			end
		end
		return children
	end

	local function onTickStart()
		-- GETS CALLED AT THE START OF EACH TICK (IF OVERDRIVE BLOCKS ARE PLACED)
		sm.overdrive.calculated = {}
		for id, object in pairs(objects) do
			objects[object.self.interactable.id].children = getChildren(object.self.interactable)
			objects[object.self.interactable.id].parents = getParents(object.self.interactable)
		end
	end

	function instance.start(self, data)
		-- ONLY CALLED AT THE START OF THE TICK
		local tick = sm.game.getCurrentTick()
		if last_tick < tick then
			onTickStart()
			last_tick = tick
		end

		-- ONLY GETS CALLED IF FIRST IN CHAIN
		-- parents are only overdrive parents
		local start = true
		for i, parent in pairs(objects[data.interactable.id].parents) do
			if not objects[parent.id].properties["delay"] then
				start = false
				break
			end
		end
		if start then
			continue(data.interactable)
		end
	end

	function instance.destroy(self, data)
		-- ANTI MEMORY LEAK
		objects[data.interactable.id] = nil
	end

	function instance.getInputs(self, parents)
		-- TABLE OF INPUTS
		local inputs = {}
		for i, parent in pairs(parents) do
			local value
			local parent_type = parent:getType()
			if objects[parent.id] then
				if objects[parent.id].properties["delay"] then
					value = parent:getValue()
				else
					value = parent:getValue(true)
				end
			elseif parent_type == "scripted" then
				value = parent:getPower()
			elseif parent_type == "logic" or parent_type == "timer" or parent_type == "button" or parent_type == "lever" or parent_type == "sensor" then
				value = parent:isActive()
			else
				value = parent
			end

			inputs[parent.id] = value
		end
		return inputs
	end

	function instance.get10SortedInputs(self, parents)
		-- SORTS INPUTS INTO: VALUE_TYPE, INPUT_TYPE, NATURAL_INCREMENT, VALUE
		local inputs = {}
		for i, parent in pairs(parents) do
			local value
			local parent_type = parent:getType()
			if objects[parent.id] then
				if objects[parent.id].properties["delay"] then
					value = parent:getValue()
				else
					value = parent:getValue(true)
				end
			elseif parent:getType() == "scripted" then
				value = parent:getPower()
			elseif parent_type == "logic" or parent_type == "timer" or parent_type == "button" or parent_type == "lever" or parent_type == "sensor" then
				value = parent:isActive()
			else
				value = parent
			end

			local value_type = type(value)
			if value_type == "Interactable" then
				value_type = value:getType()
			end
			local input_type = ((sm.color.match(parent.shape.color) - 1) % 10) + 1 or 1
			if not inputs[value_type] then inputs[value_type] = {} end
			if not inputs[value_type][input_type] then inputs[value_type][input_type] = {} end
			table.insert(inputs[value_type][input_type], value)
		end
		return inputs
	end

	function instance.get40SortedInputs(self, parents)
		-- SORTS INPUTS INTO: VALUE_TYPE, INPUT_TYPE, NATURAL_INCREMENT, VALUE
		local inputs = {}
		for i, parent in pairs(parents) do
			local value
			local parent_type = parent:getType()
			if objects[parent.id] then
				if objects[parent.id].properties["delay"] then
					value = parent:getValue()
				else
					value = parent:getValue(true)
				end
			elseif parent:getType() == "scripted" then
				value = parent:getPower()
			elseif parent_type == "logic" or parent_type == "timer" or parent_type == "button" or parent_type == "lever" or parent_type == "sensor" then
				value = parent:isActive()
			else
				value = parent
			end

			local value_type = type(value)
			if value_type == "Interactable" then
				value_type = value:getType()
			end
			local input_type = sm.color.match(parent.shape.color)
			if not inputs[value_type] then inputs[value_type] = {} end
			if not inputs[value_type][input_type] then inputs[value_type][input_type] = {} end
			table.insert(inputs[value_type][input_type], value)
		end
		return inputs
	end

	function instance.setValue(self, data, in_value)
		-- SETS VALUE, POWER AND ACTIVE
		-- REFERENCE PROTECTION
		local value_type = type(in_value)
		local value
		if(value_type == "Vec3") then
			value = in_value:copy()
		elseif(value_type == "table") then
			value = table.copyTable(in_value)
		else
			value = in_value
		end
		-- VALUE
		data.interactable:setValue(value)
		-- POWER
		if type(value) == "number" then
			if math.abs(value) < 3.4 * 10^38 then
				data.interactable:setPower(value)
			else
				data.interactable:setPower(0)
			end
		-- ACTIVE
		elseif value then
			data.interactable:setActive(true)
			data.interactable:setPower(1)
		else
			data.interactable:setActive(false)
			data.interactable:setPower(0)
		end
	end

	function instance.setProperties(self, data, properties)
		properties = properties or {}
		objects[data.interactable.id].properties = {}
		for i, v in pairs(properties) do
			objects[data.interactable.id].properties[v] = true
		end
	end

	return instance
end



sm.__SE_Version.overdrive = version
print("'overdrive' library version "..tostring(version).." successfully loaded.")
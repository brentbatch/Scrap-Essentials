local version = 1

if (sm.__SE_Version._Interactable or 0) >= version then return end
sm.__SE_Version._Interactable = version

print("Loading extra interactable functions")

-- SERVER:

local values = {} -- <<not directly accessible for other scripts
function sm.interactable.setValue(interactable, ...)
	local currenttick = sm.game.getCurrentTick()
	values[interactable.id] = {
		{tick = currenttick, value = {...}},
		values[interactable.id] and (    
			values[interactable.id][1] ~= nil and 
			(values[interactable.id][1].tick < currenttick) and 
			values[interactable.id][1].value or 
			values[interactable.id][2]
		) 
		or nil
	}
end
function sm.interactable.getValue(interactable, NOW)
	if sm.exists(interactable) and values[interactable.id] then
		if values[interactable.id][1] and (values[interactable.id][1].tick < sm.game.getCurrentTick() or NOW) then
			return unpack(values[interactable.id][1].value)
		elseif values[interactable.id][2] then
			return unpack(values[interactable.id][2])
		end
	end
	return nil, nil
end

function sm.interactable.isNumberType(interactable)
	return (interactable:getType() == "scripted" and tostring(interactable:getShape().shapeUuid) ~= "6f2dd83e-bc0d-43f3-8ba5-d5209eb03d07"  --[[tickbutton]])
end


table.insert(
	sm.__SE_UserDataImprovements_Server, 
	function(self)
		self.interactable.setValue = sm.interactable.setValue
		self.interactable.getValue = sm.interactable.getValue
		self.interactable.isNumberType = sm.interactable.isNumberType
	end
)





-- client:

---[[
local uvs = {} -- <<not directly accessible for other scripts
local __OLD_setUvFrameIndex = sm.interactable.setUvFrameIndex
function sm.interactable.setUvFrameIndex(interactable, value)  
	local currenttick = sm.game.getCurrentTick()
	__OLD_setUvFrameIndex(interactable, value)
	uvs[interactable.id] = {
		{tick = currenttick, value = {value}}, 
		uvs[interactable.id] and (    
			uvs[interactable.id][1] ~= nil and 
			(uvs[interactable.id][1].tick < currenttick) and 
			uvs[interactable.id][1].value or 
			uvs[interactable.id][2]
		) 
		or nil
	}
end

local __OLD_getUvFrameIndex = sm.interactable.getUvFrameIndex
function sm.interactable.getUvFrameIndex(interactable)
	if sm.exists(interactable) and uvs[interactable.id] then
		if uvs[interactable.id][1] and uvs[interactable.id][1].tick < sm.game.getCurrentTick() then
			return uvs[interactable.id][1].value[1]
		elseif uvs[interactable.id][2] then
			return uvs[interactable.id][2][1]
		end
	end
	return __OLD_getUvFrameIndex(interactable)
end


local glows = {} -- <<not directly accessible for other scripts
local __OLD_setGlowMultiplier = sm.interactable.setGlowMultiplier
function sm.interactable.setGlowMultiplier(interactable, value)  
	local currenttick = sm.game.getCurrentTick()
	__OLD_setGlowMultiplier(interactable, value)
	glows[interactable.id] = {
		{tick = currenttick, value = {value}}, 
		glows[interactable.id] and (    
			glows[interactable.id][1] ~= nil and 
			(glows[interactable.id][1].tick < currenttick) and 
			glows[interactable.id][1].value or 
			glows[interactable.id][2]
		) 
		or nil
	}
end

local __OLD_getGlowMultiplier = sm.interactable.getGlowMultiplier
function sm.interactable.getGlowMultiplier(interactable)
	if sm.exists(interactable) and glows[interactable.id] then
		if glows[interactable.id][1] and glows[interactable.id][1].tick < sm.game.getCurrentTick() then
			return glows[interactable.id][1].value[1]
		elseif glows[interactable.id][2] then
			return glows[interactable.id][2][1]
		end
	end
	return __OLD_getGlowMultiplier(interactable)
end

table.insert(
	sm.__SE_UserDataImprovements_Client, 
	function(self)
		self.interactable.setUvFrameIndex = sm.interactable.setUvFrameIndex
		self.interactable.getUvFrameIndex = sm.interactable.getUvFrameIndex
		self.interactable.setGlowMultiplier = sm.interactable.setGlowMultiplier
		self.interactable.getGlowMultiplier = sm.interactable.getGlowMultiplier
	end
)
--]]
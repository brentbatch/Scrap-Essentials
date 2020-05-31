--[[
	Copyright (c) 2019 Scrap Essentials Team
]]--


local classO = class
function class(...) -- multi-class inheritance, by Brent Batch
	local klass = {}
	for _, super in pairs({...}) do
		for k, v in pairs(super) do
			klass[k] = v
		end
	end
	return classO(klass)
end

sm.checkDev = sm.checkDev or function(shape)   -- a '-dev' check by Brent Batch
	if sm.isDev ~= nil then return sm.isDev end
	if lastLoaded == 1 then -- on world init dev check
		sm.isDev = true
		--print('set dev mode to: ', sm.isDev)
		return true
	end
	sm.shape.createPart( shape.shapeUuid, sm.vec3.new(705,0,0), sm.quat.identity( ), false, false )
	sm.isDev = DebuggerLoads == 1
	--print('set dev mode to: ', sm.isDev)
	return sm.isDev
end 

function se.isModder()  -- an 'is a known modder' check by Brent Batch
	if sm.game.getCurrentTick() > 0 then 
		local modders = {["Brent Batch"] = true, ["TechnologicNick"] = true, ["MJM"] = true, ["Mini"] = true, ["YT_BlueFlame"] = true} 
		local name = sm.player.getAllPlayers()[1].name 
		if modders[name] then 
			function se.isModder() return true end 
			return true 
		else 
			function se.isModder() return false end 
			return false 
		end
	end
end
	
function modPrint(...)  -- print that only works for the team.
	if se.isModder() then 
		print(...) 
	end 
end

function devPrint(...)  -- print that only works in '-dev' mode  (requires a part to do 'sm.checkDev(shape)' on server side
	if sm.isDev then 
		print(...) 
	end 
end

local printO = print
function print(...) -- fancy print by TechnologicNick
	if se.isModder() then
		printO("[" .. sm.game.getCurrentTick() .. "]", sm.isServerMode() and "[Server]" or "[Client]", ...)
	else
		printO(...)
	end
end


modPrint('Loading Libs/Debugger.lua')
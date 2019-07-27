--[[
	Copyright (c) 2019 Scrap Essentials Team
	
	
	Modification notice:
	- Notify the Scrap Essentials Team when modifying any library file!
	- You can change which libraries get loaded by modifying this file and commenting out 'dofile' lines.
	
	
]]--

-- Scrap Essentials Loader v1.1


-- required by Debugger.lua, don't touch: --
lastLoaded = sm.game.getCurrentTick()
DebuggerLoads = (DebuggerLoads or 0) + 1
-- don't move relative position of this code --


if __SE_Loaded then return end
__SE_Loaded = true
print("Loading Scrap Essentials Libraries")

se = se or {} -- single mod env

sm.__SE_UserDataImprovements_Server = {} -- game env (cross mod)
sm.__SE_UserDataImprovements_Client = {} -- game env (cross mod)

sm.__SE_Version = sm.__SE_Version or {}

dofile "SE_Libs/Debugger.lua"

dofile "SE_Libs/body.lua"
dofile "SE_Libs/color.lua"
dofile "SE_Libs/interactable.lua" -- only load when you need it
dofile "SE_Libs/math.lua"
dofile "SE_Libs/physics.lua"
dofile "SE_Libs/physics.lua"
dofile "SE_Libs/player.lua"
dofile "SE_Libs/table.lua"
dofile "SE_Libs/vec3.lua"
dofile "SE_Libs/globalgui.lua" -- only load when you need it

--dofile "SE_Libs/player.lua" -- only load when you need it


function sm.ImproveUserData_Server(self)
	function sm.ImproveUserData_Server(self) end -- 'remove' function to prevent multiple loads
	for k, improvement in pairs(sm.__SE_UserDataImprovements_Server or {}) do
		improvement(self)
	end
	sm.__SE_UserDataImprovements_Server = {}
end

function sm.ImproveUserData_Client(self)
	function sm.ImproveUserData_Server(self) end -- 'remove' function to prevent multiple loads
	for k, improvement in pairs(sm.__SE_UserDataImprovements_Client or {}) do
		improvement(self)
	end
	sm.__SE_UserDataImprovements_Client = {}
end


print('══════════════════════════════════════════')
print('═══   Scrap Essentials By Awesome Modders   ═══')
print('══════════════════════════════════════════')
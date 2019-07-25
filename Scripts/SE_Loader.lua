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


if __SE_Loaded == true then return end
__SE_Loaded = true

se = se or {} -- single mod env

sm.__SE_UserDataImprovements_Server = {} -- game env (cross mod)
sm.__SE_UserDataImprovements_Client = {} -- game env (cross mod)

sm.__SE_Version = sm.__SE_Version or {}

dofile "Libs/Debugger.lua"

dofile "Libs/Body.lua"
dofile "Libs/Color.lua"
dofile "Libs/Interactable.lua" -- only load when you need it
dofile "Libs/Math.lua"
dofile "Libs/Physics.lua"
dofile "Libs/Physics.lua"
dofile "Libs/Player.lua"
dofile "Libs/Table.lua"
dofile "Libs/Vec3.lua"

--dofile "Libs/player.lua" -- only load when you need it


function sm.ImproveUserData_Server(self)
	function sm.ImproveUserData_Server(self) end -- 'remove' function to prevent multiple loads
	for k, improvement in pairs(sm.__SE_UserDataImprovements_Server or {}) do
		improvement(self)
	end
end

function sm.ImproveUserData_Client(self)
	function sm.ImproveUserData_Server(self) end -- 'remove' function to prevent multiple loads
	for k, improvement in pairs(sm.__SE_UserDataImprovements_Client or {}) do
		improvement(self)
	end
end


print('══════════════════════════════════════════')
print('═══   Scrap Essentials By Awesome Modders   ═══')
print('══════════════════════════════════════════')
function debugmode() if sm.game.getCurrentTick() > 1 and not sm.isServerMode() then local modders = {["Mini"] = true, ["Brent Batch"] = true, ["TechnologicNick"] = true} local name = sm.localPlayer.getPlayer().name if modders[name] then function debugmode() return true end return true else function debugmode() return false end return false end end end

function debug(...) if debugmode() then print(...) end end
function info(...) if debugmode() then info(...) end end
if not printO then
    printO = print
end
function print(...)
	if debugmode() then
		printO("[" .. sm.game.getCurrentTick() .. "]", sm.isServerMode() and "[Server]" or "[Client]", ...)
	else
		printO(...)
	end
end


--ScrapEssentials.lua:

if sm.scrapEssentialsLoaded == true then return end
sm.scrapEssentialsLoaded = true -- prevents loading this file multiple times --> move to version controll
sm.scrap_essentials = {}

dofile "ScrapEssentials/globalgui.lua"
dofile "ScrapEssentials/vec3.lua"
dofile "ScrapEssentials/body.lua"
dofile "ScrapEssentials/math.lua"
dofile "ScrapEssentials/table.lua"
dofile "ScrapEssentials/player.lua"
dofile "ScrapEssentials/color.lua"
dofile "ScrapEssentials/toolHack.lua" -- requires globalgui
dofile "ScrapEssentials/physics.lua"
--dofile "ScrapEssentials/interactable.lua"


function sm.load_essentials(self) -- add :func() options to stuff on server functions
	sm.load_essentials = function(e) end -- destroy func to prevent multiple times of loading this
	for k, func in pairs(sm.scrap_essentials) do
		func(self)
	end
end

print('══════════════════════════════════════════')
print('═══   Scrap Essentials By Brent Batch & Mini   ═══')
print('══════════════════════════════════════════')
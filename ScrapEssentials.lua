
if(sm.localPlayer.getPlayer().name == "Mini" or sm.localplayer.getPlayer().name == "Brent Batch") then
    if true then
        function debug(...)
            print(...)
        end
    end

    if true then
        function info(...)
            print(...)
        end
    end
else
    function debug() end
    function info() end
end

--ScrapEssentials.lua:

if sm.scrapEssentialsLoaded == true then return end
sm.scrapEssentialsLoaded = true -- prevents loading this file multiple times
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
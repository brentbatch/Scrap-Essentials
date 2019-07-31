dofile "SE_Loader.lua"


-- the following code prevents re-load of this file, except if in '-dev' mode.  -- fixes broken sh*t by devs.
if guiExample_optionMenu and not sm.isDev then -- increases performance for non '-dev' users.
	return -- perform sm.checkDev(shape) in server_onCreate to set sm.isDev
end


guiExample_optionMenu = class(guiClass) -- important !
guiExample_optionMenu.maxChildCount = -1
guiExample_optionMenu.maxParentCount = -1
guiExample_optionMenu.connectionInput = sm.interactable.connectionType.logic
guiExample_optionMenu.connectionOutput = sm.interactable.connectionType.logic -- none, logic, power, bearing, seated, piston, any
guiExample_optionMenu.colorNormal = sm.color.new(0xdf7000ff)
guiExample_optionMenu.colorHighlight = sm.color.new(0xef8010ff)

function guiExample_optionMenu.server_onCreate( self )
	guiExample_optionMenu:createRemote(self) -- create remote shape to handle all gui stuff, only one remote shape will exist at a time.
end


function guiExample_optionMenu.client_onCreate( self )
	
end

function guiExample_optionMenu.client_onSetupGui( self )
	if self:wasCreated(guiExample_optionMenu.GUI) then return end -- only allow remote shape to create a gui

	guiExample_optionMenu.GUI = GlobalGUI.create(self, "GUI - TEST - OPTIONMENU", 800, 600)
	
	local bgx, bgy = guiExample_optionMenu.GUI.bgPosX , guiExample_optionMenu.GUI.bgPosY

	


	--guiExample_optionMenu.GUI:addItemWithId("tabControl1", menu1) -- !!! add the items to menu1 first before adding menu1 to the gui !!!!!!
end



function guiExample_optionMenu.client_onInteract(self)
	if not guiExample_optionMenu.GUI then print("Failed to open GUI") end

	guiExample_optionMenu.GUI:show(self)
end

function guiExample_optionMenu.client_onDestroy(self)
	if guiExample_optionMenu.GUI then guiExample_optionMenu.GUI:setVisible(false, true) end -- sets gui invisible without showing messages (displayalert)
	-- it is possible to not hide the gui(if it is open) when the block is broken, all callbacks that use self(the instance of this broken block) will cause errors tho.
end

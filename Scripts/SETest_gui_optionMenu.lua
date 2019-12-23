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
	
	self.settings = { gravity = 10, someOption = 0 } or self.storage:load()
	
	sm.physics.setGravity( self.settings.gravity )
end

function guiExample_optionMenu.server_SendModeToClients(self, newSettings)
	if newSettings then 
		sm.physics.setGravity(newSettings.gravity)
		self.settings = newSettings
		self.storage:save(self.settings) -- save to storage, can be loaded after part is loaded from lift or on world reload.
	end
	self.network:sendToClients("client_changeMode", self.settings)
end





function guiExample_optionMenu.client_onCreate( self )
	self.client_settings = {
		gravity = 10,
		someOption = 0
	}
	self.network:sendToServer("server_SendModeToClients") -- "request mode from server"
end

function guiExample_optionMenu.client_changeMode(self, newSettings)
	self.client_settings = newSettings

	if guiExample_optionMenu.GUI and guiExample_optionMenu.GUI.visible then
		guiExample_optionMenu.GUI:show(self) -- run all the 'on_show' callbacks again so your client gets updated item values from another client that updated the mode.
	end
end

function guiExample_optionMenu.client_onSetupGui( self )
	if self:wasCreated(guiExample_optionMenu.GUI) then return end -- only allow remote shape to create a gui

	guiExample_optionMenu.GUI = GlobalGUI.create(self, "GUI - TEST - OPTIONMENU", 600, 800)
	
	local bgx, bgy = guiExample_optionMenu.GUI.bgPosX , guiExample_optionMenu.GUI.bgPosY


	local optionmenu_on_show_functions = {}
	local optionmenu = GlobalGUI.optionMenu(bgx + 100, bgy + 100, 400, 600, 
		function(item, self)
			for k, on_show_function in pairs(optionmenu_on_show_functions) do
				on_show_function(self)
			end
		end
	)
	
	local delta_y = 50
	
	local options = {
		{
			name = "gravity", 
			decreaseCallback = 
				function(valueBox, self) 
					self.client_settings.gravity = self.client_settings.gravity - 1 
					valueBox:setText(""..self.client_settings.gravity)
					guiExample_optionMenu.GUI:sendToServer("server_SendModeToClients", self.client_settings)
				end,
			increaseCallback = 
				function(valueBox, self) 
					self.client_settings.gravity = self.client_settings.gravity + 1 
					valueBox:setText(""..self.client_settings.gravity)
					guiExample_optionMenu.GUI:sendToServer("server_SendModeToClients", self.client_settings)
				end,
			on_show = 
				function(valueBox, self)
					valueBox:setText(""..self.client_settings.gravity)
				end
		},
		{
			name = "other option", 
			decreaseCallback = 
				function(valueBox, self)
					self.client_settings.someOption = (self.client_settings.someOption - 1)%7
					valueBox:setText(({"A","B","C","D","E","F","G",})[self.client_settings.someOption + 1])
					guiExample_optionMenu.GUI:sendToServer("server_SendModeToClients", self.client_settings)
				end,
			increaseCallback = 
				function(valueBox, self) 
					self.client_settings.someOption = (self.client_settings.someOption + 1)%7 
					valueBox:setText(({"A","B","C","D","E","F","G",})[self.client_settings.someOption + 1])
					guiExample_optionMenu.GUI:sendToServer("server_SendModeToClients", self.client_settings)
				end,
			on_show = 
				function(valueBox, self)
					valueBox:setText(({"A","B","C","D","E","F","G",})[self.client_settings.someOption + 1])
				end
		}
	}
	local y = 0
	
	for k, optionData in pairs(options) do
		local option = optionmenu:addItemWithId(optionData.name, 0, y, 400, 50)
		y = y + 50
		
		local optionLabel = option:addLabel(0, 0, 250, 50, optionData.name, nil --[[on_click]])
		local optionValueBox = option:addValueBox(300, 0, 50, 50, "value", nil --[[on_click]])
		local optionDecreaseButton = option:addDecreaseButton(300-27, 5, 27, 40, function(item, self) optionData.decreaseCallback(optionValueBox, self) end)
		local optionIncreaseButton = option:addIncreaseButton(350, 5, 27, 40, function(item, self) optionData.increaseCallback(optionValueBox, self) end)
		table.insert(optionmenu_on_show_functions, function(self) optionData.on_show(optionValueBox, self) end)
	end
	
	guiExample_optionMenu.GUI:addItemWithId("optionmenu", optionmenu) -- !!! add the items to menu1 first before adding menu1 to the gui !!!!!!
end



function guiExample_optionMenu.client_onInteract(self)
	if not guiExample_optionMenu.GUI then print("Failed to open GUI") end

	guiExample_optionMenu.GUI:show(self)
end

function guiExample_optionMenu.client_onDestroy(self)
	if guiExample_optionMenu.GUI then guiExample_optionMenu.GUI:setVisible(false, true) end -- sets gui invisible without showing messages (displayalert)
	-- it is possible to not hide the gui(if it is open) when the block is broken, all callbacks that use self(the instance of this broken block) will cause errors tho.
end

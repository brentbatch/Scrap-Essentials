dofile "SE_Loader.lua"


-- the following code prevents re-load of this file, except if in '-dev' mode.  -- fixes broken sh*t by devs.
if guiExample_buttons and not sm.isDev then -- increases performance for non '-dev' users.
	return -- perform sm.checkDev(shape) in server_onCreate to set sm.isDev
end 

  
guiExample_buttons = class(guiClass) -- important !
guiExample_buttons.maxChildCount = -1
guiExample_buttons.maxParentCount = -1
guiExample_buttons.connectionInput = sm.interactable.connectionType.logic
guiExample_buttons.connectionOutput = sm.interactable.connectionType.logic -- none, logic, power, bearing, seated, piston, any
guiExample_buttons.colorNormal = sm.color.new(0xdf7000ff)
guiExample_buttons.colorHighlight = sm.color.new(0xef8010ff)
guiExample_buttons.poseWeightCount = 1

function guiExample_buttons.server_onCreate( self )
	self.mode = self.storage:load() or 0 -- AND
	
	guiExample_buttons:createRemote(self) -- create remote shape to handle all gui stuff, only one remote shape will exist at a time.
end

function guiExample_buttons.server_onFixedUpdate( self, dt )
	-- no server side code yet
	if not sm.exists(self.interactable) then return end 
	local parents = self.interactable:getParents()
	
	local output;
	if self.mode == 0 then	-- AND
		output = #parents > 0 -- #parents = amount of parents, if there are more than 0 parents the output can be true
		for k, parent in pairs(parents) do 
			output = output and parent.active -- all parents have to be active for output to stay true, if one parent is not active output will be false thanks to 'and'
		end
		
	elseif self.mode == 1 then -- OR
		output = false
		for k, parent in pairs(parents) do
			output = output or parent.active -- if any parent is active the output will be true because of the 'or'
		end
		 
	elseif self.mode == 2 then -- XOR
		output = false
		for k, parent in pairs(parents) do
			if parent.active then
				output = not output -- flip output every time it finds an active parent, this way it'll be true if an uneven amount of parents is active.
			end
		end
	
	end 

	self.interactable:setActive(output)
end
 
function guiExample_buttons.server_SendModeToClients( self, newMode --[[optional]] )
	if newMode then 
		self.mode = newMode
		self.storage:save(self.mode)
	end
	self.network:sendToClients("client_changeMode", self.mode)
end




-- clients:

function guiExample_buttons.client_onCreate( self )
	self.network:sendToServer("server_SendModeToClients") -- "request mode from server"
	self.interactable:setUvFrameIndex(0)
end

function guiExample_buttons.client_onSetupGui( self )
	if self:wasCreated(guiExample_buttons.GUI) then return end -- only allow remote shape to create a gui
	
	local annoyingPrints = false
	
	local gui_on_show_functions = {
		function(guiself, self)
			if annoyingPrints then
				print("part",self.shape,"opened gui \""..guiself.title.."\" at location",self.shape.worldPosition) 
			end
		end 
	}
	
	guiExample_buttons.GUI = GlobalGUI.create(
		self, 
		"GUI - TEST", -- title
		600, -- width
		300, -- height
		function(guiself, self) -- on_hide
			if annoyingPrints then
				print("part",self.shape,"closed gui \""..guiself.title.."\" at location",self.shape.worldPosition)
			end
		end,
		function(guiself, dt) -- on_update  (happens per frame) (you can also put 'nil' instead of 'function(guiself, dt) end'  )
		end,
		function(guiself, self) -- on_show
			for _, on_show_function in pairs(gui_on_show_functions) do
				on_show_function(guiself, self) -- this way of 'loading' functions allows you to add more functions to gui on_show to do other stuff later on.
			end
		end, 
		10, -- protectionlayers
		true -- autoscale
	)
	--[[ info:
		'guiself' is your gui instance , in this case guiExample_buttons.GUI
		'self' in the callback functions 'on_hide' and 'on_show' is the self of the part the user interacts with
		'protectionlayers' is the amount of layers between the background and your items, this prevents z-index from skrewing over your gui.
		'autoscale' (default true if left out or nil)	
	]]
	
	local bgx, bgy = guiExample_buttons.GUI.bgPosX , guiExample_buttons.GUI.bgPosY
	
	local button1 = GlobalGUI.buttonSmall(
		bgx + 100, -- pos x
		bgy + 100, -- pos y
		100, -- width
		50, -- height
		"AND",  -- value
		function(item, self) -- on_click
			self.interactable:setUvFrameIndex(0 + (self.interactable.active and 6 or 0))
			guiExample_buttons.GUI:sendToServer("server_SendModeToClients", 0) -- so other clients also receive this new mode
			guiExample_buttons.GUI.items.custombutton4:on_show(self)
			guiExample_buttons.GUI.items.customlabel1:on_show(self)
		end, 
		function(item, self) end, -- on_show
		"GUI Inventory highlight", -- sound to play when clicked
		true -- show border ? ( shows border if it's true or nil )
	)
	
	
	local button2 = GlobalGUI.buttonSmall(bgx + 250, bgy + 100, 100, 50, "OR", 
		function(item, self) 
			self.interactable:setUvFrameIndex(1 + (self.interactable.active and 6 or 0)) 
			guiExample_buttons.GUI:sendToServer("server_SendModeToClients", 1)
			guiExample_buttons.GUI.items.custombutton4:on_show(self)
			guiExample_buttons.GUI.items.customlabel1:on_show(self)
		end,
		nil,
		"GUI Inventory highlight"
	)
	
	
	local button3 = GlobalGUI.buttonSmall(bgx + 400, bgy + 100, 100, 50, "XOR", 
		function(item, self) 
			self.interactable:setUvFrameIndex(2 + (self.interactable.active and 6 or 0)) 
			guiExample_buttons.GUI:sendToServer("server_SendModeToClients", 2)
			guiExample_buttons.GUI.items.custombutton4:on_show(self)
			guiExample_buttons.GUI.items.customlabel1:on_show(self)
		end,
		nil, 
		"GUI Inventory highlight"
	)
	
	
		
	local button4 = GlobalGUI.buttonSmall(bgx + 175, bgy + 200, 100, 50, "whatever", -- this button cycles between the modes
		function(item, self) 
			self.interactable:setUvFrameIndex(item.nextmode + (self.interactable.active and 6 or 0))
			guiExample_buttons.GUI:sendToServer("server_SendModeToClients", item.nextmode)
			item:on_show(self)
			guiExample_buttons.GUI.items.customlabel1:on_show(self)
		end,
		function(item, self)
			item.nextmode = (self.interactable:getUvFrameIndex()%3 + 1)%3
			item:setText( "next: "..({"AND","OR","XOR"})[item.nextmode + 1] )
		end ,
		"GUI Inventory highlight"
	)
	
	  
	
	local label1 = GlobalGUI.labelSmall(bgx + 315, bgy + 175, 120, 100, "Current State:\nAND", 
		nil, 
		function(item, self)
			item:setText("Current State:\n"..({"AND","OR","XOR"})[self.interactable:getUvFrameIndex()%3 + 1])
		end, nil, false 
	)
	
	
	guiExample_buttons.GUI:addItem(button1) -- the 'id' this 'addItem' function will use is 'button1.id' (some incremental gui widget number)
	guiExample_buttons.GUI:addItem(button2)
	guiExample_buttons.GUI:addItem(button3)
	guiExample_buttons.GUI:addItemWithId("custombutton4", button4)
	guiExample_buttons.GUI:addItemWithId("customlabel1", label1)
	
end

function guiExample_buttons.client_onUpdate(self, dt)
	if not sm.exists(self.interactable) then return end
	self.interactable:setUvFrameIndex(self.interactable:getUvFrameIndex()%3 + (self.interactable.active and 6 or 0)) 
	self.interactable:setPoseWeight(0, self.interactable.active and 1 or 0)
end

function guiExample_buttons.client_changeMode(self, mode)
	self.interactable:setUvFrameIndex(mode + (self.interactable.active and 6 or 0))
	
	-- if you want to safe mode on client, don't name it self.mode because 'self' is shared between server and client on the host.
	-- i'm simply using uvframeindex to 'safe' the mode.
	if guiExample_buttons.GUI and guiExample_buttons.GUI.visible then
		guiExample_buttons.GUI:show(self) -- run all the 'on_show' callbacks again.
	end
end

function guiExample_buttons.client_onInteract(self)
	if not guiExample_buttons.GUI then print("Failed to open GUI") end
	guiExample_buttons.GUI:show(self)
end

function guiExample_buttons.client_onDestroy(self)
	if guiExample_buttons.GUI then guiExample_buttons.GUI:setVisible(false, true) end -- sets gui invisible without showing messages (displayalert)
	-- it is possible to not hide the gui(if it is open) when the block is broken, all callbacks that use self(the instance of this broken block) will cause errors tho.
end
dofile "SE_Loader.lua"


-- the following code prevents re-load of this file, except if in '-dev' mode.  -- fixes broken sh*t by devs.
if guiExample and not sm.isDev then -- increases performance for non '-dev' users.
	return -- perform sm.checkDev(shape) in server_onCreate to set sm.isDev
end 
 

guiExample = class(guiClass) -- important !
guiExample.maxChildCount = -1
guiExample.maxParentCount = -1
guiExample.connectionInput = sm.interactable.connectionType.logic
guiExample.connectionOutput = sm.interactable.connectionType.logic -- none, logic, power, bearing, seated, piston, any
guiExample.colorNormal = sm.color.new(0xdf7000ff)
guiExample.colorHighlight = sm.color.new(0xef8010ff)

function guiExample.server_onCreate( self ) 
	guiExample:createRemote(self) -- create remote shape to handle all gui stuff, only one remote shape will exist at a time.
end

function guiExample.server_onFixedUpdate( self, dt )
	if os.time()%5 == 0 and self.risingedge then 
		 
		
	end 
	self.risingedge = os.time()%5 ~= 0
end


  
function guiExample.client_onCreate( self )
	self.interactable:setUvFrameIndex(0)

	self.menu1_selected = 1

end

function guiExample.client_onSetupGui( self )
	if self:wasCreated(guiExample_GUI) then return end -- only allow remote shape to create a gui
	
	
	local gui_on_show_functions = {
		function(guiself, self)
			print("part",self.shape,"opened gui \""..guiself.title.."\" at location",self.shape.worldPosition)
		end
	}
	
	guiExample_GUI = GlobalGUI.create(
		self, 
		"GUI - TEST", -- title
		1100, -- width
		700, -- height
		function(guiself, self) -- on_hide  
			print("part",self.shape,"closed gui \""..guiself.title.."\" at location",self.shape.worldPosition)
		end,
		function(guiself, dt) -- on_update  (happens per frame) (you can also put 'nil' instead of 'function(guiself, dt) end'  )
		end,
		function(guiself, self) -- on_show
			for _, on_show_function in pairs(gui_on_show_functions) do
				on_show_function(guiself, self) -- this way of 'loading' functions allows you to add more functions to gui on_show to do other stuff.
			end
		end, 
		10, -- protectionlayers
		true -- autoscale
	)
	--[[ info:
		'guiself' is your gui instance , in this case guiExample_GUI
		'self' in the callback functions 'on_hide' and 'on_show' is the self of the part the user interacts with
		'protectionlayers' is the amount of layers between the background and your items, this prevents z-index from skrewing over your gui.
		'autoscale' (default true if left out or nil)	
	]]
	
	local bgx, bgy = guiExample_GUI.bgPosX , guiExample_GUI.bgPosY
	
	local button1 = GlobalGUI.buttonSmall(
		bgx + 100, -- pos x
		bgy + 100, -- pos y
		100, -- width
		50, -- height
		"AND",  -- value
		function(item, self) -- on_click
			self.interactable:setUvFrameIndex(0)
			guiExample_GUI.items.custombutton4:on_show(self)
			guiExample_GUI.items.customlabel1:on_show(self)
		end, 
		function(item, self) end, -- on_show
		"GUI Inventory highlight", -- sound to play when clicked
		true -- show border ? ( shows border if it's true or nil )
	)
	local button2 = GlobalGUI.buttonSmall(bgx + 100, bgy + 150, 100, 50, "OR", 
		function(item, self) 
			self.interactable:setUvFrameIndex(1) 
			guiExample_GUI.items.custombutton4:on_show(self)
			guiExample_GUI.items.customlabel1:on_show(self)
		end,
		nil,
		"GUI Inventory highlight"
	)
	local button3 = GlobalGUI.buttonSmall(bgx + 100, bgy + 200, 100, 50, "XOR", 
		function(item, self) 
			self.interactable:setUvFrameIndex(2) 
			guiExample_GUI.items.custombutton4:on_show(self)
			guiExample_GUI.items.customlabel1:on_show(self)
		end,
		nil, 
		"GUI Inventory highlight"
	)
	
	
	
	local button4_updateText = 
		function(item, self)
			item.nextmode = (self.interactable:getUvFrameIndex() + 1)%3
			item:setText( ({"AND","OR","XOR"})[item.nextmode + 1] )
		end 
		
	local button4 = GlobalGUI.buttonSmall(bgx + 100, bgy + 270, 100, 50, "whatever", -- this button cycles between the modes
		function(item, self) 
			self.interactable:setUvFrameIndex(item.nextmode)
			button4_updateText(item, self)
			guiExample_GUI.items.customlabel1:on_show(self)
		end,
		button4_updateText,
		"GUI Inventory highlight"
	)
	
	  
	
	local label1 = GlobalGUI.labelSmall(bgx + 90, bgy + 400, 120, 100, "Current State:\nAND", 
		nil, 
		function(item, self)
			item:setText("Current State:\n"..({"AND","OR","XOR"})[self.interactable:getUvFrameIndex() + 1])
		end
	)
	
	
	guiExample_GUI:addItem(button1) -- the 'id' this 'addItem' function will use is 'button1.id' (some incremental gui widget number)
	guiExample_GUI:addItem(button2)
	guiExample_GUI:addItem(button3)
	guiExample_GUI:addItemWithId("custombutton4", button4)
	guiExample_GUI:addItemWithId("customlabel1", label1)
	
	
	------------------- this is where simple stuff ends, uncomment the next line to not load the rest of the gui code -------------------------------
	-- if true then return end
	
	
	
	
	-- < the following menu setup adds highlighting and per part it remembers which menu is selected.
	-- if you want the behaviour to be simpler (selected submenu is global):
	--	 simpler behaviour: select header2 in 1 part , exit gui, go to another part and header2 will also be selected instead of default header1 
	--   code change for this: you can remove the on_show and on_click definitions in the following 30-ish lines of code untill '/>' )
	
	local menu1 = GlobalGUI.tabControl({},{}) -- empty menu, no headers, no items (you can also use headers and items as parameters
	
	local function changeTabHighlight(item, self, tabSelected)
		local oldHighlight = self.menu1_selected
		self.menu1_selected = tabSelected
		menu1.headers["menu1_option"..oldHighlight]:on_show(self) -- reference based ('menu1') 
		item:on_show(self)
	end
	
	local menu1_headerButton1 = GlobalGUI.buttonSmall(bgx + 300, bgy + 100, 200, 50, "Header1", 
		function(item, self) -- on_click
			changeTabHighlight(item, self, 1)
		end, 
		function(item, self) -- on_show
			menu1:setVisibleTab(true, "menu1_option"..self.menu1_selected) -- ' "menu1_option"..self.menu1_selected ' is the id you gave that tab when adding it using 'menu1:addItemWithId' later on in the code.
			item:setText( self.menu1_selected == 1 and "#df7000Header1" or "#eeeeeeHeader1")
		end)
	local menu1_headerButton2 = GlobalGUI.buttonSmall(bgx + 500, bgy + 100, 200, 50, "Header2", 
		function(item, self) -- on_click
			changeTabHighlight(item, self, 2)
		end,  
		function(item, self) -- on_show
			item:setText( self.menu1_selected == 2 and "#df7000Header2" or "#eeeeeeHeader2")
		end)
	local menu1_headerButton3 = GlobalGUI.buttonSmall(bgx + 700, bgy + 100, 200, 50, "Header3", 
		function(item, self) -- on_click
			changeTabHighlight(item, self, 3)
		end, 
		function(item, self) -- on_show
			item:setText( self.menu1_selected == 3 and "#df7000Header3" or "#eeeeeeHeader3")
		end)
	  
	-- custom menu highlighting and per part submenu selection />
	-- note: the 'tabcontrol' handles the 'clicking on a header causes these items to show up' behaviour on its own. 'setVisibleTab' is just a way for the modder to control it.
	
	
	
	local menu1_option2_submenu = GlobalGUI.tabControl({},{})
	
	
	
	
	
	menu1:addItemWithId("menu1_option1", menu1_headerButton1, GlobalGUI.button(bgx + 300, bgy + 175, 600, 325, "BLOW EVERYTHING UP"))
	menu1:addItemWithId("menu1_option2", menu1_headerButton2, GlobalGUI.buttonSmall(bgx + 350, bgy + 200, 200, 50, "dummy2"))
	menu1:addItemWithId("menu1_option3", menu1_headerButton3, GlobalGUI.buttonSmall(bgx + 400, bgy + 200, 200, 50, "dummy3"))
	
	guiExample_GUI:addItemWithId("tabControl1", menu1)
	
	
end


function guiExample.client_onInteract(self)
	if not guiExample_GUI then print("Failed to open GUI") end

	guiExample_GUI:show(self)
end

function guiExample.client_onDestroy(self)
	if guiExample_GUI then guiExample_GUI:setVisible(false, true) end -- sets gui invisible without showing messages (displayalert)
	-- it is possible to not hide the gui(if it is open) when the block is broken, all callbacks that use self(the instance of this broken block) will cause errors tho.
end
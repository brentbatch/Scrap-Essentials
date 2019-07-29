dofile "SE_Loader.lua"


-- the following code prevents re-load of this file, except if in '-dev' mode.  -- fixes broken sh*t by devs.
if guiExample_tabcontrol and not sm.isDev then -- increases performance for non '-dev' users.
	return -- perform sm.checkDev(shape) in server_onCreate to set sm.isDev
end 
 
  
guiExample_tabcontrol = class(guiClass) -- important !
guiExample_tabcontrol.maxChildCount = -1
guiExample_tabcontrol.maxParentCount = -1
guiExample_tabcontrol.connectionInput = sm.interactable.connectionType.logic
guiExample_tabcontrol.connectionOutput = sm.interactable.connectionType.logic -- none, logic, power, bearing, seated, piston, any
guiExample_tabcontrol.colorNormal = sm.color.new(0xdf7000ff)
guiExample_tabcontrol.colorHighlight = sm.color.new(0xef8010ff)

function guiExample_tabcontrol.server_onCreate( self ) 
	guiExample_tabcontrol:createRemote(self) -- create remote shape to handle all gui stuff, only one remote shape will exist at a time.
end

function guiExample_tabcontrol.server_onFixedUpdate( self, dt )
	if os.time()%5 == 0 and self.risingedge then 
		 
		
	end 
	self.risingedge = os.time()%5 ~= 0
end
 

  
function guiExample_tabcontrol.client_onCreate( self )
	self.interactable:setUvFrameIndex(0)

	self.menu1_selected = 1
	self.menu1_option2_selected = 1
	
end

function guiExample_tabcontrol.client_onSetupGui( self )
	if self:wasCreated(guiExample_tabcontrol.GUI) then return end -- only allow remote shape to create a gui
	
	local annoyingPrints = false
	
	local gui_on_show_functions = {
		function(guiself, self)
			if annoyingPrints then
				print("part",self.shape,"opened gui \""..guiself.title.."\" at location",self.shape.worldPosition) 
			end
		end
	}
	
	guiExample_tabcontrol.GUI = 
		GlobalGUI.create(self, "GUI - TEST", 1100, 700, 
			function(guiself, self) -- on_hide
				if annoyingPrints then
					print("part",self.shape,"closed gui \""..guiself.title.."\" at location",self.shape.worldPosition)
				end
			end,
			nil,
			function(guiself, self) -- on_show
				for _, on_show_function in pairs(gui_on_show_functions) do
					on_show_function(guiself, self)
				end
			end
		)
	local bgx, bgy = guiExample_tabcontrol.GUI.bgPosX , guiExample_tabcontrol.GUI.bgPosY
	
	
	-- < the following menu setup adds highlighting and per part it remembers which tab is selected.
	-- if you want the behaviour to be simpler (selected tab is global):
	--	 simpler behaviour: select header2 in 1 part , exit gui, go to another part and header2 will also be selected instead of default header1 
	--   code change for this: you can remove the on_show and on_click definitions in the following 30-ish lines of code untill '/>' )
	
	local menu1 = GlobalGUI.tabControl({},{}, true) -- empty menu, no headers, no items (you can also use headers and items as parameters
	
	
	local menu1_headerButton1 = GlobalGUI.buttonSmall(bgx + 300, bgy + 100, 200, 50, "Header1")
	local menu1_headerButton2 = GlobalGUI.buttonSmall(bgx + 500, bgy + 100, 200, 50, "Header2")
	local menu1_headerButton3 = GlobalGUI.buttonSmall(bgx + 700, bgy + 100, 200, 50, "Header3")
	   
	-- custom menu highlighting and per part tab selection />
	-- note: the 'tabcontrol' handles the 'clicking on a header causes these items to show up' behaviour on its own. 'setVisibleTab' is just a way for the modder to control it.
	
	local dummy = GlobalGUI.buttonSmall( 0, 0, 600, 90, "dummy")
	
	local menu1_option2_submenu = GlobalGUI.tabControl({},{}, true) 
	
	local menu1_option2_header1 = GlobalGUI.buttonSmall(bgx + 300, bgy + 160, 300, 50, "Header2 subheader1")
	local menu1_option2_header2 = GlobalGUI.buttonSmall(bgx + 600, bgy + 160, 300, 50, "Header2 subheader2")
	
	menu1_option2_submenu:addItemWithId("menu1_option2_header1", menu1_option2_header1, dummy)
	menu1_option2_submenu:addItemWithId("menu1_option2_header2", menu1_option2_header2, dummy)
	
	
	
	
	
	
	menu1:addItemWithId("menu1_option1", menu1_headerButton1, GlobalGUI.button(bgx + 300, bgy + 175, 600, 325, "BLOW EVERYTHING UP", 
			function(item, self)
				guiExample_tabcontrol.GUI:sendToServer("server_button_click", "any data here, table, boolean, number, whatever rly")
			end 
		)
	) 
	menu1:addItemWithId("menu1_option2", menu1_headerButton2, menu1_option2_submenu)
	menu1:addItemWithId("menu1_option3", menu1_headerButton3, GlobalGUI.buttonSmall(bgx + 400, bgy + 200, 200, 50, "dummy3"))
	
	guiExample_tabcontrol.GUI:addItemWithId("tabControl1", menu1) -- !!! add the items to menu1 first before adding menu1 to the gui !!!!!!
end


function guiExample_tabcontrol.server_button_click(self, data)
	print('server_button_click_function_printing_stuff  ', data)
	-- function to explode stuff here
end

function guiExample_tabcontrol.client_onInteract(self)
	if not guiExample_tabcontrol.GUI then print("Failed to open GUI") end

	guiExample_tabcontrol.GUI:show(self)
end

function guiExample_tabcontrol.client_onDestroy(self)
	if guiExample_tabcontrol.GUI then guiExample_tabcontrol.GUI:setVisible(false, true) end -- sets gui invisible without showing messages (displayalert)
	-- it is possible to not hide the gui(if it is open) when the block is broken, all callbacks that use self(the instance of this broken block) will cause errors tho.
end
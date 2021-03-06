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
		GlobalGUI.create(self, "GUI - TEST - TABCONTROL", 800, 600,
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


	local menu1 = GlobalGUI.tabControl({},{}, true, "#df7f00") -- empty menu, no headers, no items (you can also use headers and items as parameters

	do -- header 1
		menu1:addItemWithId("menu1_option1",
			GlobalGUI.buttonSmall(bgx + 100, bgy + 100, 200, 50, "Header1"), -- header button
			GlobalGUI.button(bgx + 100, bgy + 175, 600, 325, "#ff0000EXPLODE EVERYONE", -- content (a button)
				function(item, self)
					guiExample_tabcontrol.GUI:sendToServer("server_button_click", "any data here, table, boolean, number, whatever rly")
				end
			)
		)
	end

	do -- header 2
		local menu1_option2_submenu = GlobalGUI.tabControl({},{}, true, "#00ff00", "#ff0000")

		local textBox = GlobalGUI.textBox( bgx + 175, bgy + 220, 450, 300, "textBoxes are very limited atm, this it the max size, no 'enters'")

		menu1_option2_submenu:addItemWithId(
			"menu1_option2_header1",
			GlobalGUI.buttonSmall(bgx + 100, bgy + 160, 300, 50, "Header2 subheader1"),
			GlobalGUI.collection({
				textBox,
				GlobalGUI.buttonSmall(bgx + 175, bgy + 525, 450, 50, "Print contents of this textbox in console.",
					function(item, self)
						print('TextBox content: '..textBox:getText()) -- using direct reference to get the text.
						-- also possible is the following line: (try it out!)
						--print('TextBox content: '..menu1_option2_submenu.items.menu1_option2_header1.items[1]:getText()) -- the textbox is the 1st item in the GlobalGUI.collection
					end
				)
			})
		)
		menu1_option2_submenu:addItemWithId("menu1_option2_header2",
			GlobalGUI.buttonSmall(bgx + 400, bgy + 160, 300, 50, "Header2 subheader2"),
			GlobalGUI.invisibleBox(bgx + 100, bgy + 220, 600, 350,
				function(item, self)
					print('owo, there is something here!')
				end
			)
		)

		menu1:addItemWithId("menu1_option2",
			GlobalGUI.buttonSmall(bgx + 300, bgy + 100, 200, 50, "Header2"),
			menu1_option2_submenu
		)
	end

	do -- header 3
		-- full nesting is possible: 
		menu1:addItemWithId("menu1_option3", 
			GlobalGUI.buttonSmall(bgx + 500, bgy + 100, 200, 50, "Header3"), 
			GlobalGUI.tabControl(
				{
					GlobalGUI.buttonSmall(bgx + 100, bgy + 160, 150, 50, "H3 subheader1"),
					GlobalGUI.buttonSmall(bgx + 250, bgy + 160, 150, 50, "H3 subheader2"),
					GlobalGUI.buttonSmall(bgx + 400, bgy + 160, 150, 50, "H3 subheader3"),
					GlobalGUI.buttonSmall(bgx + 550, bgy + 160, 150, 50, "H3 subheader4"),
				},
				{
					GlobalGUI.tabControl(
						{
							GlobalGUI.buttonSmall(bgx + 100, bgy + 220, 300, 50, "H3 sh1 subsub1"),
							GlobalGUI.buttonSmall(bgx + 400, bgy + 220, 300, 50, "H3 sh1 subsub2"),
						},
						{
							GlobalGUI.label(bgx + 100, bgy + 290, 600, 200, "Header3\nSubHeader1\nSubSubHeader1\nCONTENT"),
							GlobalGUI.label(bgx + 100, bgy + 290, 600, 200, "Header3\nSubHeader1\nSubSubHeader2\nCONTENT")
						},
						true, "#00df70"
					),
					GlobalGUI.tabControl(
						{
							GlobalGUI.buttonSmall(bgx + 100, bgy + 220, 300, 50, "H3 sh2 subsub1"),
							GlobalGUI.buttonSmall(bgx + 400, bgy + 220, 300, 50, "H3 sh2 subsub2"),
						},
						{
							GlobalGUI.label(bgx + 100, bgy + 290, 600, 200, "Header3\nSubHeader2\nSubSubHeader1\nCONTENT"),
							GlobalGUI.label(bgx + 100, bgy + 290, 600, 200, "Header3\nSubHeader2\nSubSubHeader2\nCONTENT")
						},
						true, "#00df70"
					),
					GlobalGUI.tabControl(
						{
							GlobalGUI.buttonSmall(bgx + 100, bgy + 220, 300, 50, "H3 sh3 subsub1"),
							GlobalGUI.buttonSmall(bgx + 400, bgy + 220, 300, 50, "H3 sh3 subsub2"),
						},
						{
							GlobalGUI.label(bgx + 100, bgy + 290, 600, 200, "Header3\nSubHeader3\nSubSubHeader1\nCONTENT"),
							GlobalGUI.label(bgx + 100, bgy + 290, 600, 200, "Header3\nSubHeader3\nSubSubHeader2\nCONTENT")
						},
						true, "#00df70"
					),
					GlobalGUI.tabControl(
						{
							GlobalGUI.buttonSmall(bgx + 100, bgy + 220, 300, 50, "H3 sh4 subsub1"),
							GlobalGUI.buttonSmall(bgx + 400, bgy + 220, 300, 50, "H3 sh4 subsub2"),
						},
						{
							GlobalGUI.label(bgx + 100, bgy + 290, 600, 200, "Header3\nSubHeader4\nSubSubHeader1\nCONTENT"),
							GlobalGUI.label(bgx + 100, bgy + 290, 600, 200, "Header3\nSubHeader4\nSubSubHeader2\nCONTENT")
						},
						true, "#00df70"
					),
				}, 
				true, "#00df70"
			)
		)
	end

	guiExample_tabcontrol.GUI:addItemWithId("tabControl1", menu1) -- !!! add the items to menu1 first before adding menu1 to the gui !!!!!!
end


function guiExample_tabcontrol.server_button_click(self, data)
	for k, v in pairs(sm.player.getAllPlayers()) do
		sm.physics.explode( v.character.worldPosition, 1, 5, 30, 500, "PropaneTank - ExplosionBig")
	end
end

function guiExample_tabcontrol.client_onInteract(self)
	if not guiExample_tabcontrol.GUI then print("Failed to open GUI") end

	guiExample_tabcontrol.GUI:show(self)
end

function guiExample_tabcontrol.client_onDestroy(self)
	if guiExample_tabcontrol.GUI then guiExample_tabcontrol.GUI:setVisible(false, true) end -- sets gui invisible without showing messages (displayalert)
	-- it is possible to not hide the gui(if it is open) when the block is broken, all callbacks that use self(the instance of this broken block) will cause errors tho.
end

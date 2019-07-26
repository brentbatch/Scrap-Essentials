dofile "SE_Loader.lua"


-- the following code prevents re-load of this file, except if in '-dev' mode.  -- fixes broken sh*t by devs.
if guiExample and not sm.isDev then -- increases performance for non '-dev' users.
	return
end 
 

guiExample = class(guiClass) -- important !
guiExample.maxChildCount = -1
guiExample.maxParentCount = -1
guiExample.connectionInput = sm.interactable.connectionType.logic
guiExample.connectionOutput = sm.interactable.connectionType.logic -- none, logic, power, bearing, seated, piston, any
guiExample.colorNormal = sm.color.new(0xdf7000ff)
guiExample.colorHighlight = sm.color.new(0xef8010ff)

function guiExample.server_onCreate( self ) 
	guiClass.createRemote(guiExample, self) -- create remote shape to handle all gui stuff, only one remote shape will exist at a time.
end

function guiExample.server_onFixedUpdate( self, dt )
	if os.time()%5 == 0 and self.risingedge then 
		 
		
	end 
	self.risingedge = os.time()%5 ~= 0
end

 
function guiExample.client_onCreate( self )
	

end

function guiExample.client_onSetupGui( self )
	if guiClass.wasCreated(self, guiExample_GUI) then return end -- only allow remote shape to create a gui
	
	guiExample_GUI = GlobalGUI.create(
		self, 
		"GUI - TEST", -- title
		600, -- width
		300, -- height
		function(guiself, self) -- on_hide  
			print("part",self.shape,"closed gui \""..guiself.title.."\" at location",self.shape.worldPosition)
		end,
		function(guiself, dt) -- on_update  (happens per frame)
			
		end, 
		function(guiself, self) -- on_show
			print("part",self.shape,"opened gui \""..guiself.title.."\" at location",self.shape.worldPosition)
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
	


end

function guiExample.client_onInteract(self)
	if not guiExample_GUI then print("Failed to open GUI") end

	guiExample_GUI:show(self)
end

function guiExample.client_onDestroy(self)
	if guiExample_GUI then guiExample_GUI:setVisible(false, true) end -- sets gui invisible without showing messages (displayalert)
	-- it is possible to not hide the gui(if it is open) when the block is broken, all callbacks that use self(the instance of this broken block) will cause errors tho.
end
print("toolhack function loaded")
dofile "$GAME_DATA/Scripts/game/Lift.lua" 
dofile "tools/ExplosionGun.lua"

-- stabilizer mug gun for the lolz
 
-- client vraagt aan server om hoverbodies te callen !

function sm.toolHack(self)
	if not self.network.sendToServerHijacks then
		self.network.sendToServerHijacks = {self.network.sendToServer} -- hijack sendToServer
		function self.network.sendToServer(network, str, data)
			local vanillaFunc = true
			for hijacknr = 1,#network.sendToServerHijacks do
				if #network.sendToServerHijacks - hijacknr == 0 and not vanillaFunc then break end
				local result = network.sendToServerHijacks[#network.sendToServerHijacks - hijacknr + 1](network, str, data) -- perform last hijack first
				if result == "break" then -- when you want to break the loop, other hijacks won't read the call
					break
				elseif result == "novanilla" then -- when you want to capture a call and not let the vanilla func perform it
					vanillaFunc = false
				end
			end
		end
	end
	
	local tools = {ExplosionGun}
	local gui = self.gui
	local HIJACKED = false
	local lifthijackindex = #self.network.sendToServerHijacks + 1
	table.insert(self.network.sendToServerHijacks, -- add the lift hijack to the sendToServerhijack
		function(network, str, data)
			if str == "server_placeLift" then -- capture lift call
				self.dupenetwork = network
				if HIJACKED then
					network.sendToServerHijacks[lifthijackindex] = function() return nil end -- kill this hijack
				return nil end
				print('HIJACKING LIFT TOOL:', os.clock())
				-- HIJACK THE LIFT.LUA:
				if not sm.localPlayer.getRaycastO then sm.localPlayer.getRaycastO = sm.localPlayer.getRaycast end
				function sm.localPlayer.getRaycast( number) return true, 
					{--[[fakecast]] ["valid"] = true,["type"] = "body",["pointWorld"] = sm.vec3.new(0,0,5), ["getBody"] = function(fakecast) fakecast.valid = false
								return {--[[fakebody]] ["isDynamic"] = function(fakebody) return true end, ["isLiftable"] = function(fakebody) return true end,["getCreationBodies"] = function(fakebody) 
											function fakebody.getCreationBodies(fakebody) self.network.sendToServerHijacks[1](self.network, "call_me")
												return function(lift, hihacked) -- the function that is 'inserted'
														sm.publictool = lift.tool -- make tool public
														
                                                        for k, value in pairs(tools[1]) do
                                                            lift[k] = value
                                                        end
                                                        lift.backupClientUpdate = lift.client_onUpdate
                                                        function lift.client_onUpdate(self, dt) 
                                                            self:client_onCreate()
                                                            self:client_onEquip()
                                                            self.client_onUpdate = lift.backupClientUpdate
                                                            self.backupClientUpdate = nil
                                                        end
														function lift.client_onReload(self) -- reload tool
															--gui:show()
															self:client_onUnequip()
															for k, value in pairs(Lift) do
																self[k] = value
															end
															self.backupClientUpdate = self.client_onUpdate
															function lift.client_onUpdate(ss, dt) 
																ss:client_onCreate()
																ss:client_onEquip()
																ss.client_onUpdate = lift.backupClientUpdate
																ss.backupClientUpdate = nil
															end
														end
														sm.localPlayer.getRaycast = sm.localPlayer.getRaycastO --repair broken functions
														HIJACKED = true
														--sm.player.placeLift(data.player, data.selectedBodies, data.liftPos, data.liftLevel, data.rotationIndex)
													end
											end return {} end } end } end end return nil 
		end
	)
	--self.shape:destroyPart(0)
	
end
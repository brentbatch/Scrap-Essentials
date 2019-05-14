print("Physics library loading...")

-- set local gravity:
if not sm.localGravityControllers then sm.localGravityController = {} end
function sm.physics.setLocalGravity(self, gravity, shape, dir, drag) -- an option: scriptclass has to perform this function every tick to work instead of janky overwrite
	dir = (dir or sm.vec3.new(0,0,1)):normalize()
	drag = (drag ~= nil and drag or 1)
	shape = shape or self.shape
	if dir == sm.vec3.new(0,0,1) and gravity == 1 and sm.localGravityController[self.interactable.id] then 
		self.server_onFixedUpdate = sm.localGravityController[self.interactable.id] 
		sm.localGravityController[self.interactable.id] = nil 
	return end -- kill the loop
	if not sm.localGravityController[self.interactable.id] then sm.localGravityController[self.interactable.id] = self.server_onFixedUpdate end -- store the original
    function self.server_onFixedUpdate(self, dt)
		if not sm.localGravityController[self.interactable.id] then return end sm.localGravityController[self.interactable.id](self, dt) -- perform original
		if not sm.exists(shape) then self.server_onFixedUpdate = sm.localGravityController[self.interactable.id] sm.localGravityController[self.interactable.id] = nil return end -- kill the loop
        for k, body in pairs(shape:getBody():getCreationBodies()) do -- do the gravity thing:
			if sm.exists(body) then sm.physics.applyImpulse(body, (sm.vec3.new(0,0,1.047494) - dir * gravity)*sm.physics.getGravity()*dt*body.mass, true) end
        end
    end
end

-- Add velocity for shapes/bodies
function sm.physics.addVelocity(body, velocity, global, offset) sm.physics.applyImpulse(body, velocity * body.mass, global, offset) end

-- Add velocity for vehicles
function sm.physics.creationAddVelocity(in_body, velocity) for i, body in pairs(in_body:getCreationBodies()) do sm.physics.applyImpulse(body, velocity * body.mass) end end

--Add angular velocity for bodies
function sm.physics.addAngularVelocity(body, a_velocity) sm.physics.applyTorque(body, a_velocity * body:getMOI(a_velocity)) end

print("Succesfully loaded.")
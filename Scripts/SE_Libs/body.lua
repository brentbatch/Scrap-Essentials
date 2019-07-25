local version = 1

if (sm.__SE_Version._Body or 0) >= version then return end
sm.__SE_Version._Body = version

print("Bodies library loading...")

local bodyCOMs = {}

-- Body's center of mass
function sm.body.getCOM(body)
    if (not bodyCOMs[body.id]) then bodyCOMs[body.id] = {} end
    -- First iteration or change detected
    if ((not bodyCOMs[body.id].tick)or((bodyCOMs[body.id].tick < sm.game.getCurrentTick())and(sm.body.hasChanged(body, bodyCOMs[body.id].tick)))or(not sm.exists(bodyCOMs[body.id].shape))) then
        if (not bodyCOMs[body.id].body) then bodyCOMs[body.id].body = body end -- AUTO DELETE
        local shapes = body:getShapes()
        bodyCOMs[body.id].shape = shapes[1]
        local mass = 0
        local center = sm.vec3.new(0, 0, 0)
        for i, shape in pairs(shapes) do
            center = center + shape:getWorldPosition() * shape:getMass()
            mass = mass + shape:getMass()
        end
        center = center * (1 / mass) --VectorBug
        local displacement = center - bodyCOMs[body.id].shape:getWorldPosition()
        bodyCOMs[body.id].vector = displacement:localize(bodyCOMs[body.id].shape)
        bodyCOMs[body.id].tick = sm.game.getCurrentTick()
        return center
    end
    return bodyCOMs[body.id].shape:getWorldPosition() + bodyCOMs[body.id].vector:delocalize(bodyCOMs[body.id].shape)
end

-- Vehicle's center of mass
function sm.body.getCreationCOM(in_body)
    local bodies = in_body:getCreationBodies()
    local mass = 0
    local center = sm.vec3.new(0, 0, 0)
    for i, body in pairs(bodies) do
        center = center + sm.body.getCOM(body) * body.mass
        mass = mass + body.mass
    end
    center = center * (1 / mass) --VectorBug
    return center
end

local bodyMOIs = {}

-- Creation's moment of inertia
function sm.body.getMOI(body, in_axis)
	bodyMOIs[body.id] = bodyMOIs[body.id] or {
		inertia = {},
		tick = 0,
		body = body
	}
    local shapes = body:getShapes()
    bodyMOIs[body.id].shape = shapes[1]
    in_axis = in_axis:localize(bodyMOIs[body.id].shape)
    in_axis = in_axis:normalize()
    if ((not bodyMOIs[body.id].tick)or(sm.body.hasChanged(body, bodyMOIs[body.id].tick))) then
        bodyMOIs[body.id].inertia.xx = 0
        bodyMOIs[body.id].inertia.yy = 0
        bodyMOIs[body.id].inertia.zz = 0
        bodyMOIs[body.id].inertia.xy = 0
        bodyMOIs[body.id].inertia.yz = 0
        bodyMOIs[body.id].inertia.xz = 0
        for i, shape in pairs(shapes) do
            local center = sm.body.getCOM(body)
            local box = shape:getBoundingBox()
            local mass = shape.mass / (box.x * 4 * box.y * 4 * box.z * 4)
            local pos = shape:getWorldPosition()
            for x = box.x * 2, box.x * -2 + 1, -1 do
                local position = pos + shape:getRight() * (x / 4 - 0.125)
                for y = box.y * 2, box.y * -2 + 1, -1 do
                    position = position + shape:getAt() * (y / 4 - 0.125)
                    for z = box.z * 2, box.z * -2 + 1, -1 do
                        position = position + shape:getUp() * (z / 4 - 0.125)
                        local dif = position - center
                        dif = dif:localize(bodyMOIs[body.id].shape)
                        bodyMOIs[body.id].inertia.xx = bodyMOIs[body.id].inertia.xx + mass * (dif.y * dif.y + dif.z * dif.z)
                        bodyMOIs[body.id].inertia.yy = bodyMOIs[body.id].inertia.yy + mass * (dif.x * dif.x + dif.z * dif.z)
                        bodyMOIs[body.id].inertia.zz = bodyMOIs[body.id].inertia.zz + mass * (dif.x * dif.x + dif.y * dif.y)
                        bodyMOIs[body.id].inertia.xy = bodyMOIs[body.id].inertia.xy - mass * dif.x * dif.y
                        bodyMOIs[body.id].inertia.yz = bodyMOIs[body.id].inertia.yz - mass * dif.y * dif.z
                        bodyMOIs[body.id].inertia.xz = bodyMOIs[body.id].inertia.xz - mass * dif.x * dif.z
                    end
                end
            end
        end
        bodyMOIs[body.id].tick = sm.game.getCurrentTick()
    end
    return in_axis.x * (in_axis.x * bodyMOIs[body.id].inertia.xx + in_axis.y * bodyMOIs[body.id].inertia.xy + in_axis.z * bodyMOIs[body.id].inertia.xz) + in_axis.y * (in_axis.x * bodyMOIs[body.id].inertia.xy + in_axis.y * bodyMOIs[body.id].inertia.yy + in_axis.z * bodyMOIs[body.id].inertia.yz) + in_axis.z * (in_axis.x * bodyMOIs[body.id].inertia.xz + in_axis.y * bodyMOIs[body.id].inertia.yz + in_axis.z * bodyMOIs[body.id].inertia.zz)
end

-- Creation's moment of inertia
--WHY WOULD ANYONE EVER NEED THIS
--YOU CAN'T APPLY TORQUE TO A WHOLE VEHICLE AT ONE TIME ANYWAYS
--ALSO !RESOURCE INTENSIVE!
function sm.body.getCreationMOI(in_body, in_axis)
    local shapes = in_body:getShapes()
    in_axis = in_axis:localize(shapes[1])
    in_axis = in_axis:normalize()
    local inertia = {
		xx = 0,
		yy = 0,
		zz = 0,
		xy = 0,
		yz = 0,
		xz = 0
	}
    for i, body in pairs(in_body:getCreationBodies()) do
        local shapes = body:getShapes()
        for n, shape in pairs(shapes) do
            local center = sm.body.getCOM(body)
            local box = shape:getBoundingBox()
            local mass = shape.mass / (box.x * 4 * box.y * 4 * box.z * 4)
            local pos = shape:getWorldPosition()
            for x = box.x * 2, box.x * -2 + 1, -1 do
                local position = pos + shape:getRight() * (x / 4 - 0.125)
                for y = box.y * 2, box.y * -2 + 1, -1 do
                    position = position + shape:getAt() * (y / 4 - 0.125)
                    for z = box.z * 2, box.z * -2 + 1, -1 do
                        position = position + shape:getUp() * (z / 4 - 0.125)
                        local dif = position - center
                        dif = dif:localize(shapes[1])
                        inertia.xx = inertia.xx + mass * (dif.y * dif.y + dif.z * dif.z)
                        inertia.yy = inertia.yy + mass * (dif.x * dif.x + dif.z * dif.z)
                        inertia.zz = inertia.zz + mass * (dif.x * dif.x + dif.y * dif.y)
                        inertia.xy = inertia.xy - mass * dif.x * dif.y
                        inertia.yz = inertia.yz - mass * dif.y * dif.z
                        inertia.xz = inertia.xz - mass * dif.x * dif.z
                    end
                end
            end
        end
    end
    return in_axis.x * (in_axis.x * inertia.xx + in_axis.y * inertia.xy + in_axis.z * inertia.xz) + in_axis.y * (in_axis.x * inertia.xy + in_axis.y * inertia.yy + in_axis.z * inertia.yz) + in_axis.z * (in_axis.x * inertia.xz + in_axis.y * inertia.yz + in_axis.z * inertia.zz)
end

table.insert(
	sm.__SE_UserDataImprovements_Server, 
	function(self)
		self.shape:getBody().getCOM = sm.body.getCOM
		self.shape:getBody().getCreationCOM = sm.body.getCreationCOM
		self.shape:getBody().getMOI = sm.body.getMOI
		self.shape:getBody().getCreationMOI = sm.body.getCreationMOI
	end
)

print("Bodies library loading...")

if (not sm.body.COM) then sm.body.COM = {} end

-- Body's center of mass
function sm.body.getCOM(body)
    if (not sm.body.COM[body.id]) then sm.body.COM[body.id] = {} end
    -- First iteration or change detected
    if ((not sm.body.COM[body.id].tick)or((sm.body.COM[body.id].tick < sm.game.getCurrentTick())and(sm.body.hasChanged(body, sm.body.COM[body.id].tick)))or(not sm.exists(sm.body.COM[body.id].shape))) then
        if (not sm.body.COM[body.id].body) then sm.body.COM[body.id].body = body end -- AUTO DELETE
        local shapes = body:getShapes()
        sm.body.COM[body.id].shape = shapes[1]
        local mass = 0
        local center = sm.vec3.new(0, 0, 0)
        for i, shape in pairs(shapes) do
            center = center + shape:getWorldPosition() * shape:getMass()
            mass = mass + shape:getMass()
        end
        center = center * (1 / mass) --VectorBug
        local displacement = center - sm.body.COM[body.id].shape:getWorldPosition()
        sm.body.COM[body.id].vector = displacement:localize(sm.body.COM[body.id].shape)
        sm.body.COM[body.id].tick = sm.game.getCurrentTick()
        return center
    end
    return sm.body.COM[body.id].shape:getWorldPosition() + sm.body.COM[body.id].vector:delocalize(sm.body.COM[body.id].shape)
end

-- Vehicle's center of mass
function sm.body.getCreationCOM(in_body)
    local bodies = in_body:getCreationBodies()
    local mass = 0
    local center = sm.vec3.new(0, 0, 0)
    for i, body in pairs(bodies) do
        center = center + body:getCOM() * body.mass
        mass = mass + body.mass
    end
    center = center * (1 / mass) --VectorBug
    return center
end

if (not sm.body.MOI) then sm.body.MOI = {} end

-- Creation's moment of inertia
function sm.body.getMOI(body, in_axis)
    if (not sm.body.MOI[body.id]) then sm.body.MOI[body.id] = {} end
    if (not sm.body.MOI[body.id].inertia) then sm.body.MOI[body.id].inertia = {} end
    if (not sm.body.MOI[body.id].tick) then sm.body.MOI[body.id].tick = 0 end
    if (not sm.body.MOI[body.id].body) then sm.body.MOI[body.id].body = body end -- AUTO DELETE
    local shapes = body:getShapes()
    sm.body.MOI[body.id].shape = shapes[1]
    in_axis = in_axis:localize(sm.body.MOI[body.id].shape)
    in_axis = in_axis:normalize()
    if ((not sm.body.MOI[body.id].tick)or(sm.body.hasChanged(body, sm.body.MOI[body.id].tick))) then
        sm.body.MOI[body.id].inertia.xx = 0
        sm.body.MOI[body.id].inertia.yy = 0
        sm.body.MOI[body.id].inertia.zz = 0
        sm.body.MOI[body.id].inertia.xy = 0
        sm.body.MOI[body.id].inertia.yz = 0
        sm.body.MOI[body.id].inertia.xz = 0
        for i, shape in pairs(shapes) do
            local center = body:getCOM()
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
                        dif = dif:localize(sm.body.MOI[body.id].shape)
                        sm.body.MOI[body.id].inertia.xx = sm.body.MOI[body.id].inertia.xx + mass * (dif.y * dif.y + dif.z * dif.z)
                        sm.body.MOI[body.id].inertia.yy = sm.body.MOI[body.id].inertia.yy + mass * (dif.x * dif.x + dif.z * dif.z)
                        sm.body.MOI[body.id].inertia.zz = sm.body.MOI[body.id].inertia.zz + mass * (dif.x * dif.x + dif.y * dif.y)
                        sm.body.MOI[body.id].inertia.xy = sm.body.MOI[body.id].inertia.xy - mass * dif.x * dif.y
                        sm.body.MOI[body.id].inertia.yz = sm.body.MOI[body.id].inertia.yz - mass * dif.y * dif.z
                        sm.body.MOI[body.id].inertia.xz = sm.body.MOI[body.id].inertia.xz - mass * dif.x * dif.z
                    end
                end
            end
        end
        sm.body.MOI[body.id].tick = sm.game.getCurrentTick()
    end
    return in_axis.x * (in_axis.x * sm.body.MOI[body.id].inertia.xx + in_axis.y * sm.body.MOI[body.id].inertia.xy + in_axis.z * sm.body.MOI[body.id].inertia.xz) + in_axis.y * (in_axis.x * sm.body.MOI[body.id].inertia.xy + in_axis.y * sm.body.MOI[body.id].inertia.yy + in_axis.z * sm.body.MOI[body.id].inertia.yz) + in_axis.z * (in_axis.x * sm.body.MOI[body.id].inertia.xz + in_axis.y * sm.body.MOI[body.id].inertia.yz + in_axis.z * sm.body.MOI[body.id].inertia.zz)
end

-- Creation's moment of inertia
--WHY WOULD ANYONE EVER NEED THIS
--YOU CAN'T APPLY TORQUE TO A WHOLE VEHICLE AT ONE TIME ANYWAYS
--ALSO !RESOURCE INTENSIVE!
function sm.body.getCreationMOI(in_body, in_axis)
    local inertia = {}
    local shapes = in_body:getShapes()
    in_axis = in_axis:localize(shapes[1])
    in_axis = in_axis:normalize()
    inertia.xx = 0
    inertia.yy = 0
    inertia.zz = 0
    inertia.xy = 0
    inertia.yz = 0
    inertia.xz = 0
    for i, body in pairs(in_body:getCreationBodies()) do
        local shapes = body:getShapes()
        for n, shape in pairs(shapes) do
            local center = body:getCOM()
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

table.insert(sm.scrap_essentials, function(self)
	self.shape:getBody().getCOM = function(body) return sm.body.getCOM(body) end
	self.shape:getBody().getCreationCOM = function(body) return sm.body.getCreationCOM(body) end
	self.shape:getBody().getMOI = function(body, param1) return sm.body.getMOI(body, param1) end
	self.shape:getBody().getCreationMOI = function(body, param1) return sm.body.getCreationMOI(body, param1) end
end)

print("Succesfully loaded.")
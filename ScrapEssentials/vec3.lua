print("Vectors library loading...")

-- Working normalize
function sm.vec3.normalize(vec) return vec:length2() == 0 and vec or vec * ( 1 / vec:length()) end --VectorBug
-- Parallel element
function sm.vec3.parallel(vec1, vec2) local vec = vec2:normalize() return vec * vec:dot(vec1) end
-- Tangent element
function sm.vec3.tangent(vec1, vec2) local vec = vec2:normalize() return vec1 - vec * vec:dot(vec1) end
-- Localize
function sm.vec3.localize(vec, shape) return sm.vec3.new(shape:getRight():dot(vec), shape:getAt():dot(vec), shape:getUp():dot(vec)) end
-- Delocalize
function sm.vec3.delocalize(vec, shape) return shape:getRight() * vec.x + shape:getAt() * vec.y + shape:getUp() * vec.z end
-- Random direction vector
function sm.vec3.random() local angle = sm.noise.randomRange(0, 2 * math.pi) local z = sm.noise.randomRange(-1, 1) local temp = math.sqrt(1 - z*z) return sm.vec3.new(temp * math.cos(angle), temp * math.sin(angle), z) end

sm.vec3.new(0,0,0).normalize = sm.vec3.normalize
sm.vec3.new(0,0,0).parallel = sm.vec3.parallel
sm.vec3.new(0,0,0).tangent = sm.vec3.tangent
sm.vec3.new(0,0,0).localize = sm.vec3.localize
sm.vec3.new(0,0,0).delocalize = sm.vec3.delocalize

print("Succesfully loaded.")
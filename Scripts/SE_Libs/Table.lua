local version = 1

if (sm.__SE_Version._Table or 0) >= version then return end
sm.__SE_Version._Table = version

print("Loading extra table stuff")

-- get table size
function table.size( someTable ) local i = 0 for k, v in pairs(someTable) do i = i + 1 end return i end

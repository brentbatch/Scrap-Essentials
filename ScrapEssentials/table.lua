print("extra table stuff loaded")

-- get table size
function table.size( someTable ) local i = 0 for k, v in pairs(someTable) do i = i + 1 end return i end

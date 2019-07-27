local version = 1.0

-- Prefix: sm.table.

-- Commands:
	-- length(table) -- Returns the length of the table
	-- copyTable(table) -- Returns a copy of the table
	-- addToTable(table, table) -- Adds elements of second table to the first table





--[[
	Copyright (c) 2019 Scrap Essentials Team
]]--

-- Version check
if sm.__SE_Version.table and version <= sm.__SE_Version.table then return end



-- get table size
function table.size( table1 )
	assert(type(table1) == "table", "length: argument 1, table expected! got: "..type(table1))
	if(table1) then
		local i = 0
		for k, v in pairs(table1) do i = i + 1 end
		return i
	end
	return 0
end

-- copy table
function table.copyTable( table1 )
	assert(type(table1) == "table", "copyTable: argument 1, table expected! got: "..type(table1))
	local out = {}
	if(table1) then
		for a, b in pairs(table1) do out[a] = b end
	end
	return out
end

-- add table
function table.addToTable( table1, table2 )
	assert(type(table1) == "table", "addToTable: argument 1, table expected! got: "..type(table1))
	assert(type(table2) == "table", "addToTable: argument 2, table expected! got: "..type(table2))
	if(table2) then
		for _, e in pairs(table2) do table.insert(table1, e) end
	end
	return table1
end



sm.__SE_Version.table = version
print("'table' library version "..tostring(version).." successfully loaded.")
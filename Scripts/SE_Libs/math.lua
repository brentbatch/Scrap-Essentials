local version = 1.0

-- Prefix: math.

-- Commands:
-- sign(number) - Returns the 1 if number is positive, -1 if negative, 0 if 0
-- round(number, <trailling digits>) - Rounds the number, possibly set the amount of trailling digits, can be negative
-- minIndex(table of numbers) - Returns the index of the biggest number
-- maxIndex(table of numbers) - Returns the index of the smallest number
-- div(dividend, divisor) - Integer division
-- mod(dividend, divisor) - Integer division remainder





--[[
	Copyright (c) 2019 Scrap Essentials Team
]]--

-- Version check
if sm.__SE_Version.math and version <= sm.__SE_Version.math then return end



-- get the sign of a number, -1, 0, 1
function math.sign( number1 )
	assert(type(number1) == "number", "sign: argument 1, number expected! got: "..type(number1))
	return number1 > 0 and 1 or number1 < 0 and -1 or 0
end

-- round, additionally choose with how many trailing digits
function math.round( number1, td )
	td = td or 0
	assert(type(number1) == "number", "round: argument 1, number expected! got: "..type(number1))
	assert(type(td) == "number", "round: argument 2, number expected! got: "..type(td))
	return math.floor((number1 * math.pow(10, td)) + 0.5) / math.pow(10, td)
end

-- max value in a table
function math.maxIndex( numbers )
	assert(type(numbers) == "table", "maxIndex: argument 1, table expected! got: "..type(numbers))
	local max = math.max( numbers )
	for i, number in pairs(numbers) do
		if(number == max) then return i end
	end
end

-- min value in a table
function math.minIndex( numbers )
	assert(type(numbers) == "table", "minIndex: argument 1, table expected! got: "..type(numbers))
	local min = math.min( numbers )
	for i, number in pairs(numbers) do
		if(number == min) then return i end
	end
end

function math.div( number1, number2 )
	assert(type(number1) == "number", "div: argument 1, number expected! got: "..type(number1))
	assert(type(number2) == "number", "div: argument 2, number expected! got: "..type(number2))
	return math.floor(number1 / number2)
end

function math.mod( number1, number2 )
	assert(type(number1) == "number", "mod: argument 1, number expected! got: "..type(number1))
	assert(type(number2) == "number", "mod: argument 2, number expected! got: "..type(number2))
	return number1 - math.floor(number1 / number2) * number2
end



sm.__SE_Version.math = version
print("'math' library version "..tostring(version).." successfully loaded.")
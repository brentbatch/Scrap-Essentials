print("Math library loading...")

-- get the sign of a number, -1, 0, 1
function math.sign( number ) return number > 0 and 1 or number < 0 and -1 or 0 end

-- round, additionally choose at how many decimal points
function math.round( number, decimals ) decimals = decimals or 0 return math.floor(( (number * math.pow(10, decimals) ) + 0.5 ) - 0.5) / math.pow(10, decimals) end

-- max value in a table
function math.indexmax( numbers ) local index for i, number in pairs(numbers) do if(not index) then index = i end if( numbers[index] < number ) then index = i end end return index end

-- min value in a table
function math.indexmin( numbers ) local index for i, number in pairs(numbers) do if(not index) then index = i end if( numbers[index] > number ) then index = i end end return index end

print("Succesfully loaded.")
local version = 1.0

-- Prefix: sm.color.

-- Commands:
	--match(rgba) - Matches the paint gun colors to numbers (1-40)
	--toRGB(hsv) - Turns HSV to RGB
	--toHSV(rgba) - Turns RGB to HSV

-- Improved:
	--color:match()
	--color:toHSV()





--[[
	 Copyright (c) 2019 Scrap Essentials Team
]]--

-- Version check
if sm.__SE_Version.color and version <= sm.__SE_Version.color then return end



--Matches any color with a group
sm.color.match = function(rgba)
	assert(type(rgba) == "Color", "match: argument 1, Color expected! got: "..type(rgba))
	local match = 
	{
		["eeeeeeff"] = 1,
		["f5f071ff"] = 2,
		["cbf66fff"] = 3,
		["68ff88ff"] = 4,
		["7eededff"] = 5,
		["4c6fe3ff"] = 6,
		["ae79f0ff"] = 7,
		["ee7bf0ff"] = 8,
		["f06767ff"] = 9,
		["eeaf5cff"] = 10,

		["7f7f7fff"] = 11,
		["e2db13ff"] = 12,
		["a0ea00ff"] = 13,
		["19e753ff"] = 14,
		["2ce6e6ff"] = 15,
		["0a3ee2ff"] = 16,
		["7514edff"] = 17,
		["cf11d2ff"] = 18,
		["d02525ff"] = 19,
		["df7f00ff"] = 20,

		["4a4a4aff"] = 21,
		["817c00ff"] = 22,
		["577d07ff"] = 23,
		["0e8031ff"] = 24,
		["118787ff"] = 25,
		["0f2e91ff"] = 26,
		["500aa6ff"] = 27,
		["720a74ff"] = 28,
		["7c0000ff"] = 29,
		["673b00ff"] = 30,

		["222222ff"] = 31,
		["323000ff"] = 32,
		["375000ff"] = 33,
		["064023ff"] = 34,
		["0a4444ff"] = 35,
		["0a1d5aff"] = 36,
		["35086cff"] = 37,
		["520653ff"] = 38,
		["560202ff"] = 39,
		["472800ff"] = 40
	}

	return match[tostring(rbga)]
end

--RGB to HSV converter
function sm.color.toHSV( rgba )
	assert(type(rgba) == "Color", "toHSV: argument 1, Color expected! got: "..type(rgba))

	local __HSV_Cases = {
		["r"] = function( rgb, delta ) return 60 * (((rgb.g - rgb.b) / delta) % 6) end
		["g"] = function( rgb, delta ) return 60 * (((rgb.b - rgb.r) / delta) + 2) end
		["b"] = function( rgb, delta ) return 60 * (((rgb.r - rgb.g) / delta) + 4) end
	}

	local rgb = { r = rgba.r, g = rgba.g, b = rgba.b }
	local max = math.maxIndex(rgb)
	local min = math.minIndex(rgb)
	local delta = rgb[max] - rgb[min]
	local hsv = { h, s, v }
	--Hue
	if(delta == 0) then hsv.h = 0 else
	hsv.h = __HSV_Cases[max](rgb, delta) end
	--Saturation
	if(rgb[max] == 0) then hsv.s = 0 else
	hsv.s = (delta / rgb[max]) end
	--Value
	hsv.v = rgb[max]
	return hsv
end

--HSV to RGB converter
function sm.color.toRGB( hsv )
	assert(type(hsv) == "table" and hsv.h ~= nil and hsv.s ~= nil and hsv.v ~= nil, "toRGB: argument 1, HSV expected! got: "..type(hsv))

	local __RGB_Cases = {
		[0] = function( C, X ) return { r = C, g = X, b = 0 } end
		[1] = function( C, X ) return { r = X, g = C, b = 0 } end
		[2] = function( C, X ) return { r = 0, g = C, b = X } end
		[3] = function( C, X ) return { r = 0, g = X, b = C } end
		[4] = function( C, X ) return { r = X, g = 0, b = C } end
		[5] = function( C, X ) return { r = C, g = 0, b = X } end
	}

	local C = hsv.v * hsv.s
	local X = C * ( 1 - math.abs( ((hsv.h / 60) % 2) - 1 ) )
	local M = hsv.v - C
	local H = math.floor( hsv.h / 60 ) % 6
	local rgb = __RGB_Cases[H]( C, X )
	return sm.color.new(rgb.r + M, rgb.g + M, rgb.b + M)
end

sm.color.new(0,0,0).match = sm.color.match
sm.color.new(0,0,0).toHSV = sm.color.toHSV



sm.__SE_Version.color = version
print("'color' library version "..tostring(version).." successfully loaded.")
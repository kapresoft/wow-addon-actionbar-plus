--[[-----------------------------------------------------------------------------
DEPENDENCIES:
-------------------------------------------------------------------------------]]
local CreateColorFromHexString = CreateColorFromHexString
local CreateColorFromRGBAHexString = CreateColorFromRGBAHexString
local CreateColorFromRGBHexString = CreateColorFromRGBHexString

--[[-----------------------------------------------------------------------------
VERSION:: Bump MINOR_VERSION whenever a change occurs
-- 1: initial version

-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'Kapresoft-ColorFormatter-2-0', 2

--- @class Kapresoft-ColorFormatter-2-0
local S = LibStub:NewLibrary(MAJOR, MINOR); if not S then return end
local mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR]  end }
setmetatable(S, mt)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local o = S

o.COLOR_FORMAT_RGBA = "RRGGBBAA";
o.COLOR_FORMAT_RGB = "RRGGBB";
o.COLOR_FORMAT_ARGB = "AARRGGBB";

--- Create a new color formatter function.
--- ```
--- Examples:
--- cfn = ColorFormatter:ColorFn(RED_THREAT_COLOR)
--- cfn = ColorFormatter:ColorFn('565656fc')
--- cfn = ColorFormatter:ColorFn('565656')
--- cfn = ColorFormatter:ColorFn('fc565656')
---
--- print('Say:', cfn('Hello'))  -- prints in color
--- ```
--- @param color colorRGBA|HexRGBA|HexRGB|HexRGBA @ RED_THREAT_COLOR | '565656fc' | '565656' | 'fc565656'
--- @return cfFn, colorRGBA?
function o:ColorFn(color)
  assertsafe(color, "ColorFormatter:ColorFn(color): The function arg color is a required field, but was [%s]", tostring(color))
  local c = color
  if type(c) == 'string' then c = self:ColorFromHex(color) end
  assertsafe(color, "ColorFormatter:ColorFn(color): Could not resolve color from [%s], type=[%]", tostring(c), type(c))
  return function(arg) return c:WrapTextInColorCode(tostring(arg)) end
end

--- ```
--- Examples:
--- color = ColorFormatter:ColorFromHex('565656')
--- color = ColorFormatter:ColorFromHex('fc565656')
---
--- print('Say:', color:WrapTextInColorCode('Hello'))  -- prints in color
--- ```
--- @param hexColor HexRGB|HexARGB | '565656' | 'fc565656'
--- @return colorRGBA
function o:ColorFromHex(hexColor)
  assertsafe(hexColor, "ColorFromHex(hexColorRBA): {hexColor} should be a string, but was [%s]",
    type(hexColor))
  local color = self:_ColorFromHexARGB(hexColor)
  if not color then
    color = self:_ColorFromHexRGB(hexColor)
  end
  assert(type(color) == 'table', 'ColorFromHex(hexColor): {hexColor} is invalid: ' .. tostring(hexColor))
  return color
end

--- @private
--- @param hexColorARGB? HexARGB | 'fc565656'
function o:_ColorFromHexARGB(hexColorARGB)
  if #hexColorARGB == #o.COLOR_FORMAT_ARGB then
    local a, r, g, b = ExtractColorValueFromHex(hexColorARGB, 1), ExtractColorValueFromHex(hexColorARGB, 3),
        ExtractColorValueFromHex(hexColorARGB, 5), ExtractColorValueFromHex(hexColorARGB, 7);
    return CreateColor(r, g, b, a);
  end
  return nil;
end
--- @private
--- @param hexColor HexRGBA|HexRGB | '565656fc' | '565656'
--- @return colorRGBA?
function o:_ColorFromHexRGB(hexColorRGB)
	if #hexColorRGB == #o.COLOR_FORMAT_RGB then
  		local r, g, b = ExtractColorValueFromHex(hexColorRGB, 1), ExtractColorValueFromHex(hexColorRGB, 3),
  		  ExtractColorValueFromHex(hexColorRGB, 5);
  		return CreateColor(r, g, b, 1);
  	end
	return nil;
end

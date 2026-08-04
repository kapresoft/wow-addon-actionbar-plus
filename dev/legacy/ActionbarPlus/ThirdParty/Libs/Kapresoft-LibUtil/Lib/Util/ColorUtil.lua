--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Kapresoft_Base_Namespace
local ns = select(2, ...)
local sformat = string.format
local K = ns.Kapresoft_LibUtil
local LibStub = K.LibStub
local ModuleName = K.M.ColorUtil()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class Kapresoft_LibUtil_ColorUtil
local L = LibStub:NewLibrary(ModuleName, 2); if not L then return end

--- @class ColorUtilMixin
local ColorUtilMixin = {}; do
    --- @type ColorUtilMixin
    local o = ColorUtilMixin

    --- Usage: local colorUtil = CreateAndInitFromMixin(ColorUtilMixin, BLUE_FONT_COLOR)
    --- @private
    --- @param color Color
    function o:Init(color)
        assert(color, 'Init(): Color is required.')
        self.color = color
    end

    --- Formatter
    --- @return fun(arg:any) : string The string wrapped in color code
    function o:f()
        return function(arg) return self.color:WrapTextInColorCode(tostring(arg)) end
    end

    -- Backwards compatibility with classic
    if not o.GetRGBA then
        function o:GetRGBA() return self.color.r, self.color.g, self.color.b, self.color.a; end
    end

end

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
-- Backwards compatibility with classic
local COLOR_FORMAT_RGBA = COLOR_FORMAT_RGBA or "RRGGBBAA";
-- Backwards compatibility with classic
local function xCreateColorFromRGBAHexString(hexColor)
    if #hexColor == #COLOR_FORMAT_RGBA then
        local r, g, b, a = ExtractColorValueFromHex(hexColor, 1), ExtractColorValueFromHex(hexColor, 3), ExtractColorValueFromHex(hexColor, 5), ExtractColorValueFromHex(hexColor, 7);
        return CreateColor(r, g, b, a);
    else
        error("ColorUtil: CreateColorFromHexString input must be hexadecimal digits in this format: RRGGBBAA.", 2);
    end
end
local CreateColorFromRGBAHexString = CreateColorFromRGBAHexString or xCreateColorFromRGBAHexString

--[[-----------------------------------------------------------------------------
Methods: Kapresoft_LibUtil_ColorUtil
-------------------------------------------------------------------------------]]
--- @class ColorUtil : ColorUtilMixin

--- @param RRGGBBAA HexColor | "'fc565656'"
--- @return ColorUtil
function L:NewColorFromHex(RRGGBBAA)
    --- @type Color
    local c = CreateColorFromRGBAHexString(RRGGBBAA)
    assert(c, sformat('Invalid color: %s. example: %s', RRGGBBAA, COLOR_FORMAT_RGBA))
    return CreateAndInitFromMixin(ColorUtilMixin, c)
end

--- @param color Color | "BLUE_FONT_COLOR"
--- @return ColorUtil
function L:NewColor(color)
    return CreateAndInitFromMixin(ColorUtilMixin, color)
end

--- @param r RGBColor 0.0 to 1.0
--- @param g RGBColor 0.0 to 1.0
--- @param b RGBColor 0.0 to 1.0
--- @param a Alpha|nil 0.0 to 1.0
--- @return fun(arg:any) : string The string wrapped in color code
function L:NewFormatterFromRGB(r, g, b, a)
    local color = CreateColor(r, g, b, a)
    return function(arg) return color:WrapTextInColorCode(tostring(arg)) end
end

--- @param RRGGBBAA HexColor | "'fc565656'"
--- @return fun(arg:any) : string The string wrapped in color code
function L:NewFormatterFromHex(RRGGBBAA)
    local colorUtil = self:NewColorFromHex(RRGGBBAA)
    --- @param arg any
    --- @return fun(arg:any) : string The string wrapped in color code
    return function(arg) return colorUtil.color:WrapTextInColorCode(tostring(arg)) end
end

--- @param color Color
--- @return fun(arg:any) : string The string wrapped in color code
function L:NewFormatterFromColor(color)
    --- @param arg any
    return function(arg) return color:WrapTextInColorCode(tostring(arg)) end
end


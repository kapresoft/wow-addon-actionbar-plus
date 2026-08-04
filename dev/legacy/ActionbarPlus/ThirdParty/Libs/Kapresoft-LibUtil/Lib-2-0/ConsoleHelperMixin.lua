--[[-----------------------------------------------------------------------------
VERSION:: Bump MINOR_VERSION whenever a change occurs
-- 1: initial version
-- 2: EmmyLua2 update
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'Kapresoft-ConsoleHelperMixin-2-0', 1

--- @class Kapresoft-ConsoleHelperMixin-2-0
local S = LibStub:NewLibrary(MAJOR, MINOR); if not S then return end
local mt = { __tostring = function() return MAJOR .. '.' .. LibStub.minors[MAJOR] end }
setmetatable(S, mt)

local failSafeColorRGB = 'FFFFFF'
local failSafeColor = CreateColorFromRGBHexString(failSafeColorRGB)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local sformat = string.format

--- @param color string
--- @param text string
local function StringHexFormatter(color, text)
  return sformat('|cfd%s%s|r', color or failSafeColorRGB, text)
end

--- @param color colorRGBA
--- @param text string
local function BlizzardColorFormatter(color, text)
  return (color or failSafeColor):WrapTextInColorCode(text)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local o = S


--- @param colorDef Kapresoft-ColorDefinition-2-0
function o:Init(colorDef)
    self.colorDef = colorDef
    self.colorDef.formatter = BlizzardColorFormatter
end

--- @param color string|colorRGBA The hex color without the '#', i.e "0xfff000" would be "fff000"
--- @param text string The text to format
function o:FormatColor(color, text) return self.colorDef.formatter(color, text) end

--- @param text string The text to format
function o:P(text) return self:FormatColor(self.colorDef.primary, text)  end

--- @param text string The text to format
function o:S(text) return self:FormatColor(self.colorDef.secondary, text)  end

--- @param text string The text to format
function o:T(text) return self:FormatColor(self.colorDef.tertiary, text)  end

--- Generate the colorized Log Prefix
--- @param module string The module name
--- @param subPrefix string Defaults to the addOn name
function o:CreateLogPrefix(module, subPrefix)
    local addOnPrefix
    if subPrefix then
        addOnPrefix = subPrefix
    elseif ns and ns.nameShort then
        addOnPrefix = ns.nameShort
    elseif addOn then
        addOnPrefix = addOn
    end
    return self.sformat(
            self:T('{{') .. '%s::%s::%s' .. self:T('}}:'),
            self:P(addOnPrefix), self:P(nameShort), self:S(module))
end

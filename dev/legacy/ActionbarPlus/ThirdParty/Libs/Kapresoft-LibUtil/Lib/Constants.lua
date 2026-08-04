-- Standalone and should not have any dependencies

--[[-----------------------------------------------------------------------------
Debugging
-------------------------------------------------------------------------------]]
Kapresoft_LibUtil_LogLevel_LibWrapper = 0
Kapresoft_LibUtil_LogLevel_LibFactory = 0
Kapresoft_LibUtil_LogLevel_LibStub = 0

local addOn, ns = ...

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub = LibStub
local nameShort = 'KL'
local logPrefix = 'Kapresoft-LibUtil::Init:'

--[[-----------------------------------------------------------------------------
Support Functions: Console Colors
-------------------------------------------------------------------------------]]
--- @type Kapresoft_LibUtil_ColorDefinition
local consoleColors = {
    primary   = 'e3caaf',
    secondary = 'fbeb2d',
    tertiary = 'ffffff'
}
local failSafeColorHex6 = 'FFFFFF'
local failSafeColor = CreateColorFromHexString('ff' .. failSafeColorHex6)
--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- @class Kapresoft_LibUtil_Constants
local L = LibStub:NewLibrary('Kapresoft-LibUtil-Constants-1.0', 3); if not L then return end

---@param color string
---@param text string
local function StringHexFormatter(color, text) return sformat('|cfd%s%s|r', color or failSafeColorHex6, text) end

---@param color Color
---@param text string
local function BlizzardColorFormatter(color, text) return (color or failSafeColor):WrapTextInColorCode(text) end

--[[-----------------------------------------------------------------------------
Support Types & Functions
-------------------------------------------------------------------------------]]
--- @class Kapresoft_LibUtil_ConsoleHelperMixin
local ConsoleHelperMixin = {
    sformat = string.format,

    --- @param self Kapresoft_LibUtil_ConsoleHelperMixin
    --- @param colorDef Kapresoft_LibUtil_ColorDefinition | Kapresoft_LibUtil_ColorDefinition2
    Init = function(self, colorDef)
        self.colorDef = colorDef
        if type(self.colorDef.primary) == 'string' then
            self.colorDef.formatter = StringHexFormatter
        else
            self.colorDef.formatter = BlizzardColorFormatter
        end
    end,

    --- @param self Kapresoft_LibUtil_ConsoleHelperMixin
    --- @param color string|Color The hex color without the '#', i.e "0xfff000" would be "fff000"
    --- @param text string The text to format
    FormatColor = function(self, color, text) return self.colorDef.formatter(color, text) end,

    --- @param self Kapresoft_LibUtil_ConsoleHelperMixin
    --- @param text string The text to format
    P = function(self, text) return self:FormatColor(self.colorDef.primary, text)  end,

    --- @param self Kapresoft_LibUtil_ConsoleHelperMixin
    --- @param text string The text to format
    S = function(self, text) return self:FormatColor(self.colorDef.secondary, text)  end,

    --- @param self Kapresoft_LibUtil_ConsoleHelperMixin
    --- @param text string The text to format
    T = function(self, text) return self:FormatColor(self.colorDef.tertiary, text)  end,

    --- Generate the colorized Log Prefix
    --- @param module string The module name
    --- @param self Kapresoft_LibUtil_ConsoleHelperMixin
    --- @param subPrefix string Defaults to the addOn name
    CreateLogPrefix = function(self, module, subPrefix)
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
    end,
}
---@param label string Optional label
local function GetExpectedIsTypeMessageFormat(label)
    local padding = ' '
    local msgFormat = "\n" .. padding ..
            '   Expecting actual object type: %s\n' .. padding ..
            '                        but was: %s'
    if label then msgFormat = '{{ ' .. label .. ' }}' .. msgFormat end
    return msgFormat
end
--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o Kapresoft_LibUtil_Constants
local function PropertiesAndMethods(o)

    --- @param colorDef Kapresoft_LibUtil_ColorDefinition | Kapresoft_LibUtil_ColorDefinition2
    --- @return Kapresoft_LibUtil_ConsoleHelper
    function o:NewConsoleHelper(colorDef) return self:CreateAndInitFromMixin(ConsoleHelperMixin, colorDef) end

    --- ```
    --- local SomeMixin1 = {}
    --- local object = {}
    --- sameReturnedObject = Mixin(object, SomeMixin1, SomeMixinN)
    --- // or
    --- local object = Mixin({}, SomeMixin1, SomeMixinN)
    --- ```
    --- @param object any The target object of which mixins will be applied to
    function o:Mixin(object, ...)
        for i = 1, select("#", ...) do
            local mixin = select(i, ...);
            for k, v in pairs(mixin) do
                object[k] = v;
            end
        end
        return object;
    end

    --- @vararg any The mixins as arguments
    function o:CreateFromMixins(...) return self:Mixin({}, ...) end

    --- @param mixin any The mixin
    --- @vararg any The arguments to pass to the new instance Init() method
    function o:CreateAndInitFromMixin(mixin, ...)
        local object = self:CreateFromMixins(mixin)
        object:Init(...);
        return object;
    end

    function o:TableSize(t)
        if type(t) ~= 'table' then error(string.format("Expected arg to be of type table, but got: %s", type(t))) end
        local count = 0
        for _ in pairs(t) do count = count + 1 end
        return count
    end

    --- @param actualObj any The actual value
    --- @param expectedType string | "'string'" | "'number'"  | "'function'"  | "'table'" | "The expected type, i.e., 'string', 'table'"
    --- @param label string The optional string prefix label
    function o:AssertType(actualObj, expectedType, label)
        local msgFormat = GetExpectedIsTypeMessageFormat(label)
        local msg = sformat(msgFormat, expectedType, type(actualObj))
        assert(expectedType == type(actualObj), msg)
    end
end

PropertiesAndMethods(L)

--- @type Kapresoft_LibUtil_ConsoleHelper
K_ConsoleHelper = L:CreateAndInitFromMixin(ConsoleHelperMixin, consoleColors)
--- @type Kapresoft_LibUtil_Constants
K_Constants = L

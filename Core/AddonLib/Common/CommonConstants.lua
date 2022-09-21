if type(ABP_PLUS_DB) ~= "table" then ABP_PLUS_DB = {} end
if type(ABP_LOG_LEVEL) ~= "number" then ABP_LOG_LEVEL = 1 end
if type(ABP_DEBUG_MODE) ~= "boolean" then ABP_DEBUG_MODE = false end

--[[-----------------------------------------------------------------------------
Global Vars
-------------------------------------------------------------------------------]]
ABP_PREFIX = '|cfdffffff{{|r|cfd2db9fbActionBarPlus|r|cfdfbeb2d%s|r|cfdffffff}}|r'
ABP_PLUS_DB_NAME = 'ABP_PLUS_DB'
VERSION_FORMAT = 'ActionbarPlus-%s-1.0'

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub, Core, O = __K_Core:LibPack()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class CommonConstantsBase
local _L = {
    GetLogLevel = function()
        return ABP_LOG_LEVEL
    end,
    ---@param level number The log level between 1 and 100
    SetLogLevel = function(level)
        ABP_LOG_LEVEL = level or 1
    end
}
---@class CommonConstants : CommonConstantsBase
_L = LibStub:NewLibrary(Core.M.CommonConstants)

---@deprecated
---@type CommonConstants
--TODO: NEXT: Deprecate ABP_CommonConstants
ABP_CommonConstants = _L

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@class UnitAttributes
_L.UnitAttributes = {
    FOCUS = 'focus'
}

---@class WidgetAttributes
local WidgetAttributes = {
    TYPE = 'type',
    UNIT = 'unit',
    SPELL = 'spell',
    ITEM = 'item',
    MOUNT = 'mount',
    FLY_OUT = 'flyout',
    PET_ACTION = 'petaction',
    MACRO_TEXT = "macrotext",
    MACRO = "macro",
}

---@class ButtonAttributes
local ButtonAttributes = {
    SPELL = WidgetAttributes.SPELL,
    UNIT = WidgetAttributes.UNIT,
    UNIT2 = format("*%s2", WidgetAttributes.UNIT),
    TYPE = WidgetAttributes.TYPE,
    MACRO = WidgetAttributes.MACRO,
    MOUNT = WidgetAttributes.MOUNT,
    MACRO_TEXT = WidgetAttributes.MACRO_TEXT,
}
---@type WidgetAttributes
_L.WidgetAttributes = WidgetAttributes
---@type ButtonAttributes
_L.ButtonAttributes = ButtonAttributes

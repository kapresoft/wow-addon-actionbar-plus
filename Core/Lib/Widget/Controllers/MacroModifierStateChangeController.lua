--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns      = select(2, ...)
local O, GC   = ns.O, ns.GC
local api, mcc = O.API, O.MacroControllerCommon

local THROTTLE_INTERVAL_MACRO_MODIFIERS = 0.3

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = ns.M.MacroModifierStateChangeController
--- @class MacroModifierStateChangeController : ThrottledUpdaterMixin
local L = ns:NewController(libName, O.ThrottledUpdaterMixin); if not L then return end
local p = ns:LC().MACRO:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function IsAnyModKeyDown()
    return IsShiftKeyDown() or IsAltKeyDown() or IsControlKeyDown()
end
--- @param bw ButtonUIWidget
local function Button_UpdateIcon(bw)
    local macroIndex = bw:GetMacroIndex(); if not macroIndex then return end
    local icon = api:GetMacroIcon(macroIndex)
    return icon and bw:SetIcon(icon)
end

--- @param ctrl ControllerV2
local function Button_UpdateAllMacros(ctrl)
    ctrl:ForEachMacroButton(function(bw)
        Button_UpdateIcon(bw)
        bw:UpdateCooldown()
    end)
end

--- @type MacroModifierStateChangeController | ControllerV2
local o = L

--[[-----------------------------------------------------------------------------
Methods: MacroModifierStateChangeController
-------------------------------------------------------------------------------]]

o:SetThrottleInterval(THROTTLE_INTERVAL_MACRO_MODIFIERS)

--- Automatically called
--- @private
--- @see ModuleV2Mixin#Init
function o:OnAddOnReady()
    self:RegisterAddOnMessage(GC.E.MODIFIER_STATE_CHANGED, o.OnModifierStateChanged)
end

---@param keyPressed string
---@param downPress number | "1" | "0"
function o.OnModifierStateChanged(evt, source, keyPressed, downPress)
    --p:vv(function() return 'OnModifierStateChanged() called: key=%s [%s]', keyPressed, downPress == 1 and 'key-down' or 'key-up' end)
    o:StartThrottledUpdates()

    -- On key-up, schedule stop after short delay
    if downPress == 0 then
        C_Timer.After(0.5, function()
            if not IsAnyModKeyDown() then
                o:StopThrottledUpdates()
            end
        end)
    end
end

--- @see ThrottledUpdaterMixin
--- @param elapsed TimeInMilli
function o:_OnUpdate(elapsed) local ctrl = self; mcc:UpdateMacros(ctrl) end

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local UnitIsDead, UnitName = UnitIsDead, UnitName

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns     = select(2, ...)
local O, GC  = ns.O, ns.GC
local api, u = O.API, GC.UnitId
local mcu    = O.MacroUtil

--[[-----------------------------------------------------------------------------
Module
The sole function of this controller is to update the current (dynamic) icon
on a macro. Macro icons can change based on conditions like modifiers, etc..
-------------------------------------------------------------------------------]]
local libName = ns.M.MacroMouseOverController
--- @class MacroMouseOverController : ThrottledUpdaterMixin
local L = ns:NewController(libName, O.ThrottledUpdaterMixin); if not L then return end
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function ri() return O.RangeIndicatorController  end

--- Checks if the current "target" unit is the same as the "mouseover" unit.
--- @return boolean
local function TargetUnitIsSameAsMouseOver()
    local targetGUID = UnitGUID("target")
    local mouseoverGUID = UnitGUID("mouseover")
    return targetGUID ~= nil and targetGUID == mouseoverGUID
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @type MacroMouseOverController | ControllerV2
local o = L

--- Automatically called
--- @see ModuleV2Mixin#Init
--- @private
function o:OnAddOnReady()
    self:SetThrottleInterval(0.1)
    self:RegisterAddOnMessage(GC.E.UPDATE_MOUSEOVER_UNIT, o.OnMouseOverUnit)
end

function o.OnMouseOverUnit()
    -- only activate if target ~= mouseover unit
    if TargetUnitIsSameAsMouseOver() then return end
    o:StartThrottledUpdates()
    o:UpdateDelayed()
end

--- @see ThrottledUpdaterMixin
--- @param elapsed TimeInMilli
function o:_OnUpdate(elapsed) self:UpdateMouseOverState() end

function o:UpdateMouseOverState()
    local exists = UnitExists(u.mouseover)
    if exists and not self._mouseoverWasSet then
        self._mouseoverWasSet = true
        self:StartThrottledUpdates()
    elseif not exists and self._mouseoverWasSet then
        self._mouseoverWasSet = false
        self:StopThrottledUpdates()
    end
end

function o:UpdateDelayed() C_Timer.After(0.001, function() self:Update() end) end

function o:Update()
    o:ForEachMacroButton(function(bw)
        mcu:Button_UpdateIcon(bw)
        mcu:Button_UpdateCooldown(bw)
        bw:ru():Button_UpdateRangeIndicator(bw, u.mouseover)
    end)
end

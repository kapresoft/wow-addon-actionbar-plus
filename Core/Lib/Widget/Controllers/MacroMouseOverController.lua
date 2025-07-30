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
local mcc = O.MacroControllerCommon

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

--- @type MacroMouseOverController | ControllerV2
local o = L

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- Automatically called
--- @see ModuleV2Mixin#Init
--- @private
function o:OnAddOnReady()
    self:RegisterAddOnMessage(GC.E.UPDATE_MOUSEOVER_UNIT, o.OnMouseOverUnit)
end

function o.OnMouseOverUnit()
    -- Wrap in a timer so that mouse on and off doesn't have a
    -- race condition when calling UnitName(mouseover)
    C_Timer.After(0.01, function()
        local name = UnitName(u.mouseover)
        if name then return o:OnStartMouseOverUnit(name) end
        o:OnStopMouseOverUnit()
    end)
end

--- @see ThrottledUpdaterMixin
--- @param elapsed TimeInMilli
function o:_OnUpdate(elapsed) self:UpdateAllRangeIndicators() end

--- @param unitName Name The mouseover unit name
function o:OnStartMouseOverUnit(unitName)
    self:StartThrottledUpdates()
    self:UpdateAllRangeIndicators()
end

function o:OnStopMouseOverUnit()
    o:StopThrottledUpdates()
    o:ForEachMacroButton(function(bw)
        mcc:UpdateIcon(bw)
        bw:UpdateCooldown()
        if UnitIsDead(u.mouseover) then return end

        self:ClearAllRangeIndicators()
    end)
end

function o:UpdateAllRangeIndicators()
    o:ForEachMacroButton(function(bw)
        mcc:UpdateIcon(bw)
        bw:UpdateCooldown()
        bw:ru():Button_UpdateRangeIndicator(bw, u.mouseover)
    end)
end

function o:ClearAllRangeIndicators()
    self:ForEachMacroButton(function(bw)
        ri():Button_ClearRangeIndicator(bw)
    end)
end


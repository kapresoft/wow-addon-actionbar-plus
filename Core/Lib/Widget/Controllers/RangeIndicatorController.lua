--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local UnitIsDead, UnitName = UnitIsDead, UnitName

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns    = select(2, ...)
local O, GC = ns.O, ns.GC
local u     = GC.UnitId

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = ns.M.RangeIndicatorController
--- @class RangeIndicatorController : ThrottledUpdaterMixin
local L = ns:NewController(libName); if not L then return end
ns:K():Mixin(L, O.ThrottledUpdaterMixin)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o RangeIndicatorController | ControllerV2
local function PropsAndMethods(o)

    --- Automatically called
    --- @see ModuleV2Mixin#Init
    --- @see MacroMouseOverController This file handles the mouseover range-indicator events
    --- @private
    function o:OnAddOnReady()
        self:RegisterAddOnMessage(GC.E.PLAYER_TARGET_CHANGED, o.OnTargetChanged)
        self:RegisterAddOnMessage(GC.E.MODIFIER_STATE_CHANGED, o.OnModifierStateChanged)
    end

    --- @private
    function o.OnTargetChanged()
        if UnitName(u.target) then return o:StartTargetingUnit() end
        return o:StopTargetingUnit()
    end

    ---@param keyPressed string
    ---@param downPress number | "1" | "0"
    function o.OnModifierStateChanged(evt, source, keyPressed, downPress)
        o:UpdateAllRangeIndicatorsDelayed()
    end

    --- @see ThrottledUpdaterMixin
    --- @param elapsed TimeInMilli
    function o:_OnUpdate(elapsed)
        self:UpdateAllRangeIndicators()
    end

    --- @private
    function o:StartTargetingUnit()
        o:StartThrottledUpdates()
        p:t(function() return 'StartTargetingUnit - active=%s', o:GetActiveCount() end)
        self:UpdateAllRangeIndicators()
    end

    --- @private
    function o:StopTargetingUnit()
        o:StopThrottledUpdates()
        p:t(function() return 'StopTargetingUnit - active=%s', o:GetActiveCount() end)
        self:ClearAllRangeIndicators()
    end

    function o:UpdateAllRangeIndicatorsDelayed()
        C_Timer.After(0.001, function() o:UpdateAllRangeIndicators() end)
    end

    --- @private
    function o:UpdateAllRangeIndicators()
        self:ForEachNonEmptyButton(function(bw)
            bw:ru():Button_UpdateRangeIndicator(bw, u.target)
        end)
    end

    function o:ClearAllRangeIndicators()
        self:ForEachNonEmptyButton(function(bw)
            bw:ru():ClearRangeIndicator()
        end)
    end

end; PropsAndMethods(L)


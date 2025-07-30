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
    --- @private
    function o:OnAddOnReady()
        self:RegisterAddOnMessage(GC.E.PLAYER_TARGET_CHANGED, o.OnTargetChanged)
    end

    --- /dump UnitExists('target')
    --- /dump UnitIsDead('target')
    --- @see ThrottledUpdaterMixin
    --- @param elapsed TimeInMilli
    function o:_OnUpdate(elapsed) self:UpdateAllRangeIndicators() end

    --- @private
    function o.OnTargetChanged()
        if UnitName(u.target) then return o:StartTargetingUnit() end
        return o:StopTargetingUnit()
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

    --- @private
    function o:UpdateAllRangeIndicators()
        self:ForEachNonEmptyButton(function(bw)
            bw:ru():Button_UpdateRangeIndicator(bw, u.target)
        end)
    end

    function o:ClearAllRangeIndicators()
        self:ForEachNonEmptyButton(function(bw)
            self:Button_ClearRangeIndicator(bw)
        end)
    end

    --- @param bw ButtonUIWidget
    function o:Button_ClearRangeIndicator(bw) bw.kbt:UpdateKeybindTextState() end

end; PropsAndMethods(L)


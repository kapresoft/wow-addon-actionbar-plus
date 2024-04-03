--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, E, MSG = ns.O, ns.GC.E, ns.GC.M
local libName = 'GridEventsController'
local CURSOR_ITEM_TYPE = 1
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class GridEventsController
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)
--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o GridEventsController | ControllerV2
local function PropsAndMethods(o)

    --- Automatically called
    --- @see ModuleV2Mixin#Init
    --- @private
    function o:OnAddOnReady()
        o:RegisterAddOnMessage(E.ACTIONBAR_SHOWGRID, o.OnActionbarShowGrid)
        o:RegisterAddOnMessage(E.ACTIONBAR_HIDEGRID, o.OnActionbarHideGrid)

        if ns:IsVanilla() then return end
        print('xxx Not Vanilla')
        o:RegisterAddOnMessage(E.CURSOR_CHANGED, o.OnCursorChangeInBags)
    end

    function o.OnActionbarShowGrid()
        p:f1('OnActionbarShowGrid() called...')
        if InCombatLockdown() then return end

        o:ForEachButton(function(bw)
            bw:ShowEmptyGridEvent()
            C_Timer.After(0.1, function() bw:EnableMouse(true) end)
        end)

    end

    function o.OnActionbarHideGrid()
        p:f1('OnActionbarShowGrid() called...')
        if InCombatLockdown() then return end

        o:ForEachButton(function(bw) bw:HideEmptyGridEvent() end)
        C_Timer.After(1, function()
            o:EnableMouseAllButtons(GetCursorInfo() ~= nil)
        end)
    end

    --- See Also: [https://wowpedia.fandom.com/wiki/CURSOR_CHANGED](https://wowpedia.fandom.com/wiki/CURSOR_CHANGED)
    --- @param f Frame
    --- @param event string
    function o.OnCursorChangeInBags(event, src, ...)
        if InCombatLockdown() then return end

        local isDefault, newCursorType, oldCursorType = ...
        p:f3(function() return "OnCursorChangeInBags: isDefault=%s newCursorType=%s", isDefault, newCursorType end)
        if true == isDefault and oldCursorType == CURSOR_ITEM_TYPE then
            o.OnActionbarHideGrid()
            ns:a().ActionbarEmptyGridShowing = false
            return
        end
        if newCursorType ~= CURSOR_ITEM_TYPE then return end
        o.OnActionbarShowGrid()
        ns:a().ActionbarEmptyGridShowing = true
    end
    --- @param state boolean
    function o:EnableMouseAllButtons(state)
        self:ForEachButton(function(bw)
            if not bw:IsEmpty() then return end
            bw:EnableMouse(state)
        end)
    end


end; PropsAndMethods(L)


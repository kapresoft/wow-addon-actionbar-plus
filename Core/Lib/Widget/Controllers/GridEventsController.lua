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
local pd = ns:LC().DRAG_AND_DROP:NewLogger(libName)

--- @return boolean
local function IsSupportedCursor()
    local cursorUtil = ns:CreateCursorUtil()
    local supported = O.ReceiveDragEventHandler:IsSupportedCursorType(cursorUtil)
    return supported == true
end
--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o GridEventsController | ControllerV2
local function PropsAndMethods(o)

    --- Automatically called
    --- @see ModuleV2Mixin#Init
    --- @private
    function o:OnAddOnReady()
        o:RegisterAddOnMessage(E.ACTIONBAR_SHOWGRID, o.OnActionBarShowGrid)
        o:RegisterAddOnMessage(E.PET_BAR_SHOWGRID, o.OnPetBarShowGrid)
        o:RegisterAddOnMessage(E.ACTIONBAR_HIDEGRID, o.OnActionBarHideGrid)
        o:RegisterAddOnMessage(E.PET_BAR_HIDEGRID, o.OnPetBarHideGrid)

        if ns:IsVanilla() then return end
        o:RegisterAddOnMessage(E.CURSOR_CHANGED, o.OnCursorChangeInBags)
    end

    function o.OnActionBarShowGrid()
        if IsSupportedCursor() ~= true then return end
        if InCombatLockdown() then return end

        o:ForEachButton(function(bw)
            bw:ShowEmptyGridEvent()
            C_Timer.After(0.1, function() bw:EnableMouse(true) end)
        end)

    end

    function o.OnPetBarShowGrid()
        if IsSupportedCursor() ~= true then return end
        o.OnActionBarShowGrid()
    end

    function o.OnActionBarHideGrid()
        if InCombatLockdown() then return end

        o:ForEachButton(function(bw) bw:HideEmptyGridEvent() end)
        C_Timer.After(1, function()
            o:EnableMouseAllButtons(GetCursorInfo() ~= nil)
        end)
    end

    function o.OnPetBarHideGrid()
        o.OnActionBarHideGrid()
    end

    --- See Also: [https://wowpedia.fandom.com/wiki/CURSOR_CHANGED](https://wowpedia.fandom.com/wiki/CURSOR_CHANGED)
    --- @param f Frame
    --- @param event string
    function o.OnCursorChangeInBags(event, src, ...)
        if InCombatLockdown() then return end

        local isDefault, newCursorType, oldCursorType = ...
        pd:f3(function() return "OnCursorChangeInBags: isDefault=%s newCursorType=%s", isDefault, newCursorType end)
        if true == isDefault and oldCursorType == CURSOR_ITEM_TYPE then
            o.OnActionBarHideGrid()
            ns:a().ActionbarEmptyGridShowing = false
            return
        end
        if newCursorType ~= CURSOR_ITEM_TYPE then return end
        o.OnActionBarShowGrid()
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


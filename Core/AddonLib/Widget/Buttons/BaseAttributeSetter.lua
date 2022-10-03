--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local InCombatLockdown = InCombatLockdown

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local WMX = O.WidgetMixin

--[[-----------------------------------------------------------------------------
Interface
-------------------------------------------------------------------------------]]
---@class AttributeSetter
local AttributeSetter = {
    ---@param btnUI ButtonUI
    ---@param btnData Profile_Button
    ['SetAttributes'] = function(btnUI, btnData) end,
    ---@param btnUI ButtonUI
    ['ShowTooltip'] = function(btnUI) end
}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class BaseAttributeSetter : AttributeSetter
local _L = LibStub:NewLibrary(Core.M.BaseAttributeSetter)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param btnUI ButtonUI
function _L:HandleGameTooltipCallbacks(btnUI)
    ---@param w ButtonUIWidget
    btnUI.widget:SetCallback("OnEnter", function(w, event)
        if InCombatLockdown() then
            if not w:IsTooltipCombatModifierKeyDown() then return end
        else
            if not w:IsTooltipModifierKeyDown() then return end
        end

        self:ShowTooltip(w.button)

        if not GetCursorInfo() then return end
        w.border:SetAlpha(1)
    end)

    ---@param w ButtonUIWidget
    btnUI.widget:SetCallback("OnLeave", function(w, event)
        WMX:HideTooltipDelayed()

        if not GetCursorInfo() then return end
        w.border:SetAlpha(0.5)
    end)
end
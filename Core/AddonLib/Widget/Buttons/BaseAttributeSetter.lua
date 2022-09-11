local LibStub, M = ABP_WidgetConstants:LibPack()
local WU = ABP_LibGlobals:LibPack_WidgetUtil()
local InCombatLockdown = InCombatLockdown

---@class BaseAttributeSetter @parent class
local _L = LibStub:NewLibrary(M.BaseAttributeSetter)

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
    end)

    btnUI.widget:SetCallback("OnLeave", function(w, event) WU:HideTooltipDelayed() end)

end
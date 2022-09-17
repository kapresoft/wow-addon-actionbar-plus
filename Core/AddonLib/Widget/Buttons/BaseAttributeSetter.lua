local LibStub, M, G = ABP_LibGlobals:LibPack()
local WMX = G:Lib_WidgetMixin()
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

    ---@param w ButtonUIWidget
    btnUI.widget:SetCallback("OnLeave", function(w, event)
        WMX:HideTooltipDelayed()
    end)

end
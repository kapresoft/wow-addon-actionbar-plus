local LibStub, M = ABP_WidgetConstants:LibPack()
local WU = ABP_LibGlobals:LibPack_WidgetUtil()

---@class BaseAttributeSetter @parent class
local _L = LibStub:NewLibrary(M.BaseAttributeSetter)

---@param btnUI ButtonUI
function _L:HandleGameTooltipCallbacks(btnUI)

    ---@param w ButtonUIWidget
    btnUI.widget:SetCallback("OnEnter", function(w, event)
        _L:log(20, 'SetCallback[%s]: %s', event, w:GetName())
        self:ShowTooltip(w.button)
    end)
    btnUI.widget:SetCallback("OnLeave", function(w, event)
        _L:log(20, 'SetCallback[%s]: %s', event, w:GetName())
        WU:HideTooltipDelayed()
    end)

end
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
    ---@param self AttributeSetter
    ---@param btnUI ButtonUI
    ---@param btnData Profile_Button
    ['SetAttributes'] = function(self, btnUI, btnData) end,
    ---@param self AttributeSetter
    ---@param btnUI ButtonUI
    ['OnAfterSetAttributes'] = function(self, btnUI) end,
    ---@param self AttributeSetter
    ---@param btnUI ButtonUI
    ['ShowTooltip'] = function(self, btnUI) end
}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class BaseAttributeSetter : AttributeSetter
local _L = LibStub:NewLibrary(Core.M.BaseAttributeSetter)
---@type LoggerTemplate
local p = _L:GetLogger()

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param btnUI ButtonUI
local function AddPostCombat(btn)
    if not InCombatLockdown() then return end
    O.ButtonFrameFactory:AddPostCombatUpdate(btn.widget)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param btn ButtonUI
function _L:OnAfterSetAttributes(btn)
    AddPostCombat(btn)
    self:HandleGameTooltipCallbacks(btn)
end

---@param btn ButtonUI
function _L:HandleGameTooltipCallbacks(btn)
    ---@param w ButtonUIWidget
    btn.widget:SetCallback("OnEnter", function(w, event)
        if InCombatLockdown() then
            if not w:IsTooltipCombatModifierKeyDown() then return end
        elseif ABP.ActionbarEmptyGridShowing == true and btn.widget:IsEmpty() then
            w:SetHighlightEmptyButtonEnabled(true)
        else
            if not w:IsTooltipModifierKeyDown() then return end
        end

        self:ShowTooltip(w.button)

        if not GetCursorInfo() then return end
        w:SetHighlightEmptyButtonEnabled(true)
    end)

    ---@param w ButtonUIWidget
    btn.widget:SetCallback("OnLeave", function(w, event)
        WMX:HideTooltipDelayed()

        if not GetCursorInfo() then return end
        w:SetHighlightEmptyButtonEnabled(false)
    end)
end
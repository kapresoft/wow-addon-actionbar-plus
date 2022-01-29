--[[-----------------------------------------------------------------------------
ActionButton.lua
-------------------------------------------------------------------------------]]

-- WoW APIs
local ClearCursor, GetCursorInfo, CreateFrame, UIParent =
ClearCursor, GetCursorInfo, CreateFrame, UIParent
local GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show =
GameTooltip, C_Timer, ReloadUI, IsShiftKeyDown, StaticPopup_Show


-- Lua APIs
local format = string.format

-- Local APIs
local LibStub, M = ABP_LibGlobals:LibPack()
local PrettyPrint, Table, String, LogFactory = ABP_LibGlobals:LibPackUtils()
---@type LogFactory
local p = LogFactory:NewLogger('ButtonUI')

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local factoryMethods = {
    ---@return ButtonUI
    ['NewButton'] = function(self, dragFrame, rowNum, colNum, index)

    end,
    ---@return ButtonUI
    ['FromButton'] = function(self, btn)

    end,

}
-- ButtonUI:Factory():NewButton(dragFrame, rowNum, colNum, index)
-- ButtonUI:Factory():FromButton(btnUI)
local methods = {
    ['Factory'] = function(self)
        local f = {}
        for method, func in pairs(factoryMethods) do
            f[method] = func
        end
        return f
    end,
    ---@return ActionBarInfox
    ['GetActionbarInfo'] = function(self)
        local index = self.index
        local dragFrame = self.parentFrame;
        local frameName = dragFrame:GetName()
        local btnName = format('%sButton%s', frameName, tostring(index))

        ---@class ActionBarInfox
        local info = {
            name = frameName, index = dragFrame:GetFrameIndex(),
            button = { name = btnName, index = index },
        }
        return info
    end,
    ['GetProfileButtonData'] = function(self)
        local info = self:GetActionbarInfo()
        if not info then return nil end
        return P:GetButtonData(info.index, info.button.name)
    end,

    ['ClearCooldown'] = function(self)
        self.cooldownFrame:SetCooldownInfo(0,0)
    end,
    ['SetCooldown'] = function(self, optionalInfo)
        local info = optionalInfo or self.cooldownFrame.info
        self:SetCooldownInfo(info)
        self.cooldownFrame:SetCooldown(info.start, info.duration)
        --self:log('Cooldown success: %s', pformat(info))
    end,
    ['SetCooldownInfo'] = function(self)
        if not cooldownInfo then return end
        self.cooldownFrame.info = cooldownInfo
    end,
    ['ResumeCooldown'] = function(self)
        self:ClearCooldown()
        self:SetCooldown()
    end,
}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local function NewInstance()
    --local frame = CreateFrame("Frame", "New AceLib Wow AddonFrame", UIParent)
    --frame:SetScript("OnEvent", OnEvent)
    --frame:RegisterEvent("PLAYER_LOGIN")

    -- profile is injected OnAfterInitialize()
    local properties = {
        addon = nil,
        profile = nil,
    }

    ---@class ButtonUI
    local _L = LibStub:NewLibrary(M.ButtonUI, 1)
    _L.mt.__index = properties

    for method, func in pairs(methods) do
        _L[method] = func
    end

    return _L
end

ButtonUI = NewInstance()
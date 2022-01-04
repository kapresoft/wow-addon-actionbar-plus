---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by tony.
--- DateTime: 1/2/2022 5:43 PM
---
local _G, unpack, format = _G, table.unpackIt, string.format
local ADDON_NAME, LibStub, ABP_GLOBALS, ABP_ACE, EMBED_LOGGER  = ADDON_NAME, LibStub, ABP_GLOBALS, ABP_ACE, EMBED_LOGGER
local StaticPopupDialogs, StaticPopup_Show, ReloadUI, IsShiftKeyDown = StaticPopupDialogs, StaticPopup_Show, ReloadUI, IsShiftKeyDown

local MAJOR, MINOR = ADDON_NAME .. '-1.0', 1 -- Bump minor on changes
local A = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
if not A then return end
ABP = A

local ACEDB, ACEDBO, ACECFG, ACECFGD = unpack(ABP_ACE())
local libModules = ABP_GLOBALS()
local C, P, B, BF = unpack(libModules)
EMBED_LOGGER(A, 'Core')

StaticPopupDialogs["CONFIRM_RELOAD_UI"] = {
    text = "Reload UI?", button1 = "Yes", button2 = "No",
    timeout = 0, whileDead = true, hideOnEscape = true,
    OnAccept = function() ReloadUI() end,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

function A:RegisterSlashCommands()
    --self:RegisterChatCommand("bbc", "OpenConfig")
    --self:RegisterChatCommand("bb", "HandleBoxerCommands")
    --self:RegisterChatCommand("boxer", "HandleBoxerCommands")
end

function A:RegisterKeyBindings()
    --SetBindingClick("SHIFT-T", self:Info())
    --SetBindingClick("SHIFT-F1", BoxerButton3:GetName())
    --SetBindingClick("ALT-CTRL-F1", BoxerButton1:GetName())

    -- Warning: Replaces F5 keybinding in Wow Config
    -- SetBindingClick("F5", BoxerButton3:GetName())
    -- TODO: Configure Button 1 to be the Boxer Follow Button (or create an invisible one)
    --SetBindingClick("SHIFT-R", BoxerButton1:GetName())
end

function A:OnProfileChanged()
    --self:ConfirmReloadUI()
end

function A:ConfirmReloadUI()
    if IsShiftKeyDown() then
        ReloadUI()
        return
    end
    StaticPopup_Show("CONFIRM_RELOAD_UI")
end

function A:OpenConfig(_)
    ACECFGD:Open(ADDON_NAME)
end

-----@param isEnabled boolean Current enabled state
--function A:SetAddonState(isEnabled)
--    local enabledFrames = { 'ActionbarPlusF1', 'ActionbarPlusF2' }
--    for _,fn in ipairs(enabledFrames) do
--        local f = _G[fn]
--        if type(f.ShowGroup) == 'function' then
--            if isEnabled then f:ShowGroup()
--            else f:HideGroup() end
--        end
--    end
--end
--
--function A:SetAddonEnabledState(isEnabled)
--    if isEnabled then self:Enable()
--    else self:Disable() end
--end

function A:OnEnable()
    self:log('Enabled..')
    --self:SetAddonState(true)
end

function A:OnDisable()
    self:log('Disabled..')
    --self:SetAddonState(false)
end

function A:OnInitialize()
    -- Set up our database
    self.db = ACEDB:New("ABP_PLUS_DB")
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")

    self.profile = self.db.profile
    P:Init(self.profile)

    --if type(self.profile.bars) ~= 'table' then self.profile.bars = {} end
    --self.profile.enabled = type(self.profile.enabled) ~= boolean and true or true
    --if type(self.profile.enabled) ~= boolean then self.profile.enabled = true end

    local options = C:GetOptions(self, self.profile)
    -- Register options table and slash command
    ACECFG:RegisterOptionsTable(ADDON_NAME, options, { "abp_options" })
    --cfgDialog:SetDefaultSize(ADDON_NAME, 800, 500)
    ACECFGD:AddToBlizOptions(ADDON_NAME, ADDON_NAME)

    -- Get the option table for profiles
    options.args.profiles = ACEDBO:GetOptionsTable(self.db)

    self:RegisterSlashCommands()
    self:RegisterKeyBindings()
end

-- #####################################################################################

local function AddonLoaded()
    for _, m in ipairs(libModules) do
        m:Initialized{ handler = A, profile= A.profile }
    end
    A:log("%s.%s initialized", MAJOR, MINOR)
end

local frame = CreateFrame("Frame", ADDON_NAME .. "Frame", UIParent)
frame:SetScript("OnEvent", AddonLoaded)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Temp
Profile = P

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local type, pairs, tostring = type, pairs, tostring

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local M, GC = Core.M, O.GlobalConstants

local Table, Assert = O.Table, O.Assert

local BAttr, WAttr = GC.ButtonAttributes, GC.WidgetAttributes
local isTable, isNotTable, tsize, tinsert, tsort
    = Table.isTable, Table.isNotTable, Table.size, table.insert, table.sort
local AssertThatMethodArgIsNotNil = Assert.AssertThatMethodArgIsNotNil

---@type ProfileInitializer
local ProfileInitializer = O.ProfileInitializer

local ActionType = { WAttr.SPELL, WAttr.ITEM, WAttr.MACRO, WAttr.MACRO_TEXT }

---@class Profile
local P = LibStub:NewLibrary(M.Profile)
---@type Profile
ABP_Profile = P

if not P then return end

---- ## Start Here ----

---These are the config names used by the UI
---@see Config.lua
---@class ProfileConfigNames
local ConfigNames = {
    ---@deprecated lock_actionbars is to be removed
    ['lock_actionbars'] = 'lock_actionbars',
    ['hide_when_taxi'] = 'hide_when_taxi',
    ['action_button_mouseover_glow'] = 'action_button_mouseover_glow',
    ['tooltip_visibility_key'] = 'tooltip_visibility_key',
    ['tooltip_visibility_combat_override_key'] = 'tooltip_visibility_combat_override_key',
    ['show_button_index'] = 'show_button_index',
    ['show_keybind_text'] = 'show_keybind_text',
}

---@class TooltipKeyName
local TooltipKeyName = {
    ['SHOW'] = '',
    ['ALT'] = 'alt',
    ['CTRL'] = 'ctrl',
    ['SHIFT'] = 'shift',
    ['HIDE'] = 'hide',
}
---@class TooltipKey
local TooltipKey = {
    names = TooltipKeyName,
    sorting = {
        TooltipKeyName.SHOW, TooltipKeyName.ALT, TooltipKeyName.CTRL,
        TooltipKeyName.SHIFT, TooltipKeyName.HIDE },
    kvPairs = {
        [TooltipKeyName.SHOW]  = ABP_SHOW,
        [TooltipKeyName.ALT]   = ABP_ALT,
        [TooltipKeyName.CTRL]  = ABP_CTRL,
        [TooltipKeyName.SHIFT] = ABP_SHIFT,
        [TooltipKeyName.HIDE]  = ABP_HIDE,
    }
}

local SingleBarTemplate = {
    enabled = false,
    buttons = {}
}

---@class BarData
local ProfileBarTemplate = {
    ["enabled"] = false,
    -- allowed values: {"", "always", "in-combat"}
    ["locked"] = "",
    -- shows the button index BOTTOMLEFT
    ["show_button_index"] = true,
    -- shows the keybind text TOP
    ["show_keybind_text"] = true,
    ["widget"] = { ["rowSize"] = 2, ["colSize"] = 6, ["buttonSize"] = 35, },
    ["buttons"] = {
        ['ActionbarPlusF1Button1'] = {
            ['type'] = 'spell',
            ['spell'] = {
                -- spellInfo
            }
        }
    }
}

---@class SpellData
local SpellDataTemplate = {
    ["minRange"] = 0,
    ["id"] = 8232,
    ["label"] = "Windfury Weapon |c00747474(Rank 1)|r",
    ["name"] = "Windfury Weapon",
    ["castTime"] = 0,
    ["link"] = "|cff71d5ff|Hspell:8232:0|h[Windfury Weapon]|h|r",
    ["maxRange"] = 0,
    ["icon"] = 136018,
    ["rank"] = "Rank 1"
}
---@class ItemData
local ItemDataTemplate = {
    ["name"] = "Arcane Powder",
    ["link"] = "|cffffffff|Hitem:17020::::::::70:::::::::|h[Arcane Powder]|h|r",
    ["id"] = 17020,
    ["stackCount"] = 20,
    ["icon"] = 133848,
    ["count"] = 40,
}
---@class MacroData
local MacroDataTemplate = {
    ["type"] = "macro",
    ["index"] = 41,
    ["name"] = "z#LOL",
    ["icon"] = 132093,
    ["body"] = "/lol\n",
}
---@class MountData
local MountDataTemplate = {
    type = 'mount',
    id = -1,
    index = -1,
    name = 'Reawakened Phase Hunter',
    spell = {  id = 1, icon = 123 },
}
---@class ProfileButton : ProfileButtonDataMixin
local ProfileButtonTemplate = {
    ['type'] = 'spell',
    ["spell"] = SpellDataTemplate,
    ["item"] = ItemDataTemplate,
    ["macro"] = MacroDataTemplate,
    ["mount"] = MountDataTemplate,
}

---@class ProfileTemplate : DefaultProfile
local ProfileTemplate = {
    ["lock_actionbars"] = false,
    ["hide_when_taxi"] = true,
    ["tooltip_visibility_key"] = '',
    ---toggle action button mouseover glow
    ["action_button_mouseover_glow"] = true,
    ["tooltip_visibility_combat_override_key"] = '',
    ["bars"] = {
        ["ActionbarPlusF1"] = bar,
        ["ActionbarPlusF2"] = {["enabled"] = false, ["buttons"] = {}},
        ["ActionbarPlusF3"] = {["enabled"] = false, ["buttons"] = {}},
        ["ActionbarPlusF4"] = {["enabled"] = false, ["buttons"] = {}},
        ["ActionbarPlusF5"] = {["enabled"] = false, ["buttons"] = {}},
        ["ActionbarPlusF6"] = {["enabled"] = false, ["buttons"] = {}},
        ["ActionbarPlusF7"] = {["enabled"] = false, ["buttons"] = {}},
        ["ActionbarPlusF8"] = {["enabled"] = false, ["buttons"] = {}},
    }
}

---@see API#GetSpellinfo
local ButtonTemplate = { ['type'] = nil, [BAttr.SPELL] = {} }

---- ## Start Here ----


local function assertProfile(p)
    assert(isTable(p), "profile is not a table")
end

-- Implicit
-- self.adddon = ActionBarPlus
-- self.profile = profile

-- ##########################################################################

local FrameDetails = ProfileInitializer:GetAllActionBarSizeDetails()

-- ##########################################################################

P.maxFrames = 8
P.baseFrameName = 'ActionbarPlusF'

---@return ProfileButton
function P:GetButtonData(frameIndex, buttonName)
    local barData = self:GetBar(frameIndex)
    if not barData then return end
    local buttons = barData.buttons
    --if not buttons then return nil end
    local btnData = buttons[buttonName]
    if type(buttons[buttonName]) ~= 'table' then
        buttons[buttonName] = {}
    end
    return buttons[buttonName]
end

---@param widget ButtonUIWidget
function P:ResetButtonData(widget)
    local btnData = widget:GetConfig()
    for _, a in ipairs(ActionType) do btnData[a] = {} end
    btnData[WAttr.TYPE] = ''
end

function P:InitDELETEME(newProfile)
    assertProfile(newProfile)

    if type(newProfile.bars) ~= 'table' then
        newProfile.bars = self:CreateBarsTemplate()
    end

    for _,bar in pairs(newProfile.bars) do
        if type(bar['buttons']) ~= 'table' then
            newProfile.bars['buttons'] = {}
        end
    end
end

function P:CreateDefaultProfile(profileName)
    return ProfileInitializer:InitNewProfile(profileName)
end

function P:OnAfterInitialize()
    -- do nothing for now
end

function P:CreateBarsTemplate()
    local bars = {}
    for i=1, self:GetMaxFrames() do
        local frameName = self:GetFrameNameByIndex(i)
        bars[frameName] = {
            enabled = false,
            buttons = {}
        }
    end

    return bars
end

---@return ProfileTemplate
function P:GetProfileData() return self.profile end

-- /run ABP_Table.toString(Profile:GetBar(1))
---@return BarData
function P:GetBar(frameIndex)
    AssertThatMethodArgIsNotNil(frameIndex, 'frameIndex', 'GetBar(frameIndex)')

    if isNotTable(self.profile.bars) then return end
    local frameName = self:GetFrameNameByIndex(frameIndex)
    local bar = self.profile.bars[frameName]
    if isNotTable(bar) then
        self.profile.bars[frameName] = self:CreateBarsTemplate()
        bar = self.profile.bars[frameName]
    end

    return bar
end

function P:GetBars()
    return self.profile.bars
end

function P:GetBarSize()
    local bars = P:GetBars()
    if isNotTable(bars) then return 0 end
    return tsize(bars)
end

---@param frameIndex number The frame index number
---@param isEnabled boolean The enabled state
function P:SetBarEnabledState(frameIndex, isEnabled)
    local bar = self:GetBar(frameIndex)
    bar.enabled = isEnabled
end

---@param frameIndex number The frame index number
function P:IsBarEnabled(frameIndex)
    local bar = self:GetBar(frameIndex)
    return bar.enabled
end

function P:SetBarLockedState(frameIndex, isLocked)
    local bar = self:GetBar(frameIndex)
    --bar.locked = isLocked
end

---@param frameIndex number The frame index number
function P:IsBarLocked(frameIndex)
    local bar = self:GetBar(frameIndex)
    --return bar.locked
    return false
end

---@param frameIndex number The frame index number
function P:GetBarLockValue(frameIndex)
    local bar = self:GetBar(frameIndex)
    return bar.locked or ''
end

---@param frameIndex number The frame index number
---@param value string Allowed values are "always", "in-combat", or nil
function P:SetBarLockValue(frameIndex, value)
    local bar = self:GetBar(frameIndex)
    local valueLower = string.lower(value or '')
    if valueLower == 'always' or valueLower == 'in-combat' then
        bar.locked = value
        return bar.locked
    end
    bar.locked = ''
    return bar.locked
end

function P:IsActionButtonMouseoverGlowEnabled() return self:GetProfileData().action_button_mouseover_glow == true end
function P:IsBarUnlocked(frameIndex) return self:GetBarLockValue(frameIndex) == '' or self:GetBarLockValue(frameIndex) == nil end
function P:IsBarLockedInCombat(frameIndex) return self:GetBarLockValue(frameIndex) == 'in-combat' end
function P:IsBarLockedAlways(frameIndex) return self:GetBarLockValue(frameIndex) == 'always' end
function P:IsBarIndexEnabled(frameIndex) return self:IsBarNameEnabled(self:GetFrameNameByIndex(frameIndex)) end

function P:IsBarNameEnabled(frameName)
    if not self.profile.bars then return false end
    local bar = self.profile.bars[frameName]
    if isNotTable(bar) then return false end
    return bar.enabled
end

---@param frameIndex number The frame index number
---@param isEnabled boolean The enabled state
function P:SetShowIndex(frameIndex, isEnabled)
    self:GetBar(frameIndex).show_button_index = (isEnabled == true)
end

---@param frameIndex number The frame index number
---@param isEnabled boolean The enabled state
function P:SetShowKeybindText(frameIndex, isEnabled)
    self:GetBar(frameIndex).show_keybind_text = (isEnabled == true)
end

---@param frameIndex number The frame index number
---@return boolean
function P:IsShowIndex(frameIndex)
    return self:GetBar(frameIndex).show_button_index == true
end

---@param frameIndex number The frame index number
function P:IsShowKeybindText(frameIndex)
    return self:GetBar(frameIndex).show_keybind_text == true
end

function P:GetBaseFrameName() return self.baseFrameName end

function P:GetFrameNameByIndex(frameIndex)
    return self:GetBaseFrameName() .. tostring(frameIndex)
end

---@return FrameWidget
function P:GetFrameWidgetByIndex(frameIndex)
    return _G[self:GetFrameNameByIndex(frameIndex)].widget
end

function P:GetMaxFrames()
    return #FrameDetails
end

function P:GetAllFrameNames()
    local fnames = {}
    for i=1, self:GetMaxFrames() do
        local fn = self:GetFrameNameByIndex(i)
        tinsert(fnames, fn)
    end
    tsort(fnames)
    return fnames
end

---@return table
function P:GetAllFrameWidgets()
    local fnames = {}
    for i=1, self:GetMaxFrames() do
        local fn = self:GetFrameNameByIndex(i)
        tinsert(fnames, fn)
    end
    tsort(fnames)

    local frames = {}
    for _, f in ipairs(fnames) do tinsert(frames, _G[f].widget) end
    return frames
end

function P:GetButtonsByIndex(frameIndex)

    local barData = self:GetBar(frameIndex)
    if barData then
        return barData.buttons
    end

    return nil
end

function P:FindButtonsBySpellById(spellId)
    local buttons = {}
    for barName, bar in pairs(self:GetBars()) do
        for buttonName, button in pairs(bar.buttons) do
            if 'spell' == button.type and button.spell and spellId == button.spell.id then
                buttons[buttonName] = button.spell
            end
        end
    end
    return buttons
end

---@param btnType string spell, macro, item
function P:FindButtonsByType(btnType)
    local buttons = {}
    for _, bar in pairs(self:GetBars()) do
        if bar.buttons then
            for buttonName, button in pairs(bar.buttons) do
                if btnType == button.type then
                    buttons[buttonName] = button
                end
            end
        end
    end
    return buttons
end


function P:GetAllActionBarSizeDetails()
    return FrameDetails
end

function P:GetActionBarSizeDetailsByIndex(frameIndex)
    return FrameDetails[frameIndex]
end

---@deprecated No longer being used in preference of ActionBars / Pick Up Action Key
---@return boolean True if the action bar is locked
function P:IsLockActionBars()
    return self.profile[ConfigNames.lock_actionbars] == true
end

function P:IsHideWhenTaxi()
    return self.profile[ConfigNames.hide_when_taxi] == true
end

---@return ProfileConfigNames
function P:GetConfigNames() return ConfigNames end

---@return TooltipKey
function P:GetTooltipKey() return TooltipKey end

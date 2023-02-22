--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local type, pairs, tostring = type, pairs, tostring

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, LibStub = ns:LibPack()

local GC, Ace, PI = O.GlobalConstants, O.AceLibrary, O.ProfileInitializer
local Table, Assert = O.Table, O.Assert
local AceEvent, WAttr = Ace.AceEvent, GC.WidgetAttributes
local isTable, isNotTable, tsize, tinsert, tsort
    = Table.isTable, Table.isNotTable, Table.size, table.insert, table.sort
local AssertThatMethodArgIsNotNil = Assert.AssertThatMethodArgIsNotNil
local ActionType = { WAttr.SPELL, WAttr.ITEM, WAttr.MACRO, WAttr.MACRO_TEXT,
                     WAttr.PET_ACTION, WAttr.COMPANION, WAttr.BATTLE_PET,
                     WAttr.EQUIPMENT_SET}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class Profile : BaseLibraryObject_WithAceEvent
local P = LibStub:NewLibrary(ns.M.Profile); if not P then return end
AceEvent:Embed(P)
local p = P:GetLogger()

local ConfigNames = GC.Profile_Config_Names

--[[-----------------------------------------------------------------------------
Interface Definition
-------------------------------------------------------------------------------]]
--- @class TooltipKeyName
local TooltipKeyName = {
    ['SHOW'] = '',
    ['ALT'] = 'alt',
    ['CTRL'] = 'ctrl',
    ['SHIFT'] = 'shift',
    ['HIDE'] = 'hide',
}

--- @class TooltipKey
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

--- @class TooltipAnchorTypeKey
--- @see Config
local TooltipAnchorTypeKey = {
    names = GC.TooltipAnchor,
    sorting = {
        GC.TooltipAnchor.CURSOR_TOPLEFT, GC.TooltipAnchor.CURSOR_TOPRIGHT,
        GC.TooltipAnchor.CURSOR_BOTTOMLEFT, GC.TooltipAnchor.CURSOR_BOTTOMRIGHT,
        GC.TooltipAnchor.SCREEN_TOPLEFT, GC.TooltipAnchor.SCREEN_TOPRIGHT,
        GC.TooltipAnchor.SCREEN_BOTTOMLEFT, GC.TooltipAnchor.SCREEN_BOTTOMRIGHT,
    },
    kvPairs = {
        [GC.TooltipAnchor.CURSOR_TOPLEFT]  = 'Cursor Top Left',
        [GC.TooltipAnchor.CURSOR_TOPRIGHT]  = 'Cursor Top Right',
        [GC.TooltipAnchor.CURSOR_BOTTOMLEFT]  = 'Cursor Bottom Left',
        [GC.TooltipAnchor.CURSOR_BOTTOMRIGHT]  = 'Cursor Bottom Right',
        [GC.TooltipAnchor.SCREEN_TOPLEFT]  = 'Screen Top Left',
        [GC.TooltipAnchor.SCREEN_TOPRIGHT]  = 'Screen Top Right',
        [GC.TooltipAnchor.SCREEN_BOTTOMLEFT]  = 'Screen Bottom Left',
        [GC.TooltipAnchor.SCREEN_BOTTOMRIGHT]  = 'Screen Bottom Right',
    }
}

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

--- @param source _RegionAnchor
--- @param dest _RegionAnchor
local function CopyAnchor(source, dest)
    dest.point = source.point
    dest.relativeTo = source.relativeTo
    dest.relativePoint = source.relativePoint
    dest.x = source.x
    dest.y = source.y
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param obj any
function P:Mixin(obj)
    return ns:K():Mixin(obj, self)
end

--- @param frameIndex number
--- @param btnIndex number
--- @return Profile_Button
function P:GetButtonDataByIndex(frameIndex, btnIndex)
    local btnName = GC:ButtonName(frameIndex, btnIndex)
    return self:GetButtonData(frameIndex, btnName)
end

--- @return Profile_Button
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

--- @param widget ButtonUIWidget
function P:ResetButtonData(widget)
    local btnData = widget:GetConfig()
    for _, a in ipairs(ActionType) do btnData[a] = {} end
    btnData[WAttr.TYPE] = ''
end

function P:CreateDefaultProfile(profileName) return PI:InitNewProfile(profileName) end

function P:CreateBarsTemplate()
    local bars = {}
    for i=1, self:GetActionbarFrameCount() do
        local frameName = self:GetFrameNameByIndex(i)
        bars[frameName] = {
            enabled = false,
            buttons = {}
        }
    end

    return bars
end

--- @return Profile_Config
function P:P() return ns.db.profile  end
--- @return Profile_Global_Config
function P:G()
    local g = ns.db.global
    --g.bars = nil
    if Table.isNotTable(g.bars) then
        --p:log('G()| here')
        PI:InitGlobalSettings(g)
    end
    return g
end

-- /run ABP_Table.toString(Profile:GetBar(1))
--- @return Profile_Bar
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
    return ns.db.profile.bars
end

function P:GetBarSize()
    local bars = P:GetBars()
    if isNotTable(bars) then return 0 end
    return tsize(bars)
end

--- @param frameIndex number The frame index number
--- @param isEnabled boolean The enabled state
function P:SetBarEnabledState(frameIndex, isEnabled)
    local bar = self:GetBar(frameIndex)
    bar.enabled = isEnabled
end

--- @param frameIndex number The frame index number
function P:IsBarEnabled(frameIndex)
    local bar = self:GetBar(frameIndex)
    return bar and bar.enabled
end

--- @param frameIndex number The frame index number
function P:GetBarLockValue(frameIndex)
    local bar = self:GetBar(frameIndex)
    return bar.locked or ''
end

--- @param frameIndex number The frame index number
--- @param value string Allowed values are "always", "in-combat", or nil
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

function P:IsCharacterSpecificAnchor()
    return true == self.profile[ConfigNames.character_specific_anchors]
end

--- @param frameIndex number
--- @return _RegionAnchor
function P:GetAnchor(frameIndex)
    if self:IsCharacterSpecificAnchor() then return self:GetCharacterSpecificAnchor(frameIndex) end
    --p:log('GetAnchor| Is global anchor')
    return self:GetGlobalAnchor(frameIndex)
end

--- @param frameIndex number
--- @return _RegionAnchor
function P:GetGlobalAnchor(frameIndex)
    --- @type Global_Profile_Bar
    local g = self:G()
    local fn = P:GetFrameNameByIndex(frameIndex)
    --- @type Profile_Global_Config
    local buttonConf = g.bars[fn]
    if not buttonConf then buttonConf = PI:InitGlobalButtonConfig(g, fn) end
    if Table.isEmpty(buttonConf.anchor) then
        buttonConf.anchor = PI:InitGlobalButtonConfigAnchor(g, fn)
    end
    return buttonConf.anchor
end

--- @param frameIndex number
--- @return _RegionAnchor
function P:GetCharacterSpecificAnchor(frameIndex) return self:GetBar(frameIndex).anchor end

--- @param frameAnchor _RegionAnchor
--- @param frameIndex number
function P:SaveAnchor(frameAnchor, frameIndex)
    -- always sync the character specific settings
    self:SaveCharacterSpecificAnchor(frameAnchor, frameIndex)

    if not self:IsCharacterSpecificAnchor() then
        self:SaveGlobalAnchor(frameAnchor, frameIndex)
    end
end

--- @param frameIndex number
--- @return Global_Profile_Bar
function P:GetGlobalBar(frameIndex)
    local frameName = self:GetFrameNameByIndex(frameIndex)
    return frameIndex and self:G().bars[frameName]
end

--- Global
--- @param frameAnchor _RegionAnchor
--- @param frameIndex number
function P:SaveGlobalAnchor(frameAnchor, frameIndex)
    local globalBarConf = self:GetGlobalBar(frameIndex)
    CopyAnchor(frameAnchor, globalBarConf.anchor)
end

--- @param frameAnchor _RegionAnchor
--- @param frameIndex number
function P:SaveCharacterSpecificAnchor(frameAnchor, frameIndex)
    local barProfile = self:GetBar(frameIndex)
    CopyAnchor(frameAnchor, barProfile.anchor)
end

function P:IsActionButtonMouseoverGlowEnabled() return self:P().action_button_mouseover_glow == true end
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

--- @param frameIndex number The frame index number
--- @param isEnabled boolean The enabled state
function P:SetShowIndex(frameIndex, isEnabled)
    self:GetBar(frameIndex).show_button_index = (isEnabled == true)
end

--- @param frameIndex number The frame index number
--- @param isEnabled boolean The enabled state
function P:SetShowKeybindText(frameIndex, isEnabled)
    self:GetBar(frameIndex).show_keybind_text = (isEnabled == true)
end

--- @param frameIndex number The frame index number
--- @return boolean
function P:IsShowIndex(frameIndex) return self:GetBar(frameIndex).show_button_index == true end

--- @param frameIndex number The frame index number
function P:IsShowKeybindText(frameIndex) return self:GetBar(frameIndex).show_keybind_text == true end

--- @param frameIndex number The frame index number
function P:IsShowEmptyButtons(frameIndex) return self:GetBar(frameIndex).widget.show_empty_buttons == true end

function P:GetFrameNameByIndex(frameIndex) return PI:GetFrameNameByIndex(frameIndex) end

--- @return FrameWidget
function P:GetFrameWidgetByIndex(frameIndex) return _G[self:GetFrameNameByIndex(frameIndex)].widget end

function P:GetActionbarFrameCount() return PI.ActionbarCount end

function P:GetAllFrameNames()
    local fnames = {}
    for i=1, self:GetActionbarFrameCount() do
        local fn = self:GetFrameNameByIndex(i)
        tinsert(fnames, fn)
    end
    tsort(fnames)
    return fnames
end

--- Only return the bars that do exist. Some old profile button info
--- may exist even though the size of bar may not include these buttons.
--- The number of buttons do not reflect how many buttons actually exist because
--- the addon doesn't cleanup old data.
-- TODO: Should we cleanup old config?
--- @param btnType string spell, macro, item
function P:FindButtonsByType(btnType)
    local buttons = {}
    for _, bar in pairs(self:GetBars()) do
        if bar.buttons then
            for buttonName, button in pairs(bar.buttons) do
                if btnType == button.type and _G[buttonName] then
                    buttons[buttonName] = button
                end
            end
        end
    end
    return buttons
end

function P:IsHideWhenTaxi() return self.profile[ConfigNames.hide_when_taxi] == true end

--- @param anchorType string
--- @see TooltipAnchor
function P:SetTooltipAnchorType(anchorType) self.profile[ConfigNames.tooltip_anchor_type] = anchorType end
--- @see TooltipAnchor
--- @return string One of TooltipAnchor values
function P:GetTooltipAnchorType() return self.profile[ConfigNames.tooltip_anchor_type] or GC.TooltipAnchor.CURSOR_TOPRIGHT end

--- @return Profile_Config_Names
function P:GetConfigNames() return ConfigNames end

--- @return TooltipKey
function P:GetTooltipKey() return TooltipKey end

--- @return TooltipAnchorTypeKey
function P:GetTooltipAnchorTypeKey() return TooltipAnchorTypeKey end

--[[-----------------------------------------------------------------------------
Listen to Message
-------------------------------------------------------------------------------]]
P:RegisterMessage(GC.M.OnDBInitialized, function(msg)
    p:log(10, '%s received..', msg)
    P.profile = ns.db.profile
end)

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local pairs = pairs
local tinsert, tsort = table.insert, table.sort
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub
local Compat = O.Compat

local PI = O.ProfileInitializer
local Table, String = ns:Table(), ns:String()
local IsBlankStr = String.IsBlank
local IsEmptyTable, IsNotTable, TableSize = Table.IsEmpty, Table.isNotTable, Table.size
local IsTable = Table.isTable

--- @type table<number, Profile_Bar>
local barProfiles = {}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class Profile : BaseLibraryObject_WithAceEvent
local P = LibStub:NewLibrary(M.Profile); if not P then return end; ns:AceEvent(P)
local p = ns:LC().PROFILE:NewLogger(M.Profile)

local ConfigNames = GC.Profile_Config_Names
local C = GC:GetAceLocale()

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
        [TooltipKeyName.SHOW]  = C['Show'],
        [TooltipKeyName.ALT]   = C['ALT'],
        [TooltipKeyName.CTRL]  = C['CTRL'],
        [TooltipKeyName.SHIFT] = C['SHIFT'],
        [TooltipKeyName.HIDE]  = C['Hide'],
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
--- @param dest _RegionAnchor
--- @param source _RegionAnchor
local function CopyAnchor(source, dest)
    dest.point = source.point
    dest.relativeTo = source.relativeTo
    dest.relativePoint = source.relativePoint
    dest.x = source.x
    dest.y = source.y
end

--- @param frameIndex number
--- @return Name
local function GetBarName(frameIndex)
    assert(type(frameIndex) == 'number' and frameIndex > 0, "GetBarName: frameIndex should be a number > 0")
    return 'ActionbarPlusF' .. frameIndex
end

local function InitGlobalSettings()
    local g = ns.db.global
    if IsNotTable(g.bars) then PI:InitGlobalSettings(g, GetBarName) end
end

--- @param barName Name The profile name of the action bar
--- @return Profile_Bar
local function GetBarProfileByName(barName)
    assert(type(barName) == 'string', 'GetBarProfileByName(): barName should be a string.')
    return ns.db.profile.bars[barName] end

--- @return Profile_Bar
--- @param frameIndex number
local function GetBarProfileByIndex(frameIndex)
    if barProfiles[frameIndex] then return barProfiles[frameIndex] end
    local barProfileName    = GetBarName(frameIndex)
    local barProfile        = GetBarProfileByName(barProfileName)
    barProfiles[frameIndex] = barProfile
    return barProfile
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param obj any
function P:Mixin(obj)
    return ns:K():Mixin(obj, self)
end

--local function removeElement(tbl, value)
--    for i, v in ipairs(tbl) do if v == value then tbl[i] = nil end end
--end

--- @param btnConf Profile_Button
--- @return boolean
function P:IsEmptyButtonConfig(btnConf)
    return IsEmptyTable(btnConf) or IsBlankStr(btnConf.type)
end

--- Removes a particular actionType data from Profile_Button
--- @param frameIndex Index
--- @param btnUIName Name
function P:CleanupActionTypeData(frameIndex, btnUIName)
    local btnConf, btnConfName = self:GetButtonConfig(frameIndex, btnUIName)
    if not btnConf then return end

    if IsEmptyTable(btnConf) or IsBlankStr(btnConf.type) then
        self:ResetButtonConfig(frameIndex, btnConfName)
        return
    end

    local actionTypes = O.ActionType:GetOtherNamesExcept(btnConf.type)
    for _, v in ipairs(actionTypes) do if v ~= nil then btnConf[v] = nil end end
end

--- FORMAT: Spec1: buttonName, spec2: buttonName_2, specN: buttonName_N
--- @param buttonName Name
function P:GetButtonConfigName(buttonName)
    -- TODO next: shorten primary button config name, ie b1, f1b1_2
    local bName    = buttonName
    if not Compat:IsMultiSpecEnabled() then return bName end

    -- p:vv(function() return 'Has dual spec: %s', dualSpec end)
    local activeSpec = Compat:GetSpecializationID()
    if activeSpec == 1 then return bName end

    bName = bName .. '_' .. activeSpec
    return bName
end

--- @return table<number, Profile_Button> This is the top leve ["buttons"] = {} config
function P:GetButtonsConfig(frameIndex)
    local bar = self:GetBar(frameIndex)
    local buttons = bar.buttons or {}
    bar.buttons = buttons
    return buttons
end

--- @return boolean
function P:ShouldCopyPrimarySpecButtons()
    if Compat:IsPrimarySpec() then return false end

    -- value of 1 means that the non-primary specs was
    -- not yet initialized for the first time.
    return ns.db.profile.spec2_init ~= 1
end

--- @param frameIndex Index
--- @param buttonName string
--- @return Profile_Button, Name The button config and the button config name
function P:GetButtonConfig(frameIndex, buttonName)
    local bar = self:GetBar(frameIndex)
    local buttons = bar.buttons or {}
    bar.buttons = buttons
    -- TODO next: shorten name, ie b1, f1b1_2
    local btnConfName = self:GetButtonConfigName(buttonName)
    if not buttons[btnConfName] then
        buttons[btnConfName] = PI:CreateSingleButtonTemplate()
    end
    return buttons[btnConfName], btnConfName
end

--- @return Profile_Config
function P:CreateDefaultProfile() InitGlobalSettings(); return PI:InitNewProfile(GetBarName) end

--- @return Profile_Config
function P:P() return ns.db.profile  end
--- @return Global_Profile_Config
function P:G() return ns.db.global end

-- /run ABP_Table.toString(Profile:GetBar(1))
--- @param frameIndex Index
--- @return Profile_Bar
function P:GetBar(frameIndex)
    local bar = barProfiles[frameIndex] or GetBarProfileByIndex(frameIndex)
    bar.buttons = bar.buttons or {}
    return bar
end

--- @param frameIndex Index
--- @param btnConfName Name The profile button dual-spec name, not the UI button name
function P:ResetButtonConfig(frameIndex, btnConfName)
    local barConf = self:GetBar(frameIndex);
    if barConf.buttons[btnConfName] then barConf.buttons[btnConfName] = nil end
end

--- @return table<string, Profile_Bar>
function P:GetBars() return ns.db.profile.bars end

--- @return number
function P:GetBarSize()
    local bars = self:GetBars()
    if IsNotTable(bars) then return 0 end
    return TableSize(bars)
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
    return self:GetGlobalAnchor(frameIndex)
end

--- @param frameIndex number
--- @return _RegionAnchor
function P:GetGlobalAnchor(frameIndex)
    local g          = self:G()
    local barName    = GetBarName(frameIndex)
    local buttonConf = self:GetGlobalBar(frameIndex)
    if not buttonConf then buttonConf = PI:InitGlobalButtonConfig(g, barName) end
    if IsEmptyTable(buttonConf.anchor) then
        buttonConf.anchor = PI:InitGlobalButtonConfigAnchor(g, barName)
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
    local frameName = GetBarName(frameIndex)
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

--- @param frameIndex number The frame index number
--- @return boolean
function P:IsBarEnabled(frameIndex)
    local bar = self:GetBar(frameIndex)
    return bar and IsTable(bar) and bar.enabled == true
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
P:RegisterMessage(GC.M.OnDBInitialized, function(msg, source)
    P.profile = ns.db.profile
end)

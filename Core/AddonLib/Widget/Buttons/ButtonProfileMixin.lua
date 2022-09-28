--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local IsShiftKeyDown, IsAltKeyDown, IsControlKeyDown = IsShiftKeyDown, IsAltKeyDown, IsControlKeyDown

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local String, Table, WAttr = O.String, O.Table, O.GlobalConstants.WidgetAttributes
local SPELL, ITEM, MACRO, MOUNT = WAttr.SPELL, WAttr.ITEM, WAttr.MACRO, WAttr.MOUNT
local IsTableEmpty = Table.isEmpty

local p = O.LogFactory(Core.M.ButtonProfileMixin)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

---@class ButtonProfileMixin
local _L = LibStub:NewLibrary(Core.M.ButtonProfileMixin)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

---@return Profile
function _L:P() return self.profile end
---@return ButtonUI
function _L:B() return self.button end
---@return ButtonUIWidget
function _L:W() return self end
---@return Profile
function _L:_Profile() return self.profile end
---@return ButtonUI
function _L:_Button() return self.button end
---@return ButtonUIWidget
function _L:_Widget() return self end

function _L:invalidButtonData(o, key)
    if type(o) ~= 'table' then return true end
    if type(o[key]) ~= 'nil' then
        local d = o[key]
        if type(d) == 'table' then return (String.IsBlank(d['id']) and String.IsBlank(d['index'])) end
    end
    return true
end
function _L:IsEmpty()
    local conf = self:GetConfig()
    return conf and String.IsEmpty(conf.type)
end

---#### Get Profile Button Config Data
---@return Profile_Button
function _L:GetConfig() return self:W().buttonData:GetData() end
---@return Profile_Config
function _L:GetProfileData() return self:W().buttonData:GetProfileData() end

---@param type string One of: spell, item, or macro
function _L:GetConfigActionbarData(type)
    local btnData = self:GetConfig()
    if self:invalidButtonData(btnData, type) then return nil end
    return btnData[type]
end

---@return Profile_Spell
function _L:GetSpellData() return self:GetConfigActionbarData(SPELL) end
---@return Profile_Item
function _L:GetItemData() return self:GetConfigActionbarData(ITEM) end
---@return Profile_Macro
function _L:GetMacroData() return self:GetConfigActionbarData(MACRO) end
---@return boolean
function _L:IsMacro() return self:IsConfigOfType(self:GetConfig(), MACRO) end
---@return boolean
function _L:IsSpell() return self:IsConfigOfType(self:GetConfig(), SPELL) end
---@return boolean
function _L:IsItem() return self:IsConfigOfType(self:GetConfig(), ITEM) end
---@return boolean
function _L:IsMount() return self:IsConfigOfType(self:GetConfig(), MOUNT) end

---@param config Profile_Button
---@param type string spell, item, macro, mount, etc
function _L:IsConfigOfType(config, type)
    if IsTableEmpty(config) then return false end
    return config.type and type == config.type
end

---@return boolean true if the key override is pressed
function _L:IsTooltipModifierKeyDown()
    local tooltipKey = self:GetTooltipVisibilityKey();
    return self:IsOverrideKeyDown(tooltipKey)
end

---@return boolean true if the key override is pressed
function _L:IsTooltipCombatModifierKeyDown()
    local combatOverride = self:GetTooltipVisibilityCombatOverrideKeyOption();
    return self:IsOverrideKeyDown(combatOverride)
end

---@see TooltipKeyName
---@param value string One of TooltipKeyName value
---@return boolean true if the key override is pressed
function _L:IsOverrideKeyDown(value)
    local tooltipKey = self:_Profile():GetTooltipKey().names
    if tooltipKey.SHOW == value then return true end
    if tooltipKey.HIDE == value then return false end

    if tooltipKey.ALT == value then
        return IsAltKeyDown()
    elseif tooltipKey.CTRL == value then
        return IsControlKeyDown()
    elseif tooltipKey.SHIFT == value then
        return IsShiftKeyDown()
    end
    return false
end

function _L:GetTooltipVisibilityKey()
    local profile = self:_Profile()
    local profileData = profile:GetProfileData()
    return profileData[profile:GetConfigNames().tooltip_visibility_key]
end

function _L:GetTooltipVisibilityCombatOverrideKeyOption()
    local profile = self:_Profile()
    local profileData = profile:GetProfileData()
    return profileData[profile:GetConfigNames().tooltip_visibility_combat_override_key]
end

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub, M, LogFactory, G = ABP_LibGlobals:LibPack_UI()
---@type String
local String = G(M.String)

local SPELL,ITEM,MACRO = G:SpellItemMacroAttributes()
local IsShiftKeyDown, IsAltKeyDown, IsControlKeyDown = IsShiftKeyDown, IsAltKeyDown, IsControlKeyDown


local p = LogFactory:NewLogger('ButtonProfileMixin')

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

---@class ButtonProfileMixin
local _L = LibStub:NewLibrary(M.ButtonProfileMixin)

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

---#### Get Profile Button Config Data
---@return ProfileButton
function _L:GetConfig() return self:W().buttonData:GetData() end
---@return ProfileTemplate
function _L:GetProfileData() return self:W().buttonData:GetProfileData() end

---@param type string One of: spell, item, or macro
function _L:GetConfigActionbarData(type)
    local btnData = self:GetConfig()
    if self:invalidButtonData(btnData, type) then return nil end
    return btnData[type]
end

---@return SpellData
function _L:GetSpellData() return self:GetConfigActionbarData(SPELL) end
---@return ItemData
function _L:GetItemData() return self:GetConfigActionbarData(ITEM) end
---@return MacroData
function _L:GetMacroData() return self:GetConfigActionbarData(MACRO) end
---@return boolean
function _L:IsMacro() return self:IsMacroConfig(self:GetConfig()) end
---@return boolean
function _L:IsSpell() return self:IsSpellConfig(self:GetConfig()) end
---@return boolean
function _L:IsItem() return self:IsItemConfig(self:GetConfig()) end

---@param config ProfileButton
---@return boolean
function _L:IsMacroConfig(config) return config and config.type and MACRO == config.type end
---@param config ProfileButton
---@return boolean
function _L:IsSpellConfig(config) return config and config.type and SPELL == config.type end
---@param config ProfileButton
---@return boolean
function _L:IsItemConfig(config) return config and config.type and ITEM == config.type end

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

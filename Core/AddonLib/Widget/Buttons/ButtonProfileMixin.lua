--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local IsShiftKeyDown, IsAltKeyDown, IsControlKeyDown = IsShiftKeyDown, IsAltKeyDown, IsControlKeyDown

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace()
local LibStub, Core, O = ns.O.LibStub, ns.Core, ns.O

local GC = O.GlobalConstants
local CN = GC.Profile_Config_Names
local String, Table, WAttr = O.String, O.Table, GC.WidgetAttributes
local SPELL, ITEM, MACRO, MOUNT, COMPANION, BATTLE_PET =
            WAttr.SPELL, WAttr.ITEM, WAttr.MACRO,
            WAttr.MOUNT, WAttr.COMPANION, WAttr.BATTLE_PET
local IsTableEmpty = Table.isEmpty
local IsEmptyStr, IsBlankStr = String.IsEmpty, String.IsBlank
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
---@return ButtonUIWidget
function _L:W() return self end
---@return ButtonUI
function _L:B() return self.button end

function _L:invalidButtonData(o, key)
    if type(o) ~= 'table' then return true end
    if type(o[key]) ~= 'nil' then
        local d = o[key]
        if type(d) == 'table' then return (IsBlankStr(d['id']) and IsBlankStr(d['index'])) end
    end
    return true
end

function _L:IsEmpty()
    local conf = self:GetConfig()
    if not (conf and conf.type) then return true end
    return Table.isEmpty(conf[conf.type])
end

---#### Get Profile Button Config Data
---@return Profile_Button
function _L:GetConfig() return self:W():GetButtonData():GetConfig() end
---@return Profile_Config
function _L:GetProfileConfig() return self:W():GetButtonData():GetProfileConfig() end

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
---@see Interface/FrameXML/SecureHandlers.lua
---@return boolean
function _L:IsCompanion() return self:IsConfigOfType(self:GetConfig(), COMPANION) end
function _L:IsBattlePet() return self:IsConfigOfType(self:GetConfig(), BATTLE_PET) end

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
    local tooltipKey = self:P():GetTooltipKey().names
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
    return self:GetProfileConfig()[CN.tooltip_visibility_key]
end

function _L:GetTooltipVisibilityCombatOverrideKeyOption()
    return self:GetProfileConfig()[CN.tooltip_visibility_combat_override_key]
end

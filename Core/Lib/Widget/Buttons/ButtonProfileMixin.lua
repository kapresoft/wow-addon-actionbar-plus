--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local IsShiftKeyDown, IsAltKeyDown, IsControlKeyDown = IsShiftKeyDown, IsAltKeyDown, IsControlKeyDown

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub

local CN = GC.Profile_Config_Names
local String, Table, WAttr = O.String, O.Table, GC.WidgetAttributes
local SPELL, ITEM, MACRO, MOUNT, COMPANION, BATTLE_PET, EQUIPMENT_SET =
            WAttr.SPELL, WAttr.ITEM, WAttr.MACRO,
            WAttr.MOUNT, WAttr.COMPANION, WAttr.BATTLE_PET,
            WAttr.EQUIPMENT_SET
local IsTableEmpty = Table.IsEmpty
local IsEmptyStr, IsBlankStr = String.IsEmpty, String.IsBlank
local p = O.LogFactory(M.ButtonProfileMixin)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

---@class ButtonProfileMixin : BaseLibraryObject
local L = LibStub:NewLibrary(M.ButtonProfileMixin)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

---@return Profile
function L:P() return self.profile end
---@return ButtonUIWidget
function L:W() return self end
---@return ButtonUI
function L:B() return self.button end

function L:invalidButtonData(o, key)
    if type(o) ~= 'table' then return true end
    if type(o[key]) ~= 'nil' then
        local d = o[key]
        if type(d) == 'table' then return (IsBlankStr(d['id']) and IsBlankStr(d['index'])) end
    end
    return true
end

function L:IsEmpty()
    local conf = self:GetConfig()
    if IsTableEmpty(conf) or IsBlankStr(conf.type) then return true end
    return IsTableEmpty(conf[conf.type])
end

---#### Get Profile Button Config Data
---@return Profile_Button
function L:GetConfig() return self:W():GetButtonData():GetConfig() end
---@return Profile_Config
function L:GetProfileConfig() return self:W():GetButtonData():GetProfileConfig() end

---@param type string One of: spell, item, or macro
function L:GetButtonTypeData(type)
    local btnData = self:GetConfig()
    if self:invalidButtonData(btnData, type) then return nil end
    return btnData[type]
end

---@return Profile_Spell
function L:GetSpellData() return self:GetButtonTypeData(SPELL) end
---@return Profile_Item
function L:GetItemData() return self:GetButtonTypeData(ITEM) end
---@return Profile_Macro
function L:GetMacroData() return self:GetButtonTypeData(MACRO) end
---@return boolean
function L:IsMacro() return self:IsConfigOfType(self:GetConfig(), MACRO) end
---@return boolean
function L:IsSpell() return self:IsConfigOfType(self:GetConfig(), SPELL) end
---@return boolean
function L:IsItem() return self:IsConfigOfType(self:GetConfig(), ITEM) end
---@return boolean
function L:IsMount() return self:IsConfigOfType(self:GetConfig(), MOUNT) end
---@see Interface/FrameXML/SecureHandlers.lua
---@return boolean
function L:IsCompanion() return self:IsConfigOfType(self:GetConfig(), COMPANION) end
---@return boolean
function L:IsBattlePet() return self:IsConfigOfType(self:GetConfig(), BATTLE_PET) end
---@return boolean
function L:IsEquipmentSet() return self:IsConfigOfType(self:GetConfig(), EQUIPMENT_SET) end

---@param config Profile_Button
---@param type string spell, item, macro, mount, etc
function L:IsConfigOfType(config, type)
    if IsTableEmpty(config) then return false end
    return config.type and type == config.type
end

---@return boolean true if the key override is pressed
function L:IsTooltipModifierKeyDown()
    local tooltipKey = self:GetTooltipVisibilityKey();
    return self:IsOverrideKeyDown(tooltipKey)
end

---@return boolean true if the key override is pressed
function L:IsTooltipCombatModifierKeyDown()
    local combatOverride = self:GetTooltipVisibilityCombatOverrideKeyOption();
    return self:IsOverrideKeyDown(combatOverride)
end

---@see TooltipKeyName
---@param value string One of TooltipKeyName value
---@return boolean true if the key override is pressed
function L:IsOverrideKeyDown(value)
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

function L:GetTooltipVisibilityKey()
    return self:GetProfileConfig()[CN.tooltip_visibility_key]
end

function L:GetTooltipVisibilityCombatOverrideKeyOption()
    return self:GetProfileConfig()[CN.tooltip_visibility_combat_override_key]
end

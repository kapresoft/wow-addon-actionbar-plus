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
local P = O.Profile
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

--- @class ButtonProfileMixin : BaseLibraryObject
local L = LibStub:NewLibrary(M.ButtonProfileMixin)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param buttonData Profile_Button
local function CleanupTypeData(buttonData)
    local function removeElement(tbl, value)
        for i, v in ipairs(tbl) do
            if v == value then tbl[i] = nil end
        end
    end

    if buttonData == nil or buttonData.type == nil then return end
    local btnTypes = { SPELL, MACRO, ITEM, MOUNT, COMPANION, BATTLE_PET, EQUIPMENT_SET }
    removeElement(btnTypes, buttonData.type)
    for _, v in ipairs(btnTypes) do
        if v ~= nil then buttonData[v] = {} end
    end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @param widget ButtonUIWidget
function L:New(widget)
    return ns:K():CreateAndInitFromMixin(L, widget)
end

--- @param widget ButtonUIWidget
function L:Init(widget)
    self.w = widget
    self.config = self.w.buttonData:GetConfig()
end

function L:invalidButtonData(o, key)
    if type(o) ~= 'table' then return true end
    if type(o[key]) ~= 'nil' then
        local d = o[key]
        if type(d) == 'table' then return (IsBlankStr(d['id']) and IsBlankStr(d['index'])) end
    end
    return true
end

function L:IsEmpty()
    if IsTableEmpty(self.config) then return true end
    local type = self.config.type
    if IsBlankStr(type) then return true end
    if IsTableEmpty(self.config[type]) then return true end
    return false
end

---#### Get Profile Button Config Data
--- @return Profile_Button
function L:GetConfig() return self.w:GetButtonData():GetConfig() end

--- @return Profile_Button
function L:GetProfileButtonData()
    local profileButton = O.Profile:GetButtonData(self.w.frameIndex, self.w.index)
    -- self cleanup
    CleanupTypeData(profileButton)
    return profileButton
end

--- @return Profile_Config
function L:GetProfileConfig() return self.w:GetButtonData():GetProfileConfig() end

--- @param type string One of: spell, item, or macro
function L:GetButtonTypeData(type)
    local btnData = self:GetConfig()
    if self:invalidButtonData(btnData, type) then return nil end
    return btnData[type]
end

--- @return Profile_Spell
function L:GetSpellData() return self:GetButtonTypeData(SPELL) end
--- @return Profile_Item
function L:GetItemData() return self:GetButtonTypeData(ITEM) end
--- @return Profile_Macro
function L:GetMacroData() return self:GetButtonTypeData(MACRO) end
--- @return boolean
function L:IsMacro() return self:IsConfigOfType(self:GetConfig(), MACRO) end
--- @return boolean
function L:IsSpell() return self:IsConfigOfType(self:GetConfig(), SPELL) end
--- @return boolean
function L:IsItem() return self:IsConfigOfType(self:GetConfig(), ITEM) end
--- @return boolean
function L:IsMount() return self:IsConfigOfType(self:GetConfig(), MOUNT) end
--- @see Interface/FrameXML/SecureHandlers.lua
--- @return boolean
function L:IsCompanion() return self:IsConfigOfType(self:GetConfig(), COMPANION) end
--- @return boolean
function L:IsBattlePet() return self:IsConfigOfType(self:GetConfig(), BATTLE_PET) end
--- @return boolean
function L:IsEquipmentSet() return self:IsConfigOfType(self:GetConfig(), EQUIPMENT_SET) end

--- @param config Profile_Button
--- @param type string spell, item, macro, mount, etc
function L:IsConfigOfType(config, type)
    if IsTableEmpty(config) then return false end
    return config.type and type == config.type
end

--- @return boolean true if the key override is pressed
function L:IsTooltipModifierKeyDown()
    local tooltipKey = self:GetTooltipVisibilityKey();
    return self:IsOverrideKeyDown(tooltipKey)
end

--- @return boolean true if the key override is pressed
function L:IsTooltipCombatModifierKeyDown()
    local combatOverride = self:GetTooltipVisibilityCombatOverrideKeyOption();
    return self:IsOverrideKeyDown(combatOverride)
end

--- @see TooltipKeyName
--- @param value string One of TooltipKeyName value
--- @return boolean true if the key override is pressed
function L:IsOverrideKeyDown(value)
    local tooltipKey = P:GetTooltipKey().names
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

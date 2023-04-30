--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetSpellSubtext, GetSpellInfo, GetSpellLink = GetSpellSubtext, GetSpellInfo, GetSpellLink
local GetCursorInfo, GetSpellCooldown = GetCursorInfo, GetSpellCooldown
local GetItemCooldown, GetItemCount =  GetItemCooldown, GetItemCount
local C_ToyBox, C_Container = C_ToyBox, C_Container
local IsSpellInRange, GetItemSpell = IsSpellInRange, GetItemSpell
local UnitIsDead, GetUnitName = UnitIsDead, GetUnitName
local UnitClass, IsStealthed, GetShapeshiftForm = UnitClass, IsStealthed, GetShapeshiftForm

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format = string.format
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O = ns.O
local pformat = ns.pformat

local String = O.String
local IsAnyOf, IsBlank, IsNotBlank, strlower = String.IsAnyOf, String.IsBlank, String.IsNotBlank, string.lower
local DruidAPI, GC = O.DruidAPI, O.GlobalConstants
local BaseAPI, WAttr, UnitId = O.BaseAPI, GC.WidgetAttributes, GC.UnitId
local SPELL, ITEM, MACRO, MOUNT = WAttr.SPELL, WAttr.ITEM, WAttr.MACRO, WAttr.MOUNT

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class API
local S = {}
---@type API
_API = S

--TODO: Next Deprecate Global Var _API
ns:Register(ns.M.API, S)

local p = O.LogFactory(ns.M.API)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--todo next: start using CursorHasSpell(),
--CursorHasItem() - True if the cursor currently holds an item.
--CursorHasMacro() - Returns 1 if the cursor is currently dragging a macro.
--CursorHasMoney() -
-- p:log('cursor-has-spell: %s', CursorHasSpell())
---@return CursorInfo
function S:GetCursorInfo()
    -- actionType string spell, item, macro, mount, etc..
    local actionType, info1, info2, info3 = GetCursorInfo()
    if IsBlank(actionType) then return nil end
    ---@type CursorInfo
    local c = { type = actionType or '', info1 = info1, info2 = info2, info3 = info3 }

    local info2Lc = strlower(c.info2 or '')
    if c.type == 'companion' and 'mount' == info2Lc then
        c.info2 = info2Lc
        c.originalCursor = { type = c.type, info1 = c.info1, info2 = info2 }
        c.type = c.info2
    end

    return c
end

---@see Blizzard_UnitId
function S:IsValidActionTarget() return self:HasTarget() and not UnitIsDead(UnitId.target) end
function S:HasTarget() return GetUnitName(UnitId.target) ~= nil end

---Note: should call ButtonData:ContainsValidAction() before calling this
---@return boolean|nil true, false or nil if not applicable; nil if spell cannot be applied to unit, i.e. targeting a harmful unit on a friendly player
---@param btnConfig Profile_Button
---@param targetUnit string one of "target", "focus", "mouseover", etc.. See Blizz APIs
function S:IsActionInRange(btnConfig, targetUnit)
    if btnConfig.type == SPELL then
        local inRange = IsSpellInRange(btnConfig.spell.name, targetUnit)
        if inRange == nil then return nil end
        return inRange == true or inRange == 1
    elseif btnConfig.type == ITEM then
        local inRange = IsSpellInRange(btnConfig.item.name, targetUnit)
        if inRange == nil then return nil end
        return inRange == true or inRange == 1
    elseif btnConfig.type == MACRO then
        local macroIndex = btnConfig.macro.index
        local spell = self:GetMacroSpellInfo(macroIndex)
        if not spell then return nil end
        local inRange = IsSpellInRange(spell.name, targetUnit)
        if inRange == nil then return nil end
        return inRange == true or inRange == 1
    end

    return false
end

function S:CanApplySpellOnTarget(spellName) return IsSpellInRange(spellName, UnitId.target) ~= nil end


--- See:
---  * https://wowpedia.fandom.com/wiki/API_GetSpellInfo
---### SpellInfo
---```
--- {
---    id = 1456,
---    name = 'Life Tap',
---    label = 'Life Tap (Rank 3)',
---    rank = 'Rank 3'
---    castTime = 0,
---    icon = 136126,
---    link = '[Life Tap]',
---    maxRange = 0,
---    minRange = 0,
--- }
---```
---@param spellNameOrId string Spell ID or Name
---@return Profile_Spell
function S:GetSpellInfo(spellNameOrId)
    local name, _, icon, castTime, minRange, maxRange, id = GetSpellInfo(spellNameOrId)
    if name then
        local subTextOrRank = GetSpellSubtext(spellNameOrId)
        local spellLink = GetSpellLink(spellNameOrId)
        ---@type Profile_Spell
        local spellInfo = { id = id, name = name, icon = icon,
                            link=spellLink, castTime = castTime,
                            minRange = minRange, maxRange = maxRange, rank = subTextOrRank,
                            isShapeshift = false, isStealth = false, isProwl = false }
        self:ApplySpellInfoAttributes(spellInfo)
        return spellInfo
    end
    return nil
end

function S:ApplySpellInfoAttributes(spellInfo)
    if not spellInfo then return end
    spellInfo.label = spellInfo.name
    if IsNotBlank(spellInfo.rank) then
        -- color codes format: |cAARRGGBB
        local labelFormat = '%s |c00747474(%s)|r'
        spellInfo.label = format(labelFormat, spellInfo.name, spellInfo.rank)
    end
    local rankLc = strlower(spellInfo.rank or '')
    local nameLc = strlower(spellInfo.name or '')

    -- Manual correction since [Moonkin Form] doesn't have rank as 'Shapeshift'
    if WAttr.MOONKIN_FORM == nameLc then spellInfo.rank = 'Shapeshift' end
    if WAttr.SHAPESHIFT == rankLc or WAttr.SHADOWFORM == nameLc then
        spellInfo.isShapeshift = true
    elseif WAttr.STEALTH == nameLc then spellInfo.isStealth = true
    elseif WAttr.PROWL == nameLc then spellInfo.isProwl = true end
end

---@param macroIndex number
---@return Profile_Spell
function S:GetMacroSpellInfo(macroIndex)
    --local macroIndex = btnConfig.macro.index
    local spellId = GetMacroSpell(macroIndex)
    if not spellId then return nil end
    return self:GetSpellInfo(spellId)
end
---@param spellNameOrId string|number
function S:IsPassiveSpell(spellNameOrId) return IsPassiveSpell(spellNameOrId) end

---@return SpellCooldownDetails
function S:GetSpellCooldownDetails(spellID, optionalSpell)
    local spell = optionalSpell or self:GetSpellInfo(spellID)
    if spell == nil then error("Spell not found: " .. spellID) end
    local start, duration, enabled, modRate = GetSpellCooldown(spellID);
    local cooldown = { start = start, duration = duration, enabled = enabled, modRate = modRate }
    ---@class SpellCooldownDetails
    local details = { spell = spell, cooldown = cooldown }
    return details
end

--- See: [GetSpellCooldown](https://wowpedia.fandom.com/wiki/API_GetSpellCooldown)
--- @param spellNameOrID number|string Spell ID or Name. When passing a name requires the spell to be in your Spellbook.
--- @param optionalSpell Profile_Spell
--- @return SpellCooldown
function S:GetSpellCooldown(spellNameOrID, optionalSpell)
    if not spellNameOrID then return nil end
    local start, duration, enabled, modRate = GetSpellCooldown(spellNameOrID);
    local name, _, icon, _, _, _, spellID = GetSpellInfo(spellNameOrID)

    ---@type SpellCooldown
    local cd = {
        spell = { name = name, id = spellID, icon = icon },
        start = start, duration = duration, enabled = enabled, modRate = modRate }
    if optionalSpell then
        cd.spell.details = optionalSpell
    end
    return cd
end
---Example:
---@param optionalUnit string
---@see GlobalConstants#UnitId
---@see Blizzard_UnitId
---@return string One of DRUID, ROGUE, PRIEST, etc...
function S:GetUnitClass(optionalUnit)
    optionalUnit = optionalUnit or UnitId.player
    return select(2, UnitClass(optionalUnit))
end

---Example:
---```
---local playerClass = 'DRUID'
---local isValidClass = IsPlayerClassAnyOf('DRUID','ROGUE', 'PRIEST')
---assertThat(isValidClass).IsTrue()
---```
function S:IsPlayerClassAnyOf(...)
    local unitClass = self:GetUnitClass()
    return IsAnyOf(unitClass, ...)
end

---@param spellInfo Profile_Spell
function S:IsShapeShiftActive(spellInfo)
    if not spellInfo then return false end
    if self:IsPlayerClassAnyOf(GC.UnitClass.PRIEST, GC.UnitClass.ROGUE) then
        return GetShapeshiftForm() > 0
    end
    return DruidAPI:IsActiveForm(spellInfo.id)
end

--- Generalizes shapeshift and stealth and shapeshift form
---@param spellInfo Profile_Spell
function S:IsShapeshiftOrStealthSpell(spellInfo)
    return self:IsShapeshiftSpell(spellInfo)
            or self:IsStealthSpell(spellInfo.name)
end

--- Generalizes shapeshift and stealth and shapeshift form
---@param spellInfo Profile_Spell
function S:IsShapeshiftSpell(spellInfo) return true == spellInfo.isShapeshift end

---@param spellName string
function S:IsStealthSpell(spellName)
    return IsAnyOf(spellName, WAttr.PROWL, WAttr.STEALTH)
end

---@param spellInfo Profile_Spell
function S:GetSpellIcon(spellInfo)
    if not spellInfo then return nil end

    if self:IsShapeshiftSpell(spellInfo) then
        local unitClass = self:GetUnitClass(UnitId.player)
        if self:IsShapeShiftActive(spellInfo) then
            if unitClass == GC.UnitClass.DRUID then
                return GC.Textures.DRUID_FORM_ACTIVE_ICON
            elseif unitClass == GC.UnitClass.PRIEST then
                return GC.Textures.PRIEST_SHADOWFORM_ACTIVE_ICON
            end
        end
    elseif self:IsStealthSpell(spellInfo.name) and IsStealthed() then
        return GC.Textures.STEALTHED_ICON
    end
    return spellInfo.icon
end

---@param spellInfo Profile_Spell
function S:GetStealthIcon(spellInfo)
    if self:IsStealthSpell(spellInfo.name) and IsStealthed() then
        return GC.Textures.STEALTHED_ICON
    end
    return spellInfo.icon
end

---@param spellInfo Profile_Spell
function S:GetShapeshiftIcon(spellInfo)
    if self:IsShapeShiftActive(spellInfo) then return GC.Textures.DRUID_FORM_ACTIVE_ICON end
    return spellInfo.icon
end

---@param spellInfo Profile_Spell
function S:GetSpellAttributeValue(spellInfo)
    local spellAttrValue = spellInfo.id
    if self:IsShapeshiftOrStealthSpell(spellInfo) then
        spellAttrValue = spellInfo.name
    end
    return spellAttrValue
end

---@param itemID number
function S:IsToyItem(itemID)
    if not C_ToyBox then return false end
    local _itemID, toyName, icon, isFavorite, hasFanfare, quality = C_ToyBox.GetToyInfo(itemID)
    return not (_itemID == nil or toyName == nil)
end

function S:GetItemID(itemName)
    if String.IsBlank(itemName) then return nil end
    local link = select(2, GetItemInfo(itemName))
    if not link then return nil end
    local itemID = GetItemInfoFromHyperlink(link)
    return itemID
end

--- @param itemIDOrName number|string The itemID or itemName
--- @return number The numeric itemID
function S:ResolveItemID(itemIDOrName)
    if type(itemIDOrName) == 'string' then
        return self:GetItemID(itemIDOrName)
    elseif type(itemIDOrName) == 'number' then
        return itemIDOrName
    end
    return nil
end

---@param spellName string
function S:IsItemSpell(spellName) return spellName and GetItemInfo(spellName) ~= nil end

--- See: [GetItemInfo](https://wowpedia.fandom.com/wiki/API_GetItemInfo)
--- See: [GetItemInfoInstant](https://wowpedia.fandom.com/wiki/API_GetItemInfoInstant)
--- @param itemIDOrName number|string The itemID or itemName
--- @return ItemInfo
function S:GetItemInfo(itemIDOrName)
    local itemID = self:ResolveItemID(itemIDOrName); if not itemID then return nil end

    local itemName, itemLink,
        itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
        itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
        expacID, setID, isCraftingReagent = GetItemInfo(itemID)

    local count = GetItemCount(itemID, false, true, true) or 0

    ---@class ItemInfo
    local itemInfo = { id = itemID, name = itemName, link = itemLink, icon = itemTexture,
                       quality = itemQuality, level = itemLevel, minLevel = itemMinLevel,
                       type = itemType, subType = itemSubType, stackCount = itemStackCount,
                       count = count, equipLoc=itemEquipLoc, classID=classID,
                       subclassID=subclassID, bindType=bindType,
                       isCraftingReagent=isCraftingReagent }
    return itemInfo
end

---@return string, number
function S:GetItemSpellInfo(itemIdNameOrLink)
   local spellName, spellID = GetItemSpell(itemIdNameOrLink)
   return spellName, spellID
end

--- See: [GetItemCooldown](https://wowpedia.fandom.com/wiki/API_GetItemCooldown)
--- @param itemIDOrName number|string The itemID or itemName
--- @param optionalItem Profile_Item
--- @return ItemCooldown
function S:GetItemCooldown(itemIDOrName, optionalItem)
    local itemID = self:ResolveItemID(itemIDOrName); if not itemID then return nil end

    if C_Container then GetItemCooldown = C_Container.GetItemCooldown end
    local start, duration, enabled = GetItemCooldown(itemID)
    ---@class ItemCooldown
    local cd = {
        item = { id = itemID },
        start=start, duration=duration, enabled=enabled
    }
    if optionalItem then
        cd.item.details = optionalItem
        cd.item.name = optionalItem.name
    end
    return cd
end

---@return SpellCooldownDetails
function S:GSCD(spellID, optionalSpell) return S:GetSpellCooldownDetails(spellID, optionalSpell) end
---@return SpellCooldown
function S:GSC(spellID, optionalSpellName) return S:GetSpellCooldown(spellID, optionalSpellName) end
---@return ItemCooldown
function S:GIC(itemId, optionalItem) return S:GetItemCooldown(itemId, optionalItem) end

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local C_ToyBox, C_Container = C_ToyBox, C_Container
local C_MountJournal, C_PetBattles, C_PetJournal = C_MountJournal, C_PetBattles, C_PetJournal
--- Use C_AddOns.GetAddOnEnableStat(addonName, char) if available
local C_AddOns_GetAddOnEnableState = C_AddOns.GetAddOnEnableState
--- Else, WOTLK Uses GetAddOnEnableState(index, char)
local GetAddOnEnableState = GetAddOnEnableState
local UnitInVehicle, UnitOnTaxi = UnitInVehicle, UnitOnTaxi

local ABP_M6 = 'ActionbarPlus-M6'

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format = string.format
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, Compat = ns.O, ns.GC, ns.O.Compat

local String = ns:String()
local IsAnyOf, IsBlank, IsNotBlank, strlower = String.IsAnyOf, String.IsBlank, String.IsNotBlank, string.lower
local DruidAPI, ShamanAPI = O.DruidUnitMixin, O.ShamanUnitMixin
local PriestAPI, RogueAPI = O.PriestUnitMixin, O.RogueUnitMixin

local WAttr, UnitId = GC.WidgetAttributes, GC.UnitId
local SPELL, ITEM, MACRO, MOUNT = WAttr.SPELL, WAttr.ITEM, WAttr.MACRO, WAttr.MOUNT

local ROGUE_STEALTH_SPELL_ID = 1784
local DRUID_PROWL_SPELL_ID = 5215
local NIGHT_ELF_SHADOWMELD_SPELL_ID = 20580

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class API
local S = ns:NewLibStd(ns.M.API)
local p = ns:CreateDefaultLogger(ns.M.API)

local ACTION_BUTTON_USE_KEY_DOWN = 'ActionButtonUseKeyDown'
local LOCK_ACTION_BARS = 'lockActionBars'

S.ACTION_BUTTON_USE_KEY_DOWN = ACTION_BUTTON_USE_KEY_DOWN
S.LOCK_ACTION_BARS = LOCK_ACTION_BARS
--[[-----------------------------------------------------------------------------
Mixins
-------------------------------------------------------------------------------]]
--- @alias Mount MountMixin | C_MountJournal_MountInfo
--- @class MountMixin
local MountMixin = {}
--- @param o MountMixin
local function MountMixinMethods(o)
    ---@param mount C_MountJournal_MountInfo
    function o:Init(mount)
        assert(mount, "MountMixin::Mount is missing.")
        self.data = mount
        self.mt = {
            __tostring = function() return "MountMixin:: " .. self.mount.name end,
            __index = mount
        }
        setmetatable(self, self.mt)
    end
    --- @param mount C_MountJournal_MountInfo
    --- @return Mount
    function o:New(mount)
        return ns:K():CreateAndInitFromMixin(o, mount)
    end

    function o:IsFlyingMountMountUsable()
        if true ~= IsFlyableArea() then return false end
        return true == self.isUsable
    end

    function o:IsGroundMountMountUsable()
        if true == IsIndoors() then return false end
        return true == self.isUsable
    end
end; MountMixinMethods(MountMixin)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--todo next: start using CursorHasSpell(),
--CursorHasItem() - True if the cursor currently holds an item.
--CursorHasMacro() - Returns 1 if the cursor is currently dragging a macro.
--CursorHasMoney() -
--- @return CursorInfo
function S:GetCursorInfo()
    -- actionType string spell, item, macro, mount, etc..
    local actionType, info1, info2, info3 = GetCursorInfo()
    if IsBlank(actionType) then return nil end
    --- @type CursorInfo
    local c = { type = actionType or '', info1 = info1, info2 = info2, info3 = info3 }

    local info2Lc = strlower(c.info2 or '')
    if c.type == 'companion' and 'mount' == info2Lc then
        c.info2 = info2Lc
        c.originalCursor = { type = c.type, info1 = c.info1, info2 = info2 }
        c.type = c.info2
    end

    return c
end

function S:GetCurrentPlayer() return UnitName("player") end
function S:IsActionbarPlusM6Enabled() return self:IsAddOnEnabled(ABP_M6) end

--- @private
--- @param indexOrName IndexOrName
--- @return Enabled
function S:IsAddOnEnabled(indexOrName)
    local charName = self:GetCurrentPlayer()
    if not C_AddOns_GetAddOnEnableState then return self:IsAddOnEnabledLegacy(indexOrName, charName) end
    local intVal = C_AddOns_GetAddOnEnableState(indexOrName, charName)
    return intVal == 2
end

--- @private
--- @param indexOrName Name The name of the addon
--- @return boolean
function S:IsAddOnEnabledLegacy(indexOrName, charName)
    --- Note that the parameters are in different order compared
    --- to the new API C_AddOns.GetAddOnEnableState().
    --- GetAddOnEnableState is only used in WOTLK. classic era and
    --- retail uses C_AddOns.GetAddOnEnableState().
    return GetAddOnEnableState(charName, indexOrName) == 2
end

--- @see Blizzard_UnitId
function S:IsValidActionTarget() return self:HasTarget() and not UnitIsDead(UnitId.target) end
function S:HasTarget() return GetUnitName(UnitId.target) ~= nil end

--- @param spell SpellName
--- @param target UnitID
--- @return boolean
function S:IsSpellInRange(spell, target)
    local inRange = Compat:IsSpellInRange(spell, target);
    if inRange == nil then return nil end
    return inRange == true or inRange == 1
end

--- @param item ItemName
--- @param target UnitID
--- @return BooleanOptional A return of nil means that the item is not applicable for the target unit
function S:IsItemInRange(item, target)
    local inRange = IsItemInRange(item, target)
    if inRange == nil then return nil end
    return inRange == true or inRange == 1
end

---Note: should call ButtonData:ContainsValidAction() before calling this
--- @param btnConfig Profile_Button
--- @param targetUnit string one of "target", "focus", "mouseover", etc.. See Blizz APIs
--- @return BooleanOptional true, false or nil if not applicable; nil if spell cannot be applied to unit, i.e. targeting a harmful unit on a friendly player
function S:IsActionInRange(btnConfig, targetUnit)
    if btnConfig.type == SPELL then
        return self:IsSpellInRange(btnConfig.spell.name, targetUnit)
    elseif btnConfig.type == MACRO then
        local macroIndex = btnConfig.macro.index
        local spellName = self:GetMacroSpell(macroIndex)
        return self:IsSpellInRange(spellName, targetUnit)
    elseif btnConfig.type == ITEM then
        local itemName = btnConfig.item.name
        return self:IsItemInRange(itemName, targetUnit)
    end

    return false
end

--- @param item Profile_Item
--- @return Profile_Item
function S:UpdateAndGetItemData(item)
    if not item.classID then
        local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subclassID = GetItemInfoInstant(item.id)
        p:d(function() return 'Item[%s]: retrieved classID=%s subclassID=%s', item.name, classID, subclassID end)
        item.classID = classID
        item.subclassID = subclassID
    end
    return item
end

--- ### See: Enum.ItemClass
--- ```
--- Enum.ItemClass = {
---    Armor = 4,
---    Battlepet = 17,
---    Consumable = 0,
---    Container = 1,
---    CurrencyTokenObsolete = 10,
---    Gem = 3,
---    Glyph = 16,
---    ItemEnhancement = 8,
---    Key = 13,
---    Miscellaneous = 15,
---    PermanentObsolete = 14,
---    Profession = 19,
---    Projectile = 6,
---    Questitem = 12,
---    Quiver = 11,
---    Reagent = 5,
---    Recipe = 9,
---    Tradegoods = 7,
---    Weapon = 2,
---    WoWToken = 18
--- }
--- ```
---
--- This updates the item config and retrieve the classID and subClassID data
---@param item Profile_Item
---@param retrieveUpdate OptionalFlag Set to true to retrieve updated item if classID is missing
function S:IsItemConsumable(item, retrieveUpdate)
    local itemData = item
    local doUpdate = retrieveUpdate or true
    if itemData.classID == nil and doUpdate == true then
        itemData = self:UpdateAndGetItemData(item)
        p:v(function() return 'Retrieved updated item data: %s', item.name end)
    end
    return itemData.classID == Enum.ItemClass.Consumable
end

function S:CanApplySpellOnTarget(spellName) return Compat:IsSpellInRange(spellName, UnitId.target) ~= nil end


---@return boolean, SpellName, SpellID
---@param id SpellID The source spell ID
---@param name SpellName The source spell name
---@param icon Number The source spell Icon
local function IsRuneSpell(id, name, icon)
    local _name, _, _icon, _, _, _, _id = Compat:GetSpellInfo(name)
    if _name == nil or _icon == nil or id == _id or name == _name then
        return false
    end
    return _icon == icon, _name, _id;
end

--- @param spellNameOrId SpellName|SpellID
--- @return SpellName, SpellID
function S:GetSpellName(spellNameOrId)
    local name, rank, icon, castTime, minRange, maxRange, id = Compat:GetSpellInfo(spellNameOrId)
    return name, id
 end

--- @see https://warcraft.wiki.gg/wiki/Category:API_namespaces/C_Engraving
--- @param spellNameOrId SpellID_Name_Or_Index Spell ID or Name
--- @return SpellInfoBasic
function S:GetSpellInfoBasic(spellNameOrId)
    if not spellNameOrId then return nil end

    local name, _, icon, _, _, _, id = Compat:GetSpellInfo(spellNameOrId)
    if not name then return nil end
    --- @type SpellInfo
    local spellInfo = { id = id, name = name, icon = icon }
    return spellInfo
end

--- @param unit UnitID|nil Defaults to 'player'
--- @return SpellInfoBasic
function S:GetCurrentSpellCasting(unit)
    return self:GetUnitCastingInfoBasic(unit) or self:GetUnitChannelInfoBasic(unit)
end

--- @param unit UnitID|nil Defaults to 'player'
--- @return SpellInfoBasic
function S:GetUnitCastingInfoBasic(unit)
    unit = unit or UnitId.player
    local spn, _, icon, _, _, _, _, _, spID = UnitCastingInfo(unit)
    if not spn then return nil end

    --- @type SpellInfoBasic
    local ret = { id = spID, name = spn, icon = icon, empowered = false }
    return ret
end

--- @param unit UnitID|nil Defaults to 'player'
--- @return SpellInfoBasic
function S:GetUnitChannelInfoBasic(unit)
    unit = unit or UnitId.player
    local spn, _, icon, _, _, _, _, spID, isEmpowered = UnitChannelInfo(unit)
    if not spn then return nil end

    --- @type SpellInfoBasic
    local ret = { id = spID, name = spn, icon = icon, empowered = isEmpowered }
    return ret
end

--- @see https://warcraft.wiki.gg/wiki/Category:API_namespaces/C_Engraving
--- @param spellNameOrId SpellID_Name_Or_Index Spell ID or Name
--- @return SpellInfo
function S:GetSpellInfo(spellNameOrId)
    if not spellNameOrId then return nil end

    local name, rank, icon, castTime, minRange, maxRange, id = Compat:GetSpellInfo(spellNameOrId)
    if not name then return end

    local subTextOrRank = Compat:GetSpellSubtext(name)
    local spellLink = Compat:GetSpellLink(name)
    --- @type SpellInfo
    local spellInfo = {
        id = id, name = name, icon = icon,
        runeSpell = nil,
        link = spellLink, castTime = castTime,
        minRange = minRange, maxRange = maxRange, rank = subTextOrRank,
        isShapeshift = false, isStealth = false, isProwl = false }
    self:ApplySpellInfoAttributes(spellInfo)

    if not (C_Engraving and C_Engraving.IsKnownRuneSpell) then return spellInfo end
    local isRuneSpell, spName, spID = IsRuneSpell(id, name, icon)
    if not isRuneSpell then return spellInfo end

    spellInfo.runeSpell = {
        id = spID,
        name =  spName,
    }

    return spellInfo
end

--- @param spellInfo SpellInfo
function S:ApplySpellInfoAttributes(spellInfo)
    if not spellInfo then return end

    local spId = spellInfo.id
    if DruidAPI:IsDruidClass() then
        spellInfo.isProwl = DruidAPI:IsProwl(spId)
    elseif RogueAPI:IsRogueClass() then
        spellInfo.isStealth = RogueAPI:IsStealth(spId)
    elseif PriestAPI:IsPriestClass() then
        spellInfo.isShapeshift = PriestAPI:IsInShadowFormSpell(spId)
    end
end

--- @param macroIndex number
--- @return SpellID
function S:GetMacroSpellID(macroIndex) return macroIndex and GetMacroSpell(macroIndex) end

--- @param macroIndex number
--- @return SpellName, SpellID
function S:GetMacroSpell(macroIndex)
    local spellID = self:GetMacroSpellID(macroIndex)
    return spellID and Compat:GetSpellInfo(spellID), spellID
end

--- @param macroIndex number
--- @return Profile_Spell
function S:GetMacroSpellInfo(macroIndex)
    local spellId = self:GetMacroSpellID(macroIndex)
    return spellId and self:GetSpellInfo(spellId)
end

--- @return SpellCooldownDetails
function S:GetSpellCooldownDetails(spellID, optionalSpell)
    local spell = optionalSpell or self:GetSpellInfo(spellID)
    if spell == nil then error("Spell not found: " .. spellID) end
    local start, duration, enabled, modRate = Compat:GetSpellCooldown(spellID);
    local cooldown = { start = start, duration = duration, enabled = enabled, modRate = modRate }
    --- @class SpellCooldownDetails
    local details = { spell = spell, cooldown = cooldown }
    return details
end

--- See: [GetSpellCooldown](https://wowpedia.fandom.com/wiki/API_GetSpellCooldown)
--- @param spellNameOrID number|string Spell ID or Name. When passing a name requires the spell to be in your Spellbook.
--- @return SpellCooldown
function S:GetSpellCooldown(spellNameOrID)
    if not spellNameOrID then return nil end
    local spell = self:GetSpellInfo(spellNameOrID)
    if not spell then return nil end

    local start, duration, enabled, modRate = Compat:GetSpellCooldown(spellNameOrID);

    --- @type SpellCooldown
    local cd = {
        spell = { name = spell.name, id = spell.id, icon = spell.icon },
        start = start,
        duration = duration,
        enabled = enabled,
        modRate = modRate,
    }
    return cd
end
---Example:
--- @param optionalUnit string
--- @see GlobalConstants#UnitId
--- @see Blizzard_UnitId
--- @return string One of DRUID, ROGUE, PRIEST, etc...
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

--- @param spellInfo Profile_Spell
function S:IsShapeShiftActive(spellInfo)
    if not spellInfo then return false end
    return spellInfo and spellInfo.id and self:IsShapeShiftActiveBySpellID(spellInfo.id)
end

--- @param spellID SpellID
function S:IsShapeShiftActiveBySpellID(spellID)
    if self:IsPlayerClassAnyOf(GC.UnitClass.PRIEST, GC.UnitClass.ROGUE) then
        return GetShapeshiftForm() > 0
    elseif ShamanAPI:IsShamanClass() then
        return ShamanAPI:IsGhostWolfSpell(spellID) and ShamanAPI:IsInGhostWolfForm()
    end
    return spellID and DruidAPI:IsActiveForm(spellID)
end

--- Generalizes shapeshift and stealth and shapeshift form
--- @param spellInfo Profile_Spell|SpellInfo
function S:IsShapeshiftOrStealthSpell(spellInfo)
    return self:IsShapeshiftSpell(spellInfo)
            or self:IsStealthSpell(spellInfo.id)
end

--- Generalizes shapeshift and stealth and shapeshift form
--- @param spell Profile_Spell|SpellInfo
function S:IsShapeshiftSpell(spell)
    local spellId = spell and spell.id; if not spellId then return end
    if ShamanAPI:IsShamanClass() then
        return ShamanAPI:IsGhostWolfSpell(spellId)
    elseif PriestAPI:IsPriestClass() then
        return PriestAPI:IsInShadowFormSpell(spellId)
    end
    return DruidAPI:IsDruidForm(spellId)
end

--- @param spellNameOrID SpellNameOrID
function S:IsStealthSpell(spellNameOrID)
    local spellID = spellNameOrID
    if type(spellNameOrID) == 'string' then
        local _, id = self:GetSpellName(spellNameOrID); if not id then return false end
        spellID = id
    end
    return IsAnyOf(spellID, ROGUE_STEALTH_SPELL_ID, DRUID_PROWL_SPELL_ID, NIGHT_ELF_SHADOWMELD_SPELL_ID)
end

--- @param spell Profile_Spell
function S:GetSpellIcon(spell)
    if not spell then return nil end

    if self:IsShapeshiftSpell(spell) then
        local unitClass = self:GetUnitClass(UnitId.player)
        if self:IsShapeShiftActive(spell) then
            if unitClass == GC.UnitClass.DRUID then
                return GC.Textures.DRUID_FORM_ACTIVE_ICON
            elseif unitClass == GC.UnitClass.PRIEST then
                if ns:IsRetail() then return GC.Textures.PRIEST_SHADOWFORM_ACTIVE_ICON_RETAIL end
                return GC.Textures.PRIEST_SHADOWFORM_ACTIVE_ICON
            elseif unitClass == GC.UnitClass.SHAMAN then
                return GC.Textures.GHOST_WOLF_FORM_ACTIVE_ICON
            end
        end
    elseif self:IsStealthed(spell.id) then return GC.Textures.STEALTHED_ICON end
    return spell.icon
end

function S:IsStealthed(spellID) return self:IsStealthSpell(spellID) and IsStealthed() end

--- @param spellID SpellID
function S:GetStealthIcon(spellID)
    if self:IsStealthed(spellID) then return GC.Textures.STEALTHED_ICON end
    return nil
end

--- @param spellInfo Profile_Spell
function S:GetShapeshiftIcon(spellInfo)
    if self:IsShapeShiftActive(spellInfo) then return GC.Textures.DRUID_FORM_ACTIVE_ICON end
    return spellInfo.icon
end

--- This is for WOTLK and Retail
--- @param spellInfo Profile_Spell
function S:GetSpellAttributeValue(spellInfo) return spellInfo.name end

--  TODO: Rank matters in classic-era. We should use this
--- @param spellInfo Profile_Spell
function S:GetSpellAttributeValueClassicEra(spellInfo)
    local spell = spellInfo.name
    local spellRank = Compat:GetSpellSubtext(spellInfo.id)
    if String.IsNotBlank(spellRank) then
        spell = spell .. '(' .. spellRank .. ')'
    end
    --print('spell:', spell)
    return spell
end

--- @param itemID number
function S:IsToyItem(itemID)
    if not C_ToyBox then return false end
    local _itemID, toyName, icon, isFavorite, hasFanfare, quality = C_ToyBox.GetToyInfo(itemID)
    return not (_itemID == nil or toyName == nil)
end

--- @param macroName string
--- @return ItemInfo
function S:GetMacroItem(macroName)
    local name = GetMacroItem(macroName); if not name then return nil end
    return self:GetItemInfo(name)
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

--- @param spellName string
function S:IsItemSpell(spellName) return spellName and GetItemInfo(spellName) ~= nil end

--- See: [GetItemInfo](https://wowpedia.fandom.com/wiki/API_GetItemInfo)
--- See: [GetItemInfoInstant](https://wowpedia.fandom.com/wiki/API_GetItemInfoInstant)
--- @param item ItemID_Link_Or_Name
--- @return ItemInfo
function S:GetItemInfo(item)
    local itemID = self:ResolveItemID(item); if not itemID then return nil end

    local itemName, itemLink,
        itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
        itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
        expacID, setID, isCraftingReagent = GetItemInfo(itemID)

    --- count includes charges
    local count = GetItemCount(itemID, false, true, true) or 0

    --- @type ItemInfo
    local itemInfo = { id = itemID, name = itemName, link = itemLink, icon = itemTexture,
                       quality = itemQuality, level = itemLevel, minLevel = itemMinLevel,
                       type = itemType, subType = itemSubType, stackCount = itemStackCount,
                       count = count, equipLoc=itemEquipLoc, classID=classID,
                       subclassID=subclassID, bindType=bindType,
                       isCraftingReagent=isCraftingReagent }
    return itemInfo
end

--- @param itemIdNameOrLink ItemName|ItemLink|Profile_Item
--- @return string, number
function S:GetItemSpellInfo(itemIdNameOrLink)
    if type(itemIdNameOrLink) == 'table' then
        return self:GetItemSpellInfoFromItemData(itemIdNameOrLink)
    end
    local spellName, spellID = GetItemSpell(itemIdNameOrLink)
    return spellName, spellID
end

--- @param itemInfo Profile_Item
--- @return string, number
function S:GetItemSpellInfoFromItemData(itemInfo)
    local spellName, spellID = GetItemSpell(itemInfo.name)
    if not (spellName and spellID) then
        spellName, spellID = GetItemSpell(itemInfo.link)
    end
    return spellName, spellID
end

--- See: [GetItemCooldown](https://wowpedia.fandom.com/wiki/API_GetItemCooldown)
--- @param itemIDOrName number|string The itemID or itemName
--- @return ItemCooldown
function S:GetItemCooldown(itemIDOrName)
    local itemID = self:ResolveItemID(itemIDOrName); if not itemID then return nil end

    if C_Container then GetItemCooldown = C_Container.GetItemCooldown end
    local start, duration, enabled = GetItemCooldown(itemID)
    local item = self:GetItemInfo(itemID)
    if not item then return nil end

    --- @type ItemCooldown
    local cd = {
        item = { id = itemID, name = item.name, icon=item.icon },
        start=start, duration=duration, enabled=enabled,
        details = item
    }

    return cd
end

--- @param spellID SpellName
--- @return Mount
function S:GetMountBySpellID(spellID)
    local mountID = C_MountJournal.GetMountFromSpell(spellID)
    if not mountID then return nil end
    local mountName, spellID, Icon, isActive, isUsable, SourceType,
        isFavorite, isFactionSpecific, Faction, ShouldHideOnChar,
        isCollected, mountID, isForDragonriding = C_MountJournal.GetMountInfoByID(mountID)

    --- @type C_MountJournal_MountInfo
    local m = {
        mountID = mountID, name = mountName, spellID=spellID, isUsable=isUsable, isActive=isActive
    }
    return MountMixin:New(m)
end

--- ABP:SummonMount().Ground('gmount1', 'gmount2').Flying('fmount1', 'fmount2').WithOptions(..,..)
--- ABP:SummonMount(ground={}, flying={}, opts={})
--- @param flyingMountName string
--- @param groundMountName string
function S:SummonMountSimple(flyingMountName, groundMountName)
    if true == IsFlying() then return end
    local flyingMountSpell = self:GetSpellInfo(flyingMountName)
    if not flyingMountSpell then
        p:e(function() return "ERROR: Unknown flying mount: %s", flyingMountName end)
        return
    end
    local groundMountSpell = self:GetSpellInfo(groundMountName)
    if not groundMountSpell then
        p:e(function() return "ERROR: Unknown ground mount: %s", groundMountName end)
        return
    end

    local mountID, mountName
    local flyingMount = self:GetMountBySpellID(flyingMountSpell.id)
    if true == flyingMount.isActive then
        mountID = flyingMount.mountID
        mountName = flyingMount.name
    end
    if mountID then return C_MountJournal.SummonByID(mountID) end

    local groundMount = self:GetMountBySpellID(groundMountSpell.id)
    if true == groundMount.isActive then
        mountID = groundMount.mountID
        mountName = groundMount.name
    end

    if mountID then
        if flyingMount:IsFlyingMountMountUsable() then
            -- while mounted in a ground mount and is-flyable-area
            p:d(function() return 'Ground mount active is [%s], but the area is flyable. Mount resolved is [%s]',
                        mountName, flyingMount.name end)
            return C_MountJournal.SummonByID(flyingMount.mountID)
        end
        p:v(function() return 'Ground mount is active: %s', mountName end)
        return C_MountJournal.SummonByID(mountID)
    end

    if flyingMount:IsFlyingMountMountUsable() then
        mountID = C_MountJournal.SummonByID(flyingMount.mountID)
        mountName = flyingMount.name
    elseif groundMount:IsGroundMountMountUsable() then
        mountID = groundMount.mountID
        mountName = groundMount.name
    end
    if mountID then
        p:v(function() return 'Selected mount: %s', mountName end)
        C_MountJournal.SummonByID(mountID)
    end
end

function S:IsDragKeyDown()
    return O.API:IsLockActionBars() ~= true or IsModifiedClick("PICKUPACTION") == true
end

function S:IsLockActionBars() return Settings.GetValue(LOCK_ACTION_BARS) == true end
function S:IsUseKeyDownActionButton() return GetCVarBool(ACTION_BUTTON_USE_KEY_DOWN) == true end

function S:SyncUseKeyDownActionButtonSettings()
    -- make sure lockActionBars is in sync with ""
    local lockActionBars = self:IsLockActionBars()
    local useKeyDown = self:IsUseKeyDownActionButton()
    if useKeyDown ~= lockActionBars then
        local val = lockActionBars == true and 1 or 0
        SetCVar(ACTION_BUTTON_USE_KEY_DOWN, val)
        p:f3(function()
            return "Syncing %s=%s with lockActionBars settings.", ACTION_BUTTON_USE_KEY_DOWN, val end)
    end
end

function S:SupportsPetBattles() return C_PetBattles ~= nil end
function S:SupportsVehicles() return UnitInVehicle ~= nil end
function S:IsPlayerInVehicle() return UnitInVehicle('player') end
function S:IsPlayerOnTaxi() return UnitOnTaxi('player') end
function S:IsPlayerInPetBattle()
    if not self:SupportsPetBattles() then return false end
    return C_PetBattles.IsInBattle() == true
end

    --- #### Alias for #GetSpellCooldownDetails(spellID)
--- @return SpellCooldownDetails
function S:GSCD(spellID, optionalSpell) return S:GetSpellCooldownDetails(spellID, optionalSpell) end
--- #### Alias for #GetSpellCooldown(spellID)
--- @return SpellCooldown
function S:GSC(spellID) return S:GetSpellCooldown(spellID) end
--- #### Alias for #GetItemCooldown(itemId)
--- @return ItemCooldown
function S:GIC(itemID) return S:GetItemCooldown(itemID) end

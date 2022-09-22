--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetSpellSubtext, GetSpellInfo, GetSpellLink = GetSpellSubtext, GetSpellInfo, GetSpellLink
local GetCursorInfo, GetSpellCooldown = GetCursorInfo, GetSpellCooldown
local GetItemInfo, GetItemCooldown, GetItemCount = GetItemInfo, GetItemCooldown, GetItemCount

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core = __K_Core:LibPack_GlobalObjects()
local String, Mixin = O.String, O.Mixin
local IsBlank, IsNotBlank, strlower = String.IsBlank, String.IsNotBlank, string.lower
local BaseAPI, WAttr = O.BaseAPI, O.GlobalConstants.WidgetAttributes
local SPELL, ITEM, MACRO, MOUNT = WAttr.SPELL, WAttr.ITEM, WAttr.MACRO, WAttr.MOUNT

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class API : BaseAPI
local S = {}
---@type API
_API = S
--TODO: Next Deprecate Global Var _API
Core:Register(Core.M.API, S)

local p = O.LogFactory('API')

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

---@return CursorInfo
function S:GetCursorInfo()
    -- actionType string spell, item, macro, mount, etc..
    local actionType, info1, info2, info3 = GetCursorInfo()
    if IsBlank(actionType) then return nil end
    ---@class CursorInfo
    local c = { type = actionType or '', info1 = info1, info2 = info2, info3 = info3 }

    local info2Lc = strlower(c.info2 or '')
    if c.type == 'companion' and 'mount' == info2Lc then
        c.info2 = info2Lc
        c.originalCursor = { type = c.type, info1 = c.info1, info2 = info2 }
        c.type = c.info2
    end

    return c
end

---@param mountIDorIndex number
function S:_GetMountInfo(mountIDorIndex)

    if C_MountJournal then
        local mountID = mountIDorIndex
        local name, spellID, icon,
        isActive, isUsable, sourceType, isFavorite,
        isFactionSpecific, faction, shouldHideOnChar,
        isCollected, mountID_, isForDragonriding = C_MountJournal.GetMountInfoByID(mountID)

        return name, spellID, icon
    end

    local mountCompanionIndex = mountIDorIndex
    local creatureID, creatureName, creatureSpellID, icon, issummoned =
        GetCompanionInfo("mount", mountCompanionIndex)
    return creatureName, creatureSpellID, icon;
end

---## For WOTLK
--- CursorInfo for WOTLK
---```
---   info1 = <mountIndex> <-- info you need for GetCompanionInfo("mount", <info1>)
---   info2 = "MOUNT"
---   info3 = "companion"
---
--- GetCompanionInfo("mount", mountIndex), ex: GetCompanionInfo("mount", 1)
---    returns {   4271, 'Dire Wolf', 6653, 132266, false }
---```
---## For Retail, use C_MountJournal
---```
---  C_MountJournal.GetMountInfoByID(mountId)
---  C_MountJournal.GetDisplayedMountInfo(mountIndex)
--- actionType, info1, info2
--- "mount", mountId, C_MountJournal index
---```
---@return MountInfo
---@param cursorInfo CursorInfo
function S:GetMountInfo(cursorInfo)
    local mountIDorIndex = cursorInfo.info1
    local mountInfoAPI = BaseAPI:GetMountInfo(mountIDorIndex)
    p:log(10, "mountInfoAPI: %s", mountInfoAPI)

    ---@class MountInfoSpell
    local spell = {
        ---@type number
        id = mountInfoAPI.spellID,
        ---@type number
        icon = mountInfoAPI.icon }

    ---@class MountInfo
    local info = {
        ---@type string
        name = mountInfoAPI.name,
        ---@type number
        id = mountIDorIndex,
        ---@type number
        index = -1,
        ---@type MountInfoSpell
        spell = spell
    }
    if C_MountJournal then info.index = cursorInfo.info2 end
    return info
end

---Note: should call ButtonData:ContainsValidAction() before calling this
---@return boolean true, false or nil if not applicable
---@param btnConfig ProfileButton
---@param targetUnit string one of "target", "focus", "mouseover", etc.. See Blizz APIs
function S:IsActionInRange(btnConfig, targetUnit)
    if btnConfig.type == SPELL then
        local val = IsSpellInRange(btnConfig.spell.name, targetUnit)
        if val == nil then return nil end
        return val == true or val == 1
    end
    if btnConfig.type == ITEM then
        local val = IsSpellInRange(btnConfig.item.name, targetUnit)
        if val == nil then return nil end
        return  val == true or val == 1
    end
    if btnConfig.type == MACRO then
        return false
    end
end

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
---@return SpellInfo
function S:GetSpellInfo(spellNameOrId)
    local name, _, icon, castTime, minRange, maxRange, id = GetSpellInfo(spellNameOrId)
    if name then
        local subTextOrRank = GetSpellSubtext(spellNameOrId)
        local spellLink = GetSpellLink(spellNameOrId)
        ---@class SpellInfo
        local spellInfo = { id = id, name = name, icon = icon,
                            link=spellLink, castTime = castTime,
                            minRange = minRange, maxRange = maxRange, rank = subTextOrRank }
        spellInfo.label = spellInfo.name
        if IsNotBlank(spellInfo.rank) then
            -- color codes format: |cAARRGGBB
            local labelFormat = '%s |c00747474(%s)|r'
            spellInfo.label = format(labelFormat, spellInfo.name, spellInfo.rank)
        end
        return spellInfo;
    end
    return nil
end

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
---@return SpellCooldown
function S:GetSpellCooldown(spellID, optionalSpell)
    --print(string.format('optionalSpell: %s', pformat(optionalSpell)))
    local start, duration, enabled, modRate = GetSpellCooldown(spellID);
    local name, _, icon, _, _, _, _ = GetSpellInfo(spellID)
    ---@class SpellCooldown
    local cd = {
        spell = { name = name, id = spellID, icon = icon },
        start = start, duration = duration, enabled = enabled, modRate = modRate }
    if optionalSpell then
        cd.spell.details = optionalSpell
    end
    return cd
end

--- See: [GetItemInfo](https://wowpedia.fandom.com/wiki/API_GetItemInfo)
--- See: [GetItemInfoInstant](https://wowpedia.fandom.com/wiki/API_GetItemInfoInstant)
---@return ItemInfo
function S:GetItemInfo(itemID)
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
---@return ItemCooldown
function S:GetItemCooldown(itemId, optionalItem)
    if not itemId then return nil end;
    local start, duration, enabled = GetItemCooldown(itemId)
    ---@class ItemCooldown
    local cd = {
        item = { id = itemId },
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
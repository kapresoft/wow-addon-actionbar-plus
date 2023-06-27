--- The BaseAPI is intended to contain methods and properties
--- That are common across all versions of World of Warcraft API.
--- The methods that are found here are usually the ones that deal
--- with different API versions.
--- #############################################################
---

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local C_Timer = C_Timer
local GetCompanionInfo, GetSpellInfo = GetCompanionInfo, GetSpellInfo
local C_MountJournal, C_PetBattles, C_PetJournal = C_MountJournal, C_PetBattles, C_PetJournal
local C_EquipmentSet = C_EquipmentSet
local UnitIsFriend, UnitIsEnemy, UnitInVehicle = UnitIsFriend, UnitIsEnemy, UnitInVehicle
local IsUsableSpell = IsUsableSpell

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, LibStub = ns.O, ns.O.GlobalConstants, ns.O.LibStub

local UnitId = GC.UnitId
local W = GC.WidgetAttributes

local String, Assert = O.String, O.Assert
local IsBlank, IsNotBlank, IsNil, IsNotNil = String.IsBlank, String.IsNotBlank, Assert.IsNil, Assert.IsNotNil
local sformat = String.format

--- @class BaseAPI : BaseLibraryObject
local L = LibStub:NewLibrary(ns.M.BaseAPI)
local p = L:GetLogger()

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param mountInfo MountInfo
local function IsValidMountInfo(mountInfo)
    return IsNotBlank(mountInfo.name) and IsNotNil(mountInfo.spellID) and IsNotNil(mountInfo.icon)
end

function L:IsDragonflight() return select(4, GetBuildInfo()) >= 100000 end
function L:IsClassicEra() return select(4, GetBuildInfo()) <= 11500 end

--- @see Blizzard_UnitId
function L:IsTargetFriendlyToPlayer() return UnitIsFriend(UnitId.player, UnitId.target) end
function L:IsTargetEnemyToPlayer() return UnitIsEnemy(UnitId.player, UnitId.target) end

--- @param cursorInfo CursorInfo
--- @return CompanionCursor
function L:ToCompanionCursor(cursorInfo)
    return {
        ['type'] = cursorInfo.type or W.COMPANION,
        ['index'] = cursorInfo.info1 or -1,
        ['petType'] = cursorInfo.info2 or '',
    }
end

function L:PlayerInPetBattle()
    local inPetBattle = false
    if C_PetBattles then inPetBattle = C_PetBattles.IsInBattle() end
    return inPetBattle
end

--- @param cursorInfo CursorInfo
--- @return BattlePetCursor
function L:ToBattlePetCursor(cursorInfo)
    return {
        ['type'] = cursorInfo.type or W.BATTLE_PET,
        ['guid'] = cursorInfo.info1 or '',
    }
end

--- @param cursorInfo CursorInfo
--- @return EquipmentSetCursor
function L:ToEquipmentSetCursor(cursorInfo)
    return {
        ['type'] = cursorInfo.type or W.EQUIPMENT_SET,
        ['name'] = cursorInfo.info1 or '',
    }
end

--- @return EquipmentSetInfo
function L:GetEquipmentSetInfo(cursorInfo)
    local equipmentSetCursor = self:ToEquipmentSetCursor(cursorInfo)
    if not (equipmentSetCursor and equipmentSetCursor.name) then return nil end
    return self:GetEquipmentSetInfoByName(equipmentSetCursor.name)
end

--- @param id number The equipment setID
--- @return number The index or nil
function L:GetEquipmentSetIndex(id)
    local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs()
    if not equipmentSetIDs then return nil end
    for i, v in ipairs(equipmentSetIDs) do if v == id then return i end end
    return nil
end

--- @return EquipmentSetInfo
--- @param equipmentName string
function L:GetEquipmentSetInfoByName(equipmentName)
    local setID = C_EquipmentSet.GetEquipmentSetID(equipmentName)
    if not setID then return nil end
    return self:GetEquipmentSetInfoBySetID(setID)
end

--- @return EquipmentSetInfo
--- @param id number The setID
function L:GetEquipmentSetInfoBySetID(id)
    local name, iconFileID, setID_, isEquipped, numItems, numEquipped,
    numInInventory, numLost, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(id)

    return {
        name = name,
        id = id,
        index = self:GetEquipmentSetIndex(id),
        setID = id,
        icon = iconFileID,
        isEquipped = isEquipped,
        numItems = numItems,
        numEquipped = numEquipped,
        numInInventory = numInInventory,
        numLost = numLost,
        numIgnored = numIgnored
    }
end

---### See Interface_<wow-version>/FrameXML/Constants.lua#PET_TYPE_SUFFIX
---### See Also: GetNumCompanions('type')
--- @param petType string See PET_TYPE_SUFFIX
--- @param id number
--- @return CompanionInfo
function L:GetCompanionInfo(petType, index)
    local creatureID, creatureName, creatureSpellID, icon, isSummoned, mountType
    local status, err = pcall(function()
        assert(petType, "Companion type is required")
        assert(index, "Companion index is required")
        creatureID, creatureName, creatureSpellID, icon, isSummoned, mountType = GetCompanionInfo(petType, index)
    end)
    if not status then return p:log('Error calling GetCompanionInfo(): %s', err) end

    return {
        ['petType'] = petType,
        ['index'] = index,
        ['creatureID'] = creatureID,
        ['creatureName'] = creatureName,
        ['creatureSpellID'] = creatureSpellID,
        ['icon'] = icon,
        ['isSummoned'] = isSummoned,
        ['mountType'] = mountType
    }
end

--- @param spell Profile_Spell
function L:PickupSpell(spell)
    if not (spell and spell.id) then return end
    PickupSpell(spell.id)
end
--- @param macro Profile_Macro
function L:PickupMacro(macro)
    if not (macro or macro.index) then return end
    PickupMacro(macro.index)
end

--- @param item Profile_Item
function L:PickupItem(item)
    if not (item or item.id) then return end
    PickupItem(item.id)
end

--- @param mount Profile_Mount
function L:PickupMount(mount)
    if C_MountJournal and IsNotBlank(mount.name) then
        C_MountJournal.SetSearch(sformat('"%s"', mount.name))
        C_MountJournal.Pickup(1)
        C_Timer.After(0.5, function() C_MountJournal.SetSearch('')  end)
        return
    end

    PickupCompanion(W.MOUNT, mount.index)
end

--- @param guid string Pet GUID
function L:PickupBattlePet(guid)
    if IsBlank(guid) then return end
    C_PetJournal.PickupPet(guid)
end

--- @param equipmentSet Profile_EquipmentSet
--- @see Profile_EquipmentSet
function L:PickupEquipmentSet(equipmentSet)
    if not (equipmentSet and equipmentSet.id) then return end
    C_EquipmentSet.PickupEquipmentSet(equipmentSet.id);
end

--- @param companion Profile_Companion
function L:PickupCompanion(companion)
    if not companion then return end
    if C_PetJournal then
        return C_PetJournal.PickupPet(companion.id)
    end
    PickupCompanion(companion.petType, companion.index)
end

--- @param petGUID string Example: BattlePet-0-000008C13591
--- @return boolean
function L:CanSummonBattlePet(petGUID)
    if not (C_PetJournal and petGUID) then return false end
    return C_PetJournal.PetIsSummonable(petGUID)
end

---### Doc: [https://wowpedia.fandom.com/wiki/API_GetCursorInfo](https://wowpedia.fandom.com/wiki/API_GetCursorInfo)
---### Doc: [https://wowpedia.fandom.com/wiki/API_C_PetJournal.GetPetInfoByPetID](https://wowpedia.fandom.com/wiki/API_C_PetJournal.GetPetInfoByPetID)
--- ```
--- local type, info1 = GetCursorInfo()
---```
--- @param petGUID string Example: BattlePet-0-000008C13591
--- @return BattlePetInfo
function L:GetBattlePetInfo(petGUID)
    if IsBlank(petGUID) then return nil end

    local speciesID, customName, level, xp, maxXp, displayID,
    isFavorite, name, icon, petType, creatureID, sourceText,
    description, isWild, canBattle, tradable, unique, obtainable =
            C_PetJournal.GetPetInfoByPetID(petGUID)
    local isSummonable = C_PetJournal.PetIsSummonable(petGUID)
    return {
        ['guid'] = petGUID,
        ['canSummon'] = isSummonable,
        ['speciesID'] = speciesID,
        ['customName'] = customName,
        ['level'] = level,
        ['xp'] = xp,
        ['maxXp'] = maxXp,
        ['displayID'] = displayID,
        ['isFavorite'] = isFavorite,
        ['name'] = name,
        ['icon'] = icon,
        ['petType'] = petType,
        ['creatureID'] = creatureID,
        ['sourceText'] = sourceText,
        ['description'] = description,
        ['isWild'] = isWild,
        ['canBattle'] = canBattle,
        ['tradable'] = tradable,
        ['unique'] = unique,
        ['obtainable'] = obtainable
    }
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
--- @param cursorInfo CursorInfo
--- @return MountInfo
function L:GetMountInfo(cursorInfo)
    local mountIDorIndex = cursorInfo.info1
    local mountInfo = self:GetMountInfoGenericFromCursor(mountIDorIndex)
    if not mountInfo then return nil end
    if C_MountJournal then mountInfo.index = cursorInfo.info2 end
    return mountInfo
end

--- @return MountInfo
--- @param mountIDorIndex number
function L:GetMountInfoGenericFromCursor(mountIDorIndex)
    local m = self:GetMountInfo_CJournal(mountIDorIndex)
    if m then return m end
    return self:GetMountInfoLegacy(mountIDorIndex)
end

--- @return MountInfo
--- @param mountData Profile_Mount
function L:GetMountInfoGeneric(mountData)
    local m
    if C_MountJournal then m = self:GetMountInfo_CJournal(mountData.id) end
    if m then return m end
    return self:GetMountInfoLegacy(mountData.index)
end

--- @return MountInfo
--- @param companionIndex number
function L:GetMountInfoLegacy(companionIndex)
    local creatureID, creatureName, creatureSpellID, icon, isSummoned =
            GetCompanionInfo(W.MOUNT, companionIndex)

    local spellName = creatureName
    if not IsUsableSpell(spellName) then
        local spellInfoName = GetSpellInfo(creatureSpellID)
        if spellInfoName then spellName = spellInfoName end
        p:log(30, 'Mount creature-name=[%s] spell=[%s]', creatureName, spellName)
    end

    local isActive = false
    if AuraUtil and AuraUtil.FindAuraByName then
        local aura = AuraUtil.FindAuraByName(spellName, UnitId.player)
        isActive = spellName == aura
    end

    local o = {
        isActive = isActive,
        --- @type number
        index = companionIndex,
        --- @type string
        name = spellName,
        --- @type number
        spellID = creatureSpellID,
        --- @type number
        icon = icon
    }

    return IsValidMountInfo(o) and o or nil
end

---The Mount Journal was added in Patch 6.0.2
--- @return MountInfo
--- @param mountID number
function L:GetMountInfo_CJournal(mountID)
    if not C_MountJournal then return nil end

    local name, spellID, icon,
    isActive, isUsable, sourceType, isFavorite,
    isFactionSpecific, faction, shouldHideOnChar,
    isCollected, mountID_, isForDragonriding = C_MountJournal.GetMountInfoByID(mountID)

    local o = {
        isActive = isActive,
        --- @type number
        index = -1,
        --- @type number
        id = -1,
        --- @type number
        id = mountID,
        --- @type string
        name = name,
        --- @type number
        spellID = spellID,
        --- @type number
        icon = icon
    }

    return IsValidMountInfo(o) and o or nil
end

function L:SupportsPetBattles() return C_PetBattles ~= nil end
function L:SupportsVehicles() return UnitInVehicle ~= nil end

--- @return _SpellCastEventArguments
function L:ParseSpellCastEventArgs(...)
    local unitTarget, castGUID, spellID = ...
    return {
        ['unitTarget'] = unitTarget,
        ['castGUID'] = castGUID,
        ['spellID'] = spellID
    }
end

--- @return _SpellCastSentEventArguments
function L:ParseSpellCastSentEventArgs(...)
    local unit, target, castGUID, spellID = ...
    return {
        ['unit'] = unit,
        ['target'] = target,
        ['castGUID'] = castGUID,
        ['spellID'] = spellID
    }
end

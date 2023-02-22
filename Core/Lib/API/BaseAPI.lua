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
local PickupCompanion, GetCompanionInfo, GetSpellInfo = PickupCompanion, GetCompanionInfo, GetSpellInfo
local C_MountJournal, C_PetBattles, C_PetJournal = C_MountJournal, C_PetBattles, C_PetJournal
local UnitIsFriend, UnitIsEnemy, UnitInVehicle = UnitIsFriend, UnitIsEnemy, UnitInVehicle
local IsUsableSpell = IsUsableSpell

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, LibStub = ns.O, ns.O.GlobalConstants, ns.O.LibStub

local UnitId = GC.UnitId
local String, Assert = O.String, O.Assert
local IsBlank, IsNotBlank, IsNil, IsNotNil = String.IsBlank, String.IsNotBlank, Assert.IsNil, Assert.IsNotNil
local WAttr = O.GlobalConstants.WidgetAttributes
local MOUNT, COMPANION = WAttr.MOUNT, WAttr.COMPANION
local sformat = String.format

---@class BaseAPI : BaseLibraryObject
local L = LibStub:NewLibrary(ns.M.BaseAPI)
local p = L:GetLogger()

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param mountInfo MountInfo
local function IsValidMountInfo(mountInfo)
    return IsNotBlank(mountInfo.name) and IsNotNil(mountInfo.spellID) and IsNotNil(mountInfo.icon)
end

function L:IsDragonflight() return select(4, GetBuildInfo()) >= 100000 end
function L:IsClassicEra() return select(4, GetBuildInfo()) <= 11500 end

---@see Blizzard_UnitId
function L:IsTargetFriendlyToPlayer() return UnitIsFriend(UnitId.player, UnitId.target) end
function L:IsTargetEnemyToPlayer() return UnitIsEnemy(UnitId.player, UnitId.target) end

---@param cursorInfo CursorInfo
---@return CompanionCursor
function L:ToCompanionCursor(cursorInfo)
    return {
        ['type'] = cursorInfo.type or 'companion',
        ['index'] = cursorInfo.info1 or -1,
        ['petType'] = cursorInfo.info2 or '',
    }
end

---@param cursorInfo CursorInfo
---@return BattlePetCursor
function L:ToBattlePetCursor(cursorInfo)
    return {
        ['type'] = cursorInfo.type or 'battlepet',
        ['guid'] = cursorInfo.info1 or '',
    }
end

---### See Interface_<wow-version>/FrameXML/Constants.lua#PET_TYPE_SUFFIX
---### See Also: GetNumCompanions('type')
---@param petType string See PET_TYPE_SUFFIX
---@param id number
---@return CompanionInfo
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

---@param mount Profile_Mount
function L:PickupMount(mount)
    if C_MountJournal and IsNotBlank(mount.name) then
        C_MountJournal.SetSearch(sformat('"%s"', mount.name))
        C_MountJournal.Pickup(1)
        C_Timer.After(0.5, function() C_MountJournal.SetSearch('')  end)
        return
    end

    PickupCompanion(MOUNT, mount.index)
end

---@param guid string Pet GUID
function L:PickupBattlePet(guid)
    if IsBlank(guid) then return end
    C_PetJournal.PickupPet(guid)
end

---@param companion Profile_Companion
function L:PickupCompanion(companion)
    if not companion then return end
    if C_PetJournal then
        return C_PetJournal.PickupPet(companion.id)
    end
    PickupCompanion(companion.petType, companion.index)
end

---@param petGUID string Example: BattlePet-0-000008C13591
---@return boolean
function L:CanSummonBattlePet(petGUID)
    if not (C_PetJournal and petGUID) then return false end
    return C_PetJournal.PetIsSummonable(petGUID)
end

---### Doc: [https://wowpedia.fandom.com/wiki/API_GetCursorInfo](https://wowpedia.fandom.com/wiki/API_GetCursorInfo)
---### Doc: [https://wowpedia.fandom.com/wiki/API_C_PetJournal.GetPetInfoByPetID](https://wowpedia.fandom.com/wiki/API_C_PetJournal.GetPetInfoByPetID)
--- ```
--- local type, info1 = GetCursorInfo()
---```
---@param petGUID string Example: BattlePet-0-000008C13591
---@return BattlePetInfo
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
---@param cursorInfo CursorInfo
---@return MountInfo
function L:GetMountInfo(cursorInfo)
    local mountIDorIndex = cursorInfo.info1
    local mountInfoAPI = self:GetMountInfoGeneric(mountIDorIndex)
    if C_MountJournal then mountInfoAPI.index = cursorInfo.info2 end
    return mountInfoAPI
end

---@return MountInfo
---@param mountIDorIndex number
function L:GetMountInfoGeneric(mountIDorIndex)
    local m = self:GetMountInfo_CJournal(mountIDorIndex)
    if m then return m end
    return self:GetMountInfoLegacy(mountIDorIndex)
end

--- @return MountInfo
---@param companionIndex number
function L:GetMountInfoLegacy(companionIndex)
    local creatureID, creatureName, creatureSpellID, icon, isSummoned =
            GetCompanionInfo(MOUNT, companionIndex)
    local spellName = creatureName
    if not IsUsableSpell(spellName) then
        local spellInfoName = GetSpellInfo(creatureSpellID)
        if spellInfoName then spellName = spellInfoName end
        p:log(30, 'Mount creature-name=[%s] spell=[%s]', creatureName, spellName)
    end

    local o = {
        ---@type number
        index = companionIndex,
        ---@type string
        name = spellName,
        ---@type number
        spellID = creatureSpellID,
        ---@type number
        icon = icon
    }

    return IsValidMountInfo(o) and o or nil
end

---The Mount Journal was added in Patch 6.0.2
--- @return MountInfo
---@param mountID number
function L:GetMountInfo_CJournal(mountID)
    if not C_MountJournal then return nil end

    local name, spellID, icon,
    isActive, isUsable, sourceType, isFavorite,
    isFactionSpecific, faction, shouldHideOnChar,
    isCollected, mountID_, isForDragonriding = C_MountJournal.GetMountInfoByID(mountID)

    local o = {
        ---@type number
        index = -1,
        ---@type number
        id = -1,
        ---@type number
        id = mountID,
        ---@type string
        name = name,
        ---@type number
        spellID = spellID,
        ---@type number
        icon = icon
    }

    return IsValidMountInfo(o) and o or nil
end

function L:SupportsPetBattles() return C_PetBattles ~= nil end
function L:SupportsVehicles() return UnitInVehicle ~= nil end

---@return _SpellCastEventArguments
function L:ParseSpellCastEventArgs(...)
    local unitTarget, castGUID, spellID = ...
    return {
        ['unitTarget'] = unitTarget,
        ['castGUID'] = castGUID,
        ['spellID'] = spellID
    }
end

---@return _SpellCastSentEventArguments
function L:ParseSpellCastSentEventArgs(...)
    local unit, target, castGUID, spellID = ...
    return {
        ['unit'] = unit,
        ['target'] = target,
        ['castGUID'] = castGUID,
        ['spellID'] = spellID
    }
end

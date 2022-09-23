--- The BaseAPI is intended to contain methods and properties
--- That are common across all versions of World of Warcraft API.
--- The methods that are found here are usually the ones that deal
--- with different API versions.
--- #############################################################
---

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local C_MountJournal, C_Timer, PickupCompanion, GetCompanionInfo = C_MountJournal, C_Timer, PickupCompanion, GetCompanionInfo

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local String, Assert = O.String, O.Assert
local IsBlank, IsNotBlank, IsNil, IsNotNil = String.IsBlank, String.IsNotBlank, Assert.IsNil, Assert.IsNotNil
local MOUNT = O.GlobalConstants.WidgetAttributes.MOUNT
local sformat = String.format

---@class BaseAPI
local L = LibStub:NewLibrary(Core.M.BaseAPI)
---@type LoggerTemplate
local p = L:GetLogger()

---@class MountInfo_API
local MountInfo_API = {
    ---@type string
    name = '',
    ---@type number
    spellID = -1,
    ---@type number
    icon = -1,
}
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param mountInfo MountInfo_API
local function IsValidMountInfo(mountInfo)
    return IsNotBlank(mountInfo.name) and IsNotNil(mountInfo.spellID) and IsNotNil(mountInfo.icon)
end

---@param mountName string
---@param mountID number
function L:PickupMount(mountName, mountID)
    if C_MountJournal and IsNotBlank(mountName) then
        C_MountJournal.SetSearch(sformat('"%s"', mountName))
        C_MountJournal.Pickup(1)
        C_Timer.After(0.5, function() C_MountJournal.SetSearch('')  end)
        return
    end

    PickupCompanion(MOUNT, mountID)
end

---@param mountIDorIndex number
function L:GetMountInfo(mountIDorIndex)
    local m = self:GetMountInfo_CJournal(mountIDorIndex)
    if m then return m end
    return self:GetMountInfoLegacy(mountIDorIndex)
end

--- @return MountInfo_API
---@param companionIndex number
function L:GetMountInfoLegacy(companionIndex)
    local creatureID, creatureName, creatureSpellID, icon, isSummoned =
            GetCompanionInfo(MOUNT, companionIndex)

    local o = {
        ---@type string
        name = creatureName,
        ---@type number
        spellID = creatureSpellID,
        ---@type number
        icon = icon
    }

    return IsValidMountInfo(o) and o or nil
end

---The Mount Journal was added in Patch 6.0.2
--- @return MountInfo_API
---@param mountID number
function L:GetMountInfo_CJournal(mountID)
    if not C_MountJournal then return nil end

    local name, spellID, icon,
    isActive, isUsable, sourceType, isFavorite,
    isFactionSpecific, faction, shouldHideOnChar,
    isCollected, mountID_, isForDragonriding = C_MountJournal.GetMountInfoByID(mountID)

    local o = {
        ---@type string
        name = name,
        ---@type number
        spellID = spellID,
        ---@type number
        icon = icon
    }

    return IsValidMountInfo(o) and o or nil
end
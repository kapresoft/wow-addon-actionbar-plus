--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub
local MSG, AceEvent = GC.M, O.AceLibrary.AceEvent

--[[-----------------------------------------------------------------------------
New Library: APIHooks
-------------------------------------------------------------------------------]]
--- @class APIHooks
local L = LibStub:NewLibrary(ns.M.APIHooks); if not L then return end
AceEvent:Embed(L)
local p = L:GetLogger()

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param abp ActionbarPlus
--- @param displayedMountIndex Index This is the index as shown in mount collection tab UI
--- @see APIHooks
local function OnPickupMount_Hook(abp, displayedMountIndex)
    abp.mountID = displayedMountIndex and O.BaseAPI:GetMountIDFromDisplayIndex(displayedMountIndex)
end

--- @param abp ActionbarPlus
--- @param petGUID Identifier This is the pet GUID, i.e. 'BattlePet-0-0000001837A7'
--- @see C_PetJournal.GetPetInfoByPetID(petID_GUID)
--- @see C_PetJournal.SummonPetByGUID(petID_GUID)
local function OnPickupPet_Hook(abp, petGUID) abp.companionID = petGUID end

--[[-----------------------------------------------------------------------------
Message Handler
-------------------------------------------------------------------------------]]
--- @param abp ActionbarPlus
--- @see C_MountJournal.Pickup()
--- @see C_PetJournal.PickupPet()
L:RegisterMessage(MSG.OnAddOnEnabled, function(msg, abp)
    p:log(10, 'MSG::R: %s', msg)
    if C_MountJournal then
        hooksecurefunc(C_MountJournal, 'Pickup', function(index) OnPickupMount_Hook(abp, index) end)
    end
    if C_PetJournal then
        hooksecurefunc(C_PetJournal, 'PickupPet', function(petGUID, arg) OnPickupPet_Hook(abp, petGUID) end)
    end
end)

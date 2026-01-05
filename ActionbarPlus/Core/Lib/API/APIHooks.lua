--- @type Namespace
local ns = select(2, ...)
local O, M, MSG, LibStub = ns.O, ns.M, ns.GC.M, ns.LibStub

--[[-----------------------------------------------------------------------------
New Library: APIHooks
-------------------------------------------------------------------------------]]
--- @class APIHooks
local L = LibStub:NewLibrary(M.APIHooks); if not L then return end; ns:AceEvent(L)
local p = ns:CreateDefaultLogger(M.APIHooks)

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
L:RegisterMessage(MSG.OnAddOnEnabled, function(msg, source, abp)
    local pm = ns:LC().MESSAGE:NewLogger(M.APIHooks)
    pm:d( function() return 'MSG::R: %s', msg end)

    if C_MountJournal then
        hooksecurefunc(C_MountJournal, 'Pickup', function(index) OnPickupMount_Hook(abp, index) end)
    end
    if C_PetJournal then
        hooksecurefunc(C_PetJournal, 'PickupPet', function(petGUID, arg) OnPickupPet_Hook(abp, petGUID) end)
    end
end)

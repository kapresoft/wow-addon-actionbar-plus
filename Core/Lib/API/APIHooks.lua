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

--[[-----------------------------------------------------------------------------
Message Handler
-------------------------------------------------------------------------------]]
--- @param abp ActionbarPlus
L:RegisterMessage(MSG.OnAddOnInitialized, function(msg, abp)
    p:log(10, 'MSG::R: %s', msg)
    if not C_MountJournal then return end
    hooksecurefunc(C_MountJournal, 'Pickup', function(index)
        OnPickupMount_Hook(abp, index) end)
end)

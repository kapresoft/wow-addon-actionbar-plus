--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local PickupSpell, PickupMacro, PickupItem, PickupCompanion = PickupSpell, PickupMacro, PickupItem, PickupCompanion
local GetCursorInfo = GetCursorInfo
--[[-----------------------------------------------------------------------------
Local vars
-------------------------------------------------------------------------------]]
local ns = abp_ns(...)
local O, GC, M, LibStub, LC = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub, ns.LogCategories()
local BaseAPI = O.BaseAPI
local IsNotBlank = O.String.IsNotBlank


--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class PickupHandler
local L = LibStub:NewLibrary(M.PickupHandler); if not L then return end
local p = LC.DRAG_AND_DROP:NewLogger(M.PickupHandler)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function L:IsPickingUpSomething()
    local type = GetCursorInfo()
    return IsNotBlank(type)
end

--- ### See: (https://www.wowinterface.com/forums/showthread.php?t=49120)[https://www.wowinterface.com/forums/showthread.php?t=49120]
--- ### See: Interface/FrameXML/SecureHandlers.lua # PickupAny
--- @param widget ButtonUIWidget
local function PickupStuff(widget)
    if widget:IsSpell() then
        BaseAPI:PickupSpell(widget:GetSpellData())
    elseif widget:IsMacro() then
        BaseAPI:PickupMacro(widget:GetMacroData())
    elseif widget:IsItem() then
        BaseAPI:PickupItem(widget:GetItemData())
    elseif widget:IsMount() then
        BaseAPI:PickupMount(widget:GetMountData())
    elseif widget:IsCompanion() then
        BaseAPI:PickupCompanion(widget:GetCompanionData())
    elseif widget:IsBattlePet() then
        BaseAPI:PickupBattlePet(widget:GetBattlePetData().guid)
    elseif widget:IsEquipmentSet() then
        BaseAPI:PickupEquipmentSet(widget:GetEquipmentSetData())
    else
        p:f1("PickupStuff(): No item was picked up")
    end
end

---## Pickup APIs
--- - see [API_PickupCompanion](https://wowpedia.fandom.com/wiki/API_PickupCompanion) for Mounts and Companion
--- @param widget ButtonUIWidget
function L:PickupExisting(widget)
    local conf = widget:conf()
    ABP.mountID = conf.mount and conf.mount.id
    PickupStuff(widget)
end

--- @param widget ButtonUIWidget
function L:Pickup(widget)
    PickupStuff(widget)
end


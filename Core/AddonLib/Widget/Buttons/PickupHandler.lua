--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local PickupSpell, PickupMacro, PickupItem, PickupCompanion = PickupSpell, PickupMacro, PickupItem, PickupCompanion
local GetCursorInfo = GetCursorInfo
--[[-----------------------------------------------------------------------------
Local vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local BaseAPI, LogFactory, Table = O.BaseAPI, O.LogFactory, O.Table
local IsNotBlank, IsTableEmpty = O.String.IsNotBlank, Table.isEmpty
local WAttr = O.GlobalConstants.WidgetAttributes
local SPELL, ITEM, MACRO, MOUNT = WAttr.SPELL, WAttr.ITEM, WAttr.MACRO, WAttr.MOUNT

local p = LogFactory(Core.M.PickupHandler)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class PickupHandler
local _L = LibStub:NewLibrary(Core.M.PickupHandler)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function _L:IsPickingUpSomething()
    local type = GetCursorInfo()
    return IsNotBlank(type)
end

---@param widget ButtonUIWidget
local function PickupStuff(widget)
    local btnConf = widget:GetConfig()

    if widget:IsSpell() then
        PickupSpell(btnConf[SPELL].id)
    elseif widget:IsMacro() then
        PickupMacro(btnConf[MACRO].index)
    elseif widget:IsItem() then
        PickupItem(btnConf[ITEM].id)
    elseif widget:IsMount() then
        local mountData = widget:GetButtonData():GetMountInfo()
        BaseAPI:PickupMount(mountData.name, mountData.id)
    else
        p:log(20, "PickupExisting | no item picked up")
    end
end

---## Pickup APIs
--- - see [API_PickupCompanion](https://wowpedia.fandom.com/wiki/API_PickupCompanion) for Mounts and Companion
---@param widget ButtonUIWidget
function _L:PickupExisting(widget)
    PickupStuff(widget)
end

---@param widget ButtonUIWidget
function _L:Pickup(widget)
    PickupStuff(widget)
end


--[[-----------------------------------------------------------------------------
Wow Vars
-------------------------------------------------------------------------------]]
local PickupSpell, PickupMacro, PickupItem = PickupSpell, PickupMacro, PickupItem
local GetCursorInfo = GetCursorInfo
--[[-----------------------------------------------------------------------------
Local vars
-------------------------------------------------------------------------------]]
local Core = __K_Core
local LibStub, M, G = ABP_LibGlobals:LibPack()
local _, _, String = G:LibPackUtils()
local IsNotBlank = String.IsNotBlank

---@type LogFactory
local LogFactory = LibStub(M.LogFactory)

local p = LogFactory('PickupHandler')
---@type Table
local Table = LibStub(M.Table)
---@type WidgetAttributes
local WAttr = ABP_CommonConstants.WidgetAttributes
local SPELL = WAttr.SPELL
local MACRO = WAttr.MACRO
local ITEM = WAttr.ITEM

---@class PickupHandler
local _L = {}
Core:Register(M.PickupHandler, _L)

---@type PickupHandler
ABP_PickupHandler = _L

function _L:IsPickingUpSomething()
    local type = GetCursorInfo()
    return IsNotBlank(type)
end

---@param btnData ButtonData
function _L:PickupExisting(btnData)
    if not Table.isEmpty(btnData[SPELL]) then
        PickupSpell(btnData[SPELL].id)
    elseif not Table.isEmpty(btnData[MACRO]) then
        PickupMacro(btnData[MACRO].index)
    elseif not Table.isEmpty(btnData[ITEM]) then
        PickupItem(btnData[ITEM].id)
    else
        p:log(20, "PickupExisting | no item picked up")
    end
end

function _L:Pickup(btnData)
    if btnData.type == SPELL then
        local spellInfo = btnData[SPELL]
        PickupSpell(spellInfo.id)
    elseif btnData.type == MACRO then
        local macroInfo = btnData[MACRO]
        PickupMacro(macroInfo.index)
    elseif btnData.type == ITEM then
        local itemInfo = btnData[ITEM]
        PickupItem(itemInfo.id)
    end
end


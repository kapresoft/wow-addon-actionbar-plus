--[[-----------------------------------------------------------------------------
Wow Vars
-------------------------------------------------------------------------------]]
local PickupSpell, PickupMacro, PickupItem = PickupSpell, PickupMacro, PickupItem

--[[-----------------------------------------------------------------------------
Local vars
-------------------------------------------------------------------------------]]
local LibStub, M = ABP_LibGlobals:LibPack()
---@type LogFactory
local LogFactory = LibStub(M.LogFactory)
local l = LogFactory('PickupHandler')
---@type Table
local Table = LibStub(M.Table)
---@type WidgetAttributes
local WAttr = ABP_CommonConstants.WidgetAttributes
local SPELL = WAttr.SPELL
local MACRO = WAttr.MACRO
local ITEM = WAttr.ITEM

---@class PickupHandler
local _L = {}
---@type PickupHandler
ABP_PickupHandler = _L

---@param btnData ButtonData
function _L:PickupExisting(btnData)
    if not Table.isEmpty(btnData[SPELL]) then
        PickupSpell(btnData[SPELL].id)
    elseif not Table.isEmpty(btnData[MACRO]) then
        PickupMacro(btnData[MACRO].index)
    elseif not Table.isEmpty(btnData[ITEM]) then
        PickupItem(btnData[ITEM].id)
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


--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local PickupSpell, PickupMacro, PickupItem = PickupSpell, PickupMacro, PickupItem
local GetCursorInfo = GetCursorInfo
--[[-----------------------------------------------------------------------------
Local vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local G, LogFactory, Table = O.LibGlobals, O.LogFactory, O.Table
local IsNotBlank = O.String.IsNotBlank
local SPELL, ITEM, MACRO = G:SpellItemMacroAttributes()

local p = LogFactory(Core.M.PickupHandler)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class PickupHandler
local _L = LibStub:NewLibrary(Core.M.PickupHandler)

--TODO: NEXT: Deprecate
---@type PickupHandler
ABP_PickupHandler = _L

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
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


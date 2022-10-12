--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace(...)
local LibStub, Core, O = ns.O.LibStub, ns.Core, ns.O

local SpellAttributeSetter, WAttr, PH = O.SpellAttributeSetter, O.GlobalConstants.WidgetAttributes, O.PickupHandler
local API, Assert = O.API, O.Assert
local IsNil = Assert.IsNil

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class SpellDragEventHandler : DragEventHandler
local L = LibStub:NewLibrary(Core.M.SpellDragEventHandler)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---spellCursorInfo `{ type = actionType, name='TODO', bookIndex = info1, bookType = info2, id = info3 }`
---@param cursorInfo table Data structure`{ type = actionType, info1 = info1, info2 = info2, info3 = info3 }`
function L:Handle(btnUI, cursorInfo)
    if not self:IsValid(btnUI, cursorInfo) then return end
    local spellCursorInfo = { type = cursorInfo.type,
                              id = cursorInfo.info3,
                              bookIndex = cursorInfo.info1,
                              bookType = cursorInfo.info2 }

    local spellInfo = API:GetSpellInfo(spellCursorInfo.id)
    if IsNil(spellInfo) then return end

    local btnData = btnUI.widget:GetConfig()
    PH:PickupExisting(btnUI.widget)
    btnData[WAttr.TYPE] = WAttr.SPELL
    btnData[WAttr.SPELL] = spellInfo

    SpellAttributeSetter(btnUI, btnData)
end

function L:IsValid(btnUI, cursorInfo)
    return cursorInfo.type == nil or cursorInfo == nil or cursorInfo.id == nil
end
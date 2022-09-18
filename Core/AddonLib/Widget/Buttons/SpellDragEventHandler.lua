--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local SpellAttributeSetter, WAttr, PH = O.SpellAttributeSetter, O.CommonConstants.WidgetAttributes, O.PickupHandler
local Assert = O.Assert

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class SpellDragEventHandler
local _L = LibStub:NewLibrary(Core.M.SpellDragEventHandler)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---spellCursorInfo `{ type = actionType, name='TODO', bookIndex = info1, bookType = info2, id = info3 }`
---@param cursorInfo table Data structure`{ type = actionType, info1 = info1, info2 = info2, info3 = info3 }`
function _L:Handle(btnUI, cursorInfo)
    if not self:IsValid(btnUI, cursorInfo) then return end
    local spellCursorInfo = { type = cursorInfo.type,
                              id = cursorInfo.info3,
                              bookIndex = cursorInfo.info1,
                              bookType = cursorInfo.info2 }
    --self:log(50, 'SpellCursorInfo: %s', toStringSorted(spellCursorInfo))
    ---@type SpellInfo
    local spellInfo = _API:GetSpellInfo(spellCursorInfo.id)
    --self:log(50, 'GetSpellInfo: %s', toStringSorted(spellInfo))
    if Assert.IsNil(spellInfo) then return end

    local btnData = btnUI.widget:GetConfig()
    PH:PickupExisting(btnData)
    btnData[WAttr.TYPE] = WAttr.SPELL
    btnData[WAttr.SPELL] = spellInfo

    SpellAttributeSetter(btnUI, btnData)
end

function _L:IsValid(btnUI, cursorInfo)
    return cursorInfo.type == nil or cursorInfo == nil or cursorInfo.id == nil
end
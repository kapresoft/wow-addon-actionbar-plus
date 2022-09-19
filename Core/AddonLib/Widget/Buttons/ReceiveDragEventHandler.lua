--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local A, AT = O.Assert, O.ActionType
local SpellDragEventHandler, ItemDragEventHandler, MacroDragEventHandler = O.SpellDragEventHandler,
    O.ItemDragEventHandler, O.MacroDragEventHandler
local IsNotNil, AssertThatMethodArgIsNotNil = A.IsNotNil, A.AssertThatMethodArgIsNotNil

--[[-----------------------------------------------------------------------------
Interface
-------------------------------------------------------------------------------]]
---@class DragEventHandler
---@param btnUI ButtonUI
---@param cursorInfo CursorInfo
local DragEventHandler = {
    ['Handle'] = function(btnUI, cursorInfo)  end
}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class ReceiveDragEventHandler
local L = LibStub:NewLibrary(Core.M.ReceiveDragEventHandler)

--- Handlers with Interface Method ==> `Handler:Handle(btnUI, spellCursorInfo)`
local handlers = {
    ['spell'] = SpellDragEventHandler,
    ['item'] = ItemDragEventHandler,
    ['macro'] = MacroDragEventHandler,
    ['mount'] = O.MountDragEventHandler,
    ['macrotext'] = MacroDragEventHandler
}

-- ## Functions ------------------------------------------------
function L:CleanupProfile(btnUI, actionType)
    local btnData = btnUI.widget:GetConfig()
    if not btnData then return end

    local otherTypes = AT:GetOtherTypes(actionType)
    for _, at in ipairs(otherTypes) do
        btnData[at] = {}
    end
end

function L:CanHandle(actionType)
    local handler = handlers[actionType]
    return IsNotNil(handler) and IsNotNil(handler.Handle)
end

---@param cursorInfo CursorInfo
---@param btnUI ButtonUI
function L:Handle(btnUI, cursorInfo)
    AssertThatMethodArgIsNotNil(btnUI, 'btnUI', 'Handle(btnUI, actionType)')
    AssertThatMethodArgIsNotNil(cursorInfo, 'cursorInfo', 'Handle(btnUI, cursorInfo)')
    local actionType = cursorInfo.type
    if not self:CanHandle(actionType) then return end

    handlers[actionType]:Handle(btnUI, cursorInfo)

    self:CleanupProfile(btnUI, actionType)
end
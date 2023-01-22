--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local pformat = ns.pformat
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub

local A, AT, WAttr = O.Assert, O.ActionType, GC.WidgetAttributes
local AssertThatMethodArgIsNotNil = A.AssertThatMethodArgIsNotNil
local SPELL, ITEM, MACRO, MACRO_TEXT, MOUNT, COMPANION, BATTLE_PET =
    WAttr.SPELL, WAttr.ITEM, WAttr.MACRO, WAttr.MACRO_TEXT,
    WAttr.MOUNT, WAttr.COMPANION, WAttr.BATTLE_PET



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
---@class ReceiveDragEventHandler : BaseLibraryObject
local L = LibStub:NewLibrary(M.ReceiveDragEventHandler); if not L then return end
local p = L.logger

--- Handlers with Interface Method ==> `Handler:Handle(btnUI, spellCursorInfo)`
--- README: Also need to add the attribute setterin in ButtonFactor#AttributeSetters
local handlers = {
    [SPELL] = O.SpellDragEventHandler,
    [ITEM] = O.ItemDragEventHandler,
    [MACRO] = O.MacroDragEventHandler,
    [MOUNT] = O.MountDragEventHandler,
    [COMPANION] = O.CompanionDragEventHandler,
    [BATTLE_PET] = O.BattlePetDragEventHandler,
    [MACRO_TEXT] = O.MacroDragEventHandler,
}

---@param cursor CursorUtil
function L:IsSupportedCursorType(cursor)
    local handler = handlers[cursor:GetType()]
    if not (handler and handler.Handle) then return false end

    -- Optional method Supports():boolean
    if handler.Supports then return handler:Supports(cursor:GetCursor()) end

    return true
end

-- ## Functions ------------------------------------------------
function L:CleanupProfile(btnUI, actionType)
    local btnData = btnUI.widget:GetConfig()
    if not btnData then return end

    local otherTypes = AT:GetOtherTypes(actionType)
    for _, at in ipairs(otherTypes) do
        btnData[at] = {}
    end
end

---@param cursor CursorUtil
---@param btnUI ButtonUI
function L:Handle(btnUI, cursor)
    local cursorInfo = cursor:GetCursor()
    AssertThatMethodArgIsNotNil(btnUI, 'btnUI', 'Handle(btnUI, actionType)')
    AssertThatMethodArgIsNotNil(cursorInfo, 'cursorInfo', 'Handle(btnUI, cursorInfo)')
    p:log(10, 'Handle| CursorInfo: %s', pformat:B()(cursorInfo))
    local actionType = cursorInfo.type

    if not self:IsSupportedCursorType(cursor) then return end

    handlers[actionType]:Handle(btnUI, cursorInfo)
    self:CleanupProfile(btnUI, actionType)
end

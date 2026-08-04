--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local A, W = ns:Assert(), GC.WidgetAttributes
local AssertThatMethodArgIsNotNil = A.AssertThatMethodArgIsNotNil

--[[-----------------------------------------------------------------------------
Interface
-------------------------------------------------------------------------------]]
---@class DragEventHandler : BaseLibraryObject
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
local p = ns:LC().DRAG_AND_DROP:NewLogger(M.ReceiveDragEventHandler)

--- Handlers with Interface Method ==> `Handler:Handle(btnUI, spellCursorInfo)`
--- README: Also need to add the attribute setterin in ButtonFactor#AttributeSetters
local handlers = {
    [W.SPELL] = O.SpellDragEventHandler,
    [W.ITEM] = O.ItemDragEventHandler,
    [W.MACRO] = O.MacroDragEventHandler,
    [W.MOUNT] = O.MountDragEventHandler,
    [W.COMPANION] = O.CompanionDragEventHandler,
    [W.BATTLE_PET] = O.BattlePetDragEventHandler,
    [W.MACRO_TEXT] = O.MacroDragEventHandler,
    [W.EQUIPMENT_SET] = O.EquipmentSetDragEventHandler,
}

---@param cursor CursorUtil
function L:IsSupportedCursorType(cursor)
    if not (cursor and cursor:IsValid()) then return false end
    local handler = handlers[cursor:GetType()]
    if not (handler and handler.Handle) then
        p:d(function() return 'Unsupported cursor type: %s', tostring(cursor:GetType()) end)
        return false
    end

    -- Optional method Supports():boolean
    if handler.Supports then return handler:Supports(cursor:GetCursor()) end

    return true
end

---@param cursor CursorUtil
---@param btnUI ButtonUI
function L:Handle(btnUI, cursor)
    if not (btnUI and cursor) then return end
    local cursorInfo = cursor:GetCursor()
    p:d(function() return 'Handle():CursorInfo: %s', pformat:B()(cursorInfo) end)

    local actionType = cursorInfo.type

    if not self:IsSupportedCursorType(cursor) then return end

    handlers[actionType]:Handle(btnUI, cursorInfo)
    btnUI.widget:CleanupActionTypeData()
end

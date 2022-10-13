--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace(...)
local LibStub, Core, O, GC = ns.O.LibStub, ns.Core, ns.O, ns.O.GlobalConstants

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
---@class ReceiveDragEventHandler
local L = LibStub:NewLibrary(Core.M.ReceiveDragEventHandler)

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

---@param cursorInfo CursorInfo
function L:IsSupportedCursorType(cursorInfo)
    local cursorUtil = ABP_CreateCursorUtil(cursorInfo)
    if not cursorUtil:IsValid() then return false end

    local handler = handlers[cursorInfo.type]
    if not (handler and handler.Handle) then return false end

    -- Optional method Supports():boolean
    if handler.Supports then return handler:Supports(cursorInfo) end

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

---@param cursorInfo CursorInfo
---@param btnUI ButtonUI
function L:Handle(btnUI, cursorInfo)
    AssertThatMethodArgIsNotNil(btnUI, 'btnUI', 'Handle(btnUI, actionType)')
    AssertThatMethodArgIsNotNil(cursorInfo, 'cursorInfo', 'Handle(btnUI, cursorInfo)')
    self:log(10, 'Handle| CursorInfo: %s', pformat:B()(cursorInfo))
    local actionType = cursorInfo.type

    if not self:IsSupportedCursorType(cursorInfo) then return end

    handlers[actionType]:Handle(btnUI, cursorInfo)
    self:CleanupProfile(btnUI, actionType)
end
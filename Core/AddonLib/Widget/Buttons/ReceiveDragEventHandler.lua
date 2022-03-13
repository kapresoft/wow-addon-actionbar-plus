-- ## External -------------------------------------------------

-- ## Local ----------------------------------------------------
local LibStub, M, A, P, LSM, W, CC, G = ABP_WidgetConstants:LibPack()
local SpellDragEventHandler, ItemDragEventHandler, MacroDragEventHandler = W:LibPack_DragEventHandlers()

local IsNotNil, AssertThatMethodArgIsNotNil, Throw = A.IsNotNil, A.AssertThatMethodArgIsNotNil, A.Throw
local AT = ABP_ActionType

---@class ReceiveDragEventHandler
local _L = LibStub:NewLibrary(M.ReceiveDragEventHandler)

--- Handlers with Interface Method ==> `Handler:Handle(btnUI, spellCursorInfo)`
local handlers = {
    ['spell'] = SpellDragEventHandler,
    ['item'] = ItemDragEventHandler,
    ['macro'] = MacroDragEventHandler,
    ['macrotext'] = MacroDragEventHandler
}

-- ## Functions ------------------------------------------------
function _L:CleanupProfile(btnUI, actionType)
    local btnData = btnUI.widget:GetConfig()
    if not btnData then return end

    local otherTypes = AT:GetOtherTypes(actionType)
    for _, at in ipairs(otherTypes) do
        btnData[at] = {}
    end
end

function _L:CanHandle(actionType)
    local handler = handlers[actionType]
    local hasHandler = IsNotNil(handler) and IsNotNil(handler.Handle)
    self:log(10, 'Can handle drag event from [%s]? %s', actionType, hasHandler)
    return hasHandler
end

function _L:Handle(btnUI, actionType, cursorInfo)
    AssertThatMethodArgIsNotNil(btnUI, 'btnUI', 'Handle(btnUI, actionType)')
    AssertThatMethodArgIsNotNil(actionType, 'actionType', 'Handle(btnUI, actionType)')

    if not self:CanHandle(actionType) then
        Throw('Handler not found for action-type: %s', actionType)
    end

    handlers[actionType]:Handle(btnUI, cursorInfo)
    btnUI.widget:UpdateTooltip()

    self:CleanupProfile(btnUI, actionType)
end
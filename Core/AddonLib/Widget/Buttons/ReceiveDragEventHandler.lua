local IsNotNil, AssertThatMethodArgIsNotNil, Throw = Assert.IsNotNil, Assert.AssertThatMethodArgIsNotNil, Assert.Throw
local SpellDragEventHandler, ItemDragEventHandler, MacroDragEventHandler =
    SpellDragEventHandler, ItemDragEventHandler, MacroDragEventHandler
local LOG, AT = ABP_LogFactory, ABP_ActionType

local H = {}
LOG:EmbedLogger(H, 'ReceiveDragEventHandler')

ReceiveDragEventHandler = H

--- Handlers with Interface Method ==> `Handler:Handle(btnUI, spellCursorInfo)`
local handlers = {
    ['spell'] = SpellDragEventHandler,
    ['item'] = ItemDragEventHandler,
    ['macro'] = MacroDragEventHandler,
    ['macrotext'] = MacroDragEventHandler
}

function H:CleanupProfile(btnUI, actionType)
    local btnData = btnUI:GetProfileButtonData()
    if not btnData then return end

    local otherTypes = AT:GetOtherTypes(actionType)
    for _, at in ipairs(otherTypes) do
        btnData[at] = {}
    end

    ABP:DBG(btnData, 'Updated Btn Data')
end

function H:CanHandle(actionType)
    local handler = handlers[actionType]
    local hasHandler = IsNotNil(handler) and IsNotNil(handler.Handle)
    self:log(10, 'Can handle drag event from [%s]? %s', actionType, hasHandler)
    return hasHandler
end

function H:Handle(btnUI, actionType, cursorInfo)
    AssertThatMethodArgIsNotNil(btnUI, 'btnUI', 'Handle(btnUI, actionType)')
    AssertThatMethodArgIsNotNil(actionType, 'actionType', 'Handle(btnUI, actionType)')

    if not self:CanHandle(actionType) then
        Throw('Handler not found for action-type: %s', actionType)
    end

    handlers[actionType]:Handle(btnUI, cursorInfo)

    self:CleanupProfile(btnUI, actionType)
end
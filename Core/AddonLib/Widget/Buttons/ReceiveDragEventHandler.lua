local IsNotNil, AssertThatMethodArgIsNotNil, Throw = Assert.IsNotNil, Assert.AssertThatMethodArgIsNotNil, Assert.Throw
local format = string.format
local ACE_LIB, LOG, PrettyPrint, _API_Spell = AceLibFactory, ABP_LogFactory, PrettyPrint, _API_Spell
local BATTR, TEXTURE_HIGHLIGHT = ButtonAttributes, TEXTURE_HIGHLIGHT
local SpellDragEventHandler, ItemDragEventHandler, MacroDragEventHandler =
    SpellDragEventHandler, ItemDragEventHandler, MacroDragEventHandler

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

function H:CanHandle(actionType)
    local handler = handlers[actionType]
    local hasHandler = IsNotNil(handler) and IsNotNil(handler.Handle)
    self:log(10, 'Can handle? %s type: %s', hasHandler, actionType)
    return hasHandler
end

function H:Handle(btnUI, actionType, cursorInfo)
    AssertThatMethodArgIsNotNil(btnUI, 'btnUI', 'Handle(btnUI, actionType)')
    AssertThatMethodArgIsNotNil(actionType, 'actionType', 'Handle(btnUI, actionType)')

    if not self:CanHandle(actionType) then
        Throw('Handler not found for action-type: %s', actionType)
    end
    --ABP:DBG('handler', {type=actionType, cursorInfo=cursorInfo})
    return handlers[actionType]:Handle(btnUI, cursorInfo)
end
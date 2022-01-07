local IsNotNil, AssertThatMethodArgIsNotNil, Throw = Assert.IsNotNil, Assert.AssertThatMethodArgIsNotNil, Assert.Throw
local format = string.format
local ACE_LIB, LOG, PrettyPrint, _API_Spell = AceLibFactory, LogFactory, PrettyPrint, _API_Spell
local BATTR, TEXTURE_HIGHLIGHT = ButtonAttributes, TEXTURE_HIGHLIGHT
local SpellDragEventHandler = SpellDragEventHandler

local H = {}
local l = LOG('RecvDragEH')

ReceiveDragEventHandler = H

local ItemHandler = {
    Handle = function(self, btnUI, cursorInfo)
        l:log('item drag received: %s', btnUI:GetName())
    end

}

local MacroHandler = {
    Handle = function(self, btnUI, cursorInfo)
        l:log('macro drag received: %s', btnUI:GetName())

    end
}

local MacroTextHandler = {
    Handle = function(self, btnUI, cursorInfo)
        l:log('macrotext drag received: %s', btnUI:GetName())

    end
}
--- Handlers with Interface Method ==> `Handler:Handle(btnUI, spellCursorInfo)`
local handlers = {
    ['spell'] = SpellDragEventHandler,
    ['item'] = ItemHandler,
    ['macro'] = MacroHandler,
    ['macrotext'] = MacroTextHandler
}

function H:CanHandle(actionType)
    local handler = handlers[actionType]
    local hasHandler = IsNotNil(handler) and IsNotNil(handler.Handle)
    return hasHandler
end

function H:Handle(btnUI, actionType, cursorInfo)
    AssertThatMethodArgIsNotNil(btnUI, 'btnUI', 'Handle(btnUI, actionType)')
    AssertThatMethodArgIsNotNil(actionType, 'actionType', 'Handle(btnUI, actionType)')

    if not self:CanHandle(actionType) then
        Throw('Handler not found for action-type: %s', actionType)
    end
    return handlers[actionType]:Handle(btnUI, cursorInfo)
end
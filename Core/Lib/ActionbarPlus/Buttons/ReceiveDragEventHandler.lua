local H = {}
ReceiveDragEventHandler = H

local SpellHandler = {

    handleOnReceiveDragEvent = function()

    end

}

local ItemHandler = {

}

local MacroHandler = {

}

local MacroTextHandler = {

}

local handlers = {
    ['spell'] = SpellHandler,
    ['item'] = ItemHandler,
    ['macro'] = MacroHandler,
    ['macrotext'] = MacroTextHandler
}

function H:CanHandle(actionType)
    return type(handlers[actionType]) == 'function'
end

function H:GetHandler(actionType)
    return handlers[actionType]
end
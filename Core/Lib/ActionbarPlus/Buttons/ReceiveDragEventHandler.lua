local IsNotNil, AssertThatMethodArgIsNotNil, Throw = Assert.IsNotNil, Assert.AssertThatMethodArgIsNotNil, Assert.Throw
local format = string.format

local H = {}
LibFactory:GetLogger():Embed(H, 'RDEH')
ReceiveDragEventHandler = H

local smedia = LibFactory:GetAceSharedMedia()
local noIconTexture = smedia:Fetch(smedia.MediaType.BACKGROUND, "Blizzard Dialog Background")
local highlightIconTexture = smedia:Fetch(smedia.MediaType.BACKGROUND, "Blizzard Parchment")

local UNIT = 'unit'
local A = {
    SPELL = "spell",
    UNIT = UNIT,
    UNIT2 = format("*%s2", UNIT),
    TYPE = "type",
    MACRO_TEXT = "macrotext",
    MACRO = "macro",
}

local function ResetAttributes(btnUI)
    for _,v in pairs(A) do
        H:log('Resetting Attribute: %s', v)
        btnUI:SetAttribute(v, nil)
    end
end

local SpellHandler = {}
---@param spellCursorInfo table Structure `{ type = actionType, name='TODO', bookIndex = info1, bookType = info2, id = info3 }`
function SpellHandler:Handle(btnUI, spellCursorInfo)
    H:log('XXXX btnUI', spellCursorInfo)
    H:logp(format('Spell Cursor Info for Button (%s)', btnUI:GetName()), spellCursorInfo)
    if spellCursorInfo == nil or spellCursorInfo.id == nil then return end
    local spellInfo = _Spell:GetSpellInfo(spellCursorInfo.id)
    H:logp('Spell Info', spellInfo)
    self:SetSpellAttributes(btnUI, spellInfo)
end

function SpellHandler:SetSpellAttributes(btnUI, spellInfo)
    ResetAttributes(btnUI)

    btnUI:SetNormalTexture(spellInfo.icon)
    btnUI:SetHighlightTexture(highlightIconTexture)
    H:log('btnUI: %s', type(btnUI))
    H:logp('btnUI', btnUI)
    btnUI:SetAttribute(A.TYPE, 'spell')
    btnUI:SetAttribute(A.SPELL, spellInfo.id)
    btnUI:SetAttribute(A.UNIT2, 'focus')
end

local ItemHandler = {
    Handle = function(self, btnUI, cursorInfo)
        H:log('item drag received: %s', btnUI:GetName())
    end

}

local MacroHandler = {
    Handle = function(self, btnUI, cursorInfo)
        H:log('macro drag received: %s', btnUI:GetName())

    end
}

local MacroTextHandler = {
    Handle = function(self, btnUI, cursorInfo)
        H:log('macrotext drag received: %s', btnUI:GetName())

    end
}

local handlers = {
    ['spell'] = SpellHandler,
    ['item'] = ItemHandler,
    ['macro'] = MacroHandler,
    ['macrotext'] = MacroTextHandler
}

function H:CanHandle(actionType)
    local handler = handlers[actionType]
    --local hasHandler = nil ~= handler and nil ~= handler.handle
    local hasHandler = IsNotNil(handler) and IsNotNil(handler.Handle)
    self:log('CanHandle: %s', hasHandler)
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
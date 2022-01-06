local format, lower, setmetatable = string.format, string.lower, setmetatable

local ButtonType = {
    SPELL = "spell",
    ITEM = "item",
    MACRO = "macro",
    MACROTEXT = "macrotext",
}

local ButtonTypeCode = {
    SPELL = 1,
    ITEM = 2,
    MACRO = 3,
    MACROTEXT = 4
}


--- Can call as:
---  BT:new(code, value) or BT:new{code=code, value=value}
---@param code number The button type code
---@param value string The button type value
function ButtonType:new(code, value)
    local obj = {}
    if type(code) ~= 'table' then
        obj.code = code
        obj.value = value
    else
        local arg = code
        if (type(arg.code) ~= nil) then obj.code = arg.code end
        if (type(arg.value) ~= nil) then obj.value = arg.value end
    end
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function ButtonType:toString()
    return format('code=[%s] value=[%s]', self.code, self.value)
end

local BTE = {
    SPELL = ButtonType:new(ButtonTypeCode.SPELL, ButtonType.SPELL),
    ITEM = ButtonType:new(ButtonTypeCode.ITEM, ButtonType.ITEM),
    MACRO = ButtonType:new(ButtonTypeCode.MACRO, ButtonType.MACRO),
    MACROTEXT = ButtonType:new(ButtonTypeCode.MACROTEXT, ButtonType.MACROTEXT),
}

-----@param buttonType string The button type string
function BTE:IsSpell(buttonType) return ButtonType.SPELL == lower(buttonType or '') end

-----@param buttonCode string The numeric button type code
function BTE:IsSpellCode(buttonCode) return ButtonTypeCode.SPELL == buttonCode end

-----@param buttonType string The button type string
function BTE:IsItem(buttonType) return ButtonType.ITEM == lower(buttonType or '') end

-----@param buttonCode string The numeric button type code
function BTE:IsItemCode(buttonCode) return ButtonTypeCode.ITEM == buttonCode end

-----@param buttonType string The button type string
function BTE:IsMacro(buttonType) return ButtonType.MACRO == lower(buttonType or '') end

-----@param buttonCode string The numeric button type code
function BTE:IsMacroCode(buttonCode) return ButtonTypeCode.MACRO == buttonCode end

-----@param buttonType string The button type string
function BTE:IsMacroText(buttonType) return ButtonType.MACROTEXT == lower(buttonType or '') end

-----@param buttonCode string The numeric button type code
function BTE:IsMacroTextCode(buttonCode) return ButtonTypeCode.MACROTEXT == buttonCode end

ButtonTypes = BTE
local AssertNotNil = Assert.AssertNotNil
local WLIB, MacroAttributeSetter = WidgetLibFactory, MacroAttributeSetter
local ButtonAttributes, _API_Spell, IsNil = ButtonAttributes, _API_Spell, Assert.IsNil
local LOG = ABP_LogFactory

local P = WLIB:GetProfile()

local S = {}
LOG:EmbedLogger(S, 'MacroDragEventHandler')
MacroDragEventHandler = S

function S:IsMacrotext(macroInfo)
    return macroInfo.type == 'macrotext'
end

---@param cursorInfo table Structure `{ -- }`
function S:Handle(btnUI, cursorInfo)
    local macroInfo = { type = cursorInfo.type, macroIndex = cursorInfo.info1 }
    self:log('TODO: Handle macro:  %s', PrettyPrint.pformat(macroInfo))
    if self:IsMacrotext(macroInfo) then
        self:HandleMacrotext(btnUI, cursorInfo)
        return
    end

    if macroInfo == nil or macroInfo.macroIndex == nil then return end
    --local itemInfo = _API_Spell:GetSpellInfo(spellCursorInfo.id)
    local macroInfo = nil
    if IsNil(macroInfo) then return end
    --self:logp('spellInfo', spellInfo)

    local actionbarInfo = btnUI:GetActionbarInfo()
    --self:logp('ActionBar', actionbarInfo)
    local btnName = btnUI:GetName()
    local barData = P:GetBar(actionbarInfo.index)

    local btnData = barData.buttons[btnName] or P:GetTemplate().Button
    btnData.type = ButtonAttributes.MACRO
    btnData[btnData.type] = macroInfo
    barData.buttons[btnName] = btnData

    MacroAttributeSetter(btnUI, btnData)
end

function S:HandleMacrotext(btnUI, cursorInfo)

end

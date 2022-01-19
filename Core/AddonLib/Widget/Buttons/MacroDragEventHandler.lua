local LOG, PrettyPrint = ABP_LogFactory, AceLibAddonFactory:GetPrettyPrint()
local pformat = PrettyPrint.pformat
local WLIB, MacroAttributeSetter = WidgetLibFactory, MacroAttributeSetter
local AssertNotNil = Assert.AssertNotNil
local ButtonAttributes, _API_Spell, IsNil = ButtonAttributes, _API_Spell, Assert.IsNil

-- TODO: Move to API
local GetMacroInfo, GetActionTexture = GetMacroInfo, GetActionTexture

local P = WLIB:GetProfile()

local S = {}
LOG:EmbedLogger(S, 'MacroDragEventHandler')
MacroDragEventHandler = S

function S:IsMacrotext(macroInfo)
    return macroInfo.type == 'macrotext'
end

---@param cursorInfo table Structure `{ -- }`
function S:Handle(btnUI, cursorInfo)
    self:log(10, 'cursorInfo: %s', cursorInfo)
    if cursorInfo == nil or cursorInfo.info1 == nil then return end
    local macroInfo = self:GetMacroInfo(cursorInfo)
    -- replace %s in macros, has log format issues
    local macroInfoText = ABP_String.replace(pformat(macroInfo), '%s', '$s')
    self:log(10, 'macroInfo: %s', macroInfoText)
    --DEVT:EvalObject(macroInfo, 'macroInfo')

    if self:IsMacrotext(macroInfo) then
        self:HandleMacrotext(btnUI, cursorInfo)
        return
    end
    if IsNil(macroInfo) then return end

    --- ActionBarInfo `{ index = 2, name = 'ActionbarPlusF2' }`
    local actionbarInfo = btnUI:GetActionbarInfo()
    -- DEVT:EvalObject(actionbarInfo, 'actionbarInfo')

    local btnName = btnUI:GetName()
    local barData = P:GetBar(actionbarInfo.index)

    local btnData = barData.buttons[btnName] or P:GetTemplate().Button
    btnData.type = ButtonAttributes.MACRO
    btnData[btnData.type] = macroInfo
    barData.buttons[btnName] = btnData

    MacroAttributeSetter(btnUI, btnData)
end

--- {
---     body = '/run message(GetXPExhaustion())\n',
---     icon = 132096,
---     index = 1,
---     name = '#GetRestedXP',
---     type = 'macro'
--- }
---@param cursorInfo table Cursor Info `{ type='type', info1='macroIndex' }`
function S:GetMacroInfo(cursorInfo)
    local macroIndex = cursorInfo.info1
    local macroName, macroIconId, macroBody, isLocal = GetMacroInfo(macroIndex)
    local macroInfo = {
        type = cursorInfo.type,
        index = macroIndex,
        name = macroName, icon = macroIconId, body = macroBody,
        isLocal = isLocal,
    }


    return macroInfo
end

function S:HandleMacrotext(btnUI, cursorInfo)

end

-- ## External -------------------------------------------------
-- TODO: Move to API
local GetMacroInfo, GetActionTexture = GetMacroInfo, GetActionTexture

-- ## Local ----------------------------------------------------
local PrettyPrint, Table, String, LogFactory = ABP_LibGlobals:LibPackUtils()

local LibStub, M, A, P, _, W, CC = ABP_WidgetConstants:LibPack()
local MacroAttributeSetter = W:MacroAttributeSetter()
local ButtonAttributes = CC.ButtonAttributes

local s_replace, IsNil = String.replace, A.IsNil

---@class MacroDragEventHandler
local _L = LibStub:NewLibrary(M.MacroDragEventHandler)

-- ## Functions ------------------------------------------------
function _L:IsMacrotext(macroInfo)
    return macroInfo.type == 'macrotext'
end

---@param cursorInfo table Structure `{ -- }`
function _L:Handle(btnUI, cursorInfo)
    self:log(10, 'cursorInfo: %s', cursorInfo)
    if cursorInfo == nil or cursorInfo.info1 == nil then return end
    local macroInfo = self:GetMacroInfo(cursorInfo)
    -- replace %s in macros, has log format issues
    local macroInfoText = s_replace(pformat(macroInfo), '%s', '$s')
    self:log(10, 'macroInfo: %s', macroInfoText)
    --DEVT:EvalObject(macroInfo, 'macroInfo')

    if self:IsMacrotext(macroInfo) then
        self:HandleMacrotext(btnUI, cursorInfo)
        return
    end
    if IsNil(macroInfo) then return end

    --- ActionBarInfo `{ index = 2, name = 'ActionbarPlusF2' }`
    local actionbarInfo = btnUI.widget:GetActionbarInfo()
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
function _L:GetMacroInfo(cursorInfo)
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

function _L:HandleMacrotext(btnUI, cursorInfo)

end

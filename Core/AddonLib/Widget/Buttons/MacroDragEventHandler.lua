--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetMacroInfo = GetMacroInfo

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local Assert, String = O.Assert, O.String
local MacroAttributeSetter, WAttr, PH = O.MacroAttributeSetter, O.CommonConstants.WidgetAttributes, O.PickupHandler
local s_replace, IsNil = String.replace, Assert.IsNil

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class MacroDragEventHandler
local _L = LibStub:NewLibrary(Core.M.MacroDragEventHandler)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function _L:IsMacrotext(macroInfo) return macroInfo.type == 'macrotext' end

---@param cursorInfo table Structure `{ -- }`
function _L:Handle(btnUI, cursorInfo)
    self:log(10, 'cursorInfo: %s', cursorInfo)
    if cursorInfo == nil or cursorInfo.info1 == nil then return end
    local macroInfo = self:GetMacroInfo(cursorInfo)
    -- replace %s in macros, has log format issues
    local macroInfoText = s_replace(pformat(macroInfo), '%s', '$s')
    --self:log(10, 'macroInfo: %s', macroInfoText)
    --DEVT:EvalObject(macroInfo, 'macroInfo')

    if self:IsMacrotext(macroInfo) then
        self:HandleMacrotext(btnUI, cursorInfo)
        return
    end
    if IsNil(macroInfo) then return end

    local btnData = btnUI.widget:GetConfig()
    PH:PickupExisting(btnData)
    btnData[WAttr.TYPE] = WAttr.MACRO
    btnData[WAttr.MACRO] = macroInfo

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
    -- TODO: Not yet needed
end

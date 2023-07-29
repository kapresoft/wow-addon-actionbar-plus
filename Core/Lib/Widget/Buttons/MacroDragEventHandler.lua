--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local pformat = ns.pformat
local O, LibStub, GC = ns.O, ns.LibStub, ns.O.GlobalConstants


local Assert, String = O.Assert, O.String
local MacroAttributeSetter, WAttr, PH = O.MacroAttributeSetter, GC.WidgetAttributes, O.PickupHandler
local s_replace, IsNil = String.replace, Assert.IsNil
local warnColor = WARNING_FONT_COLOR or RED_FONT_COLOR
local highlightColor =  HIGHLIGHT_LIGHT_BLUE or BLUE_FONT_COLOR

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class MacroDragEventHandler : DragEventHandler
local L = LibStub:NewLibrary(ns.M.MacroDragEventHandler)
local p = L:GetLogger()
local LL = GC:GetAceLocale()

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function L:IsMacrotext(macroInfo) return macroInfo.type == 'macrotext' end

---@param cursorInfo CursorInfo
function L:Supports(cursorInfo)
    local c = ns:CreateCursorUtil(cursorInfo)
    if c:IsM6Macro() then
        local isEnabled  = GC:IsActionbarPlusM6Enabled()
        if isEnabled ~= true then
            local msg = warnColor:WrapTextInColorCode(LL['Requires ActionbarPlus-M6::Message'])
                    .. ' ' .. highlightColor:WrapTextInColorCode(LL['ActionbarPlus-M6 URL'])
            p:log(msg)
        end

        p:log(10, 'm6 supported: %s', isEnabled)
        return isEnabled
    end
    return true
end

---@param cursorInfo table Structure `{ -- }`
---@param btnUI ButtonUI
function L:Handle(btnUI, cursorInfo)
    if cursorInfo == nil or cursorInfo.info1 == nil then return end
    local macroInfo = self:GetMacroInfo(cursorInfo)
    -- replace %s in macros, has log format issues
    -- local macroInfoText = s_replace(pformat(macroInfo), '%s', '$s')
    -- self:log(10, 'macroInfo: %s', macroInfoText)
    -- DEVT:EvalObject(macroInfo, 'macroInfo')

    if self:IsMacrotext(macroInfo) then
        self:HandleMacrotext(btnUI, cursorInfo)
        return
    end
    if IsNil(macroInfo) then return end

    local btnData = btnUI.widget:conf()
    PH:PickupExisting(btnUI.widget)
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
function L:GetMacroInfo(cursorInfo)
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

function L:HandleMacrotext(btnUI, cursorInfo)
    -- TODO: Not yet needed
end

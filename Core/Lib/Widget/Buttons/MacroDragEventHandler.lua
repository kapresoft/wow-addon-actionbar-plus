----[[-----------------------------------------------------------------------------
--Lua Vars
---------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local Assert, String = ns:Assert(), ns:String()
local WAttr, PH    = GC.WidgetAttributes, O.PickupHandler
local AceEvent, TT = ns:AceLibrary().AceEvent, O.TooltipUtil

local IsNil = Assert.IsNil
local warnColor = WARNING_FONT_COLOR or RED_FONT_COLOR
local highlightColor =  HIGHLIGHT_LIGHT_BLUE or BLUE_FONT_COLOR

local MACRO_WITHOUT_SPELL_FORMAT = '%s |cfd5a5a5a(Macro)|r'
local MACRO_WITH_SPELL_FORMAT = '|cfd03c2fc::|r |cfd03c2fc%s|r |cfd5a5a5a(Macro)|r'
local MACRO_WITH_SPELL_RIGHT_FORMAT = '|cfd03c2fc%s|r |cfd5a5a5a(Macro)|r'

local enableExternalAPI = GC.F.ENABLE_EXTERNAL_API

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class MacroDragEventHandler : DragEventHandler
local L = LibStub:NewLibrary(M.MacroDragEventHandler)
local p = ns:LC().MACRO:NewLogger(M.MacroDragEventHandler)
local LL = GC:GetAceLocale()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class MacroAttributeSetter : BaseAttributeSetter
local S = LibStub:NewLibrary(ns.M.MacroAttributeSetter); if not S then return end; AceEvent:Embed(S)
---@type BaseAttributeSetter
local BaseAttributeSetter = LibStub(ns.M.BaseAttributeSetter)
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function api() return O.API end

-- todo next: move to api?
--- @param bw ButtonUIWidget
local function Button_UpdateMacro(bw)
    local macroIndex = bw:GetMacroIndex(); if not macroIndex then return end
    local icon = api():GetMacroIcon(macroIndex)
    return icon and bw:SetIcon(icon)
end

--[[-----------------------------------------------------------------------------
Methods: MacroDragEventHandler
-------------------------------------------------------------------------------]]
---@param e MacroDragEventHandler
local function eventHandlerMethods(e)

    function e:IsMacrotext(macroInfo) return macroInfo.type == 'macrotext' end

    ---@param cursorInfo CursorInfo
    function e:Supports(cursorInfo)
        local c = ns:CreateCursorUtil(cursorInfo)

        if enableExternalAPI and c:IsM6Macro() then
            local isEnabled  = O.M6Support.enabled
            if isEnabled ~= true then
                local msg = warnColor:WrapTextInColorCode(LL['Requires ActionbarPlus-M6::Message'])
                        .. ' ' .. highlightColor:WrapTextInColorCode(LL['ActionbarPlus-M6 URL'])
                p:w(msg)
            end
            p:d(function() return 'm6 supported: %s', tostring(isEnabled) end)
            return isEnabled
        end

        return true
    end

    ---@param cursorInfo table Structure `{ -- }`
    ---@param btnUI ButtonUI
    function e:Handle(btnUI, cursorInfo)
        if cursorInfo == nil or cursorInfo.info1 == nil then return end
        local macroInfo = self:GetMacroData(cursorInfo)
        p:d(function() return 'Macro: %s', macroInfo end)

        if self:IsMacrotext(macroInfo) then
            self:HandleMacrotext(btnUI, cursorInfo)
            return
        end
        if IsNil(macroInfo) then return end

        local btnData = btnUI.widget:conf()
        PH:PickupExisting(btnUI.widget)
        btnData[WAttr.TYPE] = WAttr.MACRO
        btnData[WAttr.MACRO] = macroInfo

        S(btnUI, btnData)
    end

    --- {
    ---     body = '/run message(GetXPExhaustion())\n',
    ---     icon = 132096,
    ---     index = 1,
    ---     name = '#GetRestedXP',
    ---     type = 'macro'
    --- }
    --- @param cursorInfo table Cursor Info `{ type='type', info1='macroIndex' }`
    --- @return Profile_Macro
    function e:GetMacroData(cursorInfo)
        local macroIndex = cursorInfo.info1
        local macroName, macroIconId, macroBody = GetMacroInfo(macroIndex)

        --- @type Profile_Macro
        local macroData = {
            type = WAttr.MACRO, index = macroIndex, name = macroName,
            bodyFingerprint = api():FingerprintMacroBody(macroBody),
        }
        return macroData
    end

    function e:HandleMacrotext(btnUI, cursorInfo)
        -- Not yet needed
    end

end

--[[-----------------------------------------------------------------------------
Methods: MacroAttributeSetter
-------------------------------------------------------------------------------]]
--- @param a MacroAttributeSetter
local function attributeSetterMethods(a)

    ---@param btnUI ButtonUI
    function a:SetAttributes(btnUI)

        local w = btnUI.widget
        w:ResetWidgetAttributes(btnUI)
        local c = w:conf()
        local macroInfo = c.macro; if not c:IsMacro() then return end

        btnUI:SetAttribute(WAttr.TYPE, WAttr.MACRO)
        btnUI:SetAttribute(WAttr.MACRO, macroInfo.index)
        w:SetNameText(macroInfo.name)

        if enableExternalAPI and w:IsM6Macro(macroInfo.name) then
            self:SendMessage(GC.M.MacroAttributeSetter_OnSetIcon, M.MacroAttributeSetter, function() return w, macroInfo.name end)
        end

        C_Timer.NewTicker(0.01, function() Button_UpdateMacro(w) end, 2)
        self:OnAfterSetAttributes(btnUI)
    end

    --- @see ButtonFactory#InitButtonGameTooltipHooksLegacy
    --- @see ButtonFactory#InitButtonGameTooltipHooksUsingTooltipDataProcessor
    --- @param btnUI ButtonUI
    function a:ShowTooltip(btnUI) TT:ShowTooltip_Macro(GameTooltip, btnUI.widget) end
end

--- @return MacroAttributeSetter
function L:GetAttributeSetter() return S end


--[[-----------------------------------------------------------------------------
Init
-------------------------------------------------------------------------------]]
local function Init()
    eventHandlerMethods(L)
    attributeSetterMethods(S)

    S.mt.__index = BaseAttributeSetter
    S.mt.__call = S.SetAttributes
end

Init()

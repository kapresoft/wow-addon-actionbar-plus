----[[-----------------------------------------------------------------------------
--Lua Vars
---------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, LibStub, GC = ns.O, ns.LibStub, ns.O.GlobalConstants

local Assert, String = O.Assert, O.String
local WAttr, PH = GC.WidgetAttributes, O.PickupHandler
local AceEvent = O.AceLibrary.AceEvent

local s_replace, IsNil = String.replace, Assert.IsNil
local warnColor = WARNING_FONT_COLOR or RED_FONT_COLOR
local highlightColor =  HIGHLIGHT_LIGHT_BLUE or BLUE_FONT_COLOR

local MACRO_WITHOUT_SPELL_FORMAT = '%s |cfd5a5a5a(Macro)|r'
local MACRO_WITH_SPELL_FORMAT = '|cfd03c2fc::|r |cfd03c2fc%s|r |cfd5a5a5a(Macro)|r'


--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class MacroDragEventHandler : DragEventHandler
local L = LibStub:NewLibrary(ns.M.MacroDragEventHandler)
local p = L:GetLogger()
local LL = GC:GetAceLocale()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class MacroAttributeSetter : BaseAttributeSetter
local S = LibStub:NewLibrary(ns.M.MacroAttributeSetter); if not S then return end; AceEvent:Embed(S)
---@type BaseAttributeSetter
local BaseAttributeSetter = LibStub(ns.M.BaseAttributeSetter)

--[[-----------------------------------------------------------------------------
Methods: MacroDragEventHandler
-------------------------------------------------------------------------------]]
---@param e MacroDragEventHandler
local function eventHandlerMethods(e)

    function e:IsMacrotext(macroInfo) return macroInfo.type == 'macrotext' end

    ---@param cursorInfo CursorInfo
    function e:Supports(cursorInfo)
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
    function e:Handle(btnUI, cursorInfo)
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

        S(btnUI, btnData)
    end

    --- {
    ---     body = '/run message(GetXPExhaustion())\n',
    ---     icon = 132096,
    ---     index = 1,
    ---     name = '#GetRestedXP',
    ---     type = 'macro'
    --- }
    ---@param cursorInfo table Cursor Info `{ type='type', info1='macroIndex' }`
    function e:GetMacroInfo(cursorInfo)
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
        local macroInfo = w:GetMacroData()
        if w:IsInvalidMacro(macroInfo) then return end

        local icon = GC.Textures.TEXTURE_EMPTY
        if macroInfo.icon then icon = macroInfo.icon end

        btnUI:SetAttribute(WAttr.TYPE, WAttr.MACRO)
        btnUI:SetAttribute(WAttr.MACRO, macroInfo.index or macroInfo.macroIndex)
        w:SetIcon(icon)

        if w:IsM6Macro(macroInfo.name) then
            self:SendMessage(GC.M.MacroAttributeSetter_OnSetIcon, ns.name, function() return w, macroInfo.name end)
        end

        C_Timer.NewTicker(0.01, function() w:UpdateMacroState() end, 2)
        self:OnAfterSetAttributes(btnUI)
    end

    ---@param btnUI ButtonUI
    function a:ShowTooltip(btnUI)
        local w = btnUI.widget

        if not w:ConfigContainsValidActionType() then return end

        local macroInfo = w:GetMacroData()
        if w:IsInvalidMacro(macroInfo) then return end

        if w:IsM6Macro(macroInfo.name) then
            self:SendMessage(GC.M.MacroAttributeSetter_OnShowTooltip, ns.name, function() return w, macroInfo.name end)
            return
        end

        local spellId = GetMacroSpell(macroInfo.index)
        if not spellId then
            local _, itemLink = GetMacroItem(macroInfo.index)
            if not itemLink then
                GameTooltip:SetText(sformat(MACRO_WITHOUT_SPELL_FORMAT, macroInfo.name))
                return
            end
            GameTooltip:SetHyperlink(itemLink)
        else
            GameTooltip:SetSpellByID(spellId)
        end
        GameTooltip:AppendText(' ' .. sformat(MACRO_WITH_SPELL_FORMAT, macroInfo.name))
    end
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

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip, GetMacroSpell, GetMacroItem = GameTooltip, GetMacroSpell, GetMacroItem

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace(...)
local LibStub, Core, O = ns.O.LibStub, ns.Core, ns.O

local GC = O.GlobalConstants
local String, WAttr = O.String, GC.WidgetAttributes
local MACRO_WITHOUT_SPELL_FORMAT = '%s |cfd5a5a5a(Macro)|r'
local MACRO_WITH_SPELL_FORMAT = '|cfd03c2fc::|r |cfd03c2fc%s|r |cfd5a5a5a(Macro)|r'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class MacroAttributeSetter : BaseAttributeSetter
local S = LibStub:NewLibrary(Core.M.MacroAttributeSetter)
---@type BaseAttributeSetter
local BaseAttributeSetter = LibStub(Core.M.BaseAttributeSetter)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

---@param btnUI ButtonUI
---@param btnData Profile_Button
function S:SetAttributes(btnUI, btnData)
    btnUI.widget:ResetWidgetAttributes(btnUI)

    local macroInfo = btnData[WAttr.MACRO]
    local icon = GC.Textures.TEXTURE_EMPTY
    if macroInfo.icon then icon = macroInfo.icon end

    btnUI:SetAttribute(WAttr.TYPE, WAttr.MACRO)
    btnUI:SetAttribute(WAttr.MACRO, macroInfo.index or macroInfo.macroIndex)
    btnUI.widget:SetIcon(icon)

    self:OnAfterSetAttributes(btnUI)
end

---@param btnUI ButtonUI
function S:ShowTooltip(btnUI)
    local bd = btnUI.widget:GetButtonData()
    if not bd:ConfigContainsValidActionType() then return end
    local btnData = btnUI.widget:GetConfig()

    local macroInfo = btnData[WAttr.MACRO]
    if not (macroInfo.index or macroInfo.name) then return end

    GameTooltip:SetOwner(btnUI, GC.C.ANCHOR_TOPLEFT)
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

S.mt.__index = BaseAttributeSetter
S.mt.__call = S.SetAttributes

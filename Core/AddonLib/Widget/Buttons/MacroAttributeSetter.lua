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
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local String, WAttr = O.String, O.GlobalConstants.WidgetAttributes
local WC = O.WidgetConstants
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
---@param btnData ProfileButton
function S:SetAttributes(btnUI, btnData)
    btnUI.widget:ResetWidgetAttributes(btnUI)

    local macroInfo = btnData[WAttr.MACRO]
    local icon = WC.C.TEXTURE_EMPTY
    if macroInfo.icon then icon = macroInfo.icon end

    btnUI:SetAttribute(WAttr.TYPE, WAttr.MACRO)
    btnUI:SetAttribute(WAttr.MACRO, macroInfo.index or macroInfo.macroIndex)
    btnUI.widget:SetIcon(icon)

    self:HandleGameTooltipCallbacks(btnUI)
end

---@param btnUI ButtonUI
function S:ShowTooltip(btnUI)
    if not btnUI then return end
    local w = btnUI.widget
    local btnData = w:GetConfig()
    if not btnData then return end
    if String.IsBlank(btnData.type) then return end

    local macroInfo = btnData[WAttr.MACRO]
    local macroLabel = ''

    if not (macroInfo.index or macroInfo.name) then return end

    GameTooltip:SetOwner(btnUI, WC.C.ANCHOR_TOPLEFT)
    local spellId = GetMacroSpell(macroInfo.index)
    if not spellId then
        local _, itemLink = GetMacroItem(macroInfo.index)
        if not itemLink then
            GameTooltip:SetText(sformat(MACRO_WITHOUT_SPELL_FORMAT, macroInfo.name))
            return
        end
        GameTooltip:SetHyperlink(itemLink)
    else
        GameTooltip:AddSpellByID(spellId)
    end
    GameTooltip:AppendText(' ' .. sformat(MACRO_WITH_SPELL_FORMAT, macroInfo.name))
end

S.mt.__index = BaseAttributeSetter
S.mt.__call = S.SetAttributes

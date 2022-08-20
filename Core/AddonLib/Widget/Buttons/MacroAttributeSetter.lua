local GameTooltip, GetMacroSpell = GameTooltip, GetMacroSpell

local LibStub, M, A, P, LSM, W = ABP_WidgetConstants:LibPack()

local PrettyPrint, Table, String, L = ABP_LibGlobals:LibPackUtils()
local sformat = string.format

local BATTR, WAttr = W:LibPack_WidgetAttributes()
local WU = ABP_LibGlobals:LibPack_WidgetUtil()

local TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT = TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT
local MACRO_WITHOUT_SPELL_FORMAT = '%s |cfd5a5a5a(Macro)|r'
local MACRO_WITH_SPELL_FORMAT = '|cfd03c2fc::|r |cfd03c2fc%s|r |cfd5a5a5a(Macro)|r'
---@class MacroAttributeSetter
local _L = LibStub:NewLibrary(M.MacroAttributeSetter)


--- Macro Info:
--- {
---     body = '/run message(GetXPExhaustion())\n',
---     icon = 132096,
---     index = 1,
---     name = '#GetRestedXP',
---     type = 'macro'
--- }
function _L:SetAttributes(btnUI, btnData)
    W:ResetWidgetAttributes(btnUI)

    local macroInfo = btnData[WAttr.MACRO]
    local icon = TEXTURE_EMPTY
    if macroInfo.icon then icon = macroInfo.icon end
    btnUI:SetAttribute(WAttr.TYPE, WAttr.MACRO)
    btnUI:SetAttribute(WAttr.MACRO, macroInfo.index or macroInfo.macroIndex)
    --btnUI:SetNormalTexture(icon)
    --btnUI:SetHighlightTexture(TEXTURE_HIGHLIGHT)
    btnUI.widget:SetTextures(icon)

    btnUI:SetScript("OnEnter", function(_btnUI) self:ShowTooltip(_btnUI)  end)

end

---@param btnUI ButtonUI
function _L:ShowTooltip(btnUI)
    if not btnUI then return end
    local w = btnUI.widget
    local btnData = w:GetConfig()
    if not btnData then return end
    if String.IsBlank(btnData.type) then return end

    local macroInfo = btnData[WAttr.MACRO]
    local macroLabel = ''

    if not (macroInfo.index or macroInfo.name) then return end

    GameTooltip:SetOwner(btnUI, ANCHOR_TOPLEFT)
    local spellId = GetMacroSpell(macroInfo.index)
    if not spellId then
        GameTooltip:SetText(sformat(MACRO_WITHOUT_SPELL_FORMAT, macroInfo.name))
        WU:AddKeybindingInfo(w)
        return
    end
    GameTooltip:AddSpellByID(spellId)
    GameTooltip:AppendText(' ' .. sformat(MACRO_WITH_SPELL_FORMAT, macroInfo.name))

    WU:AddKeybindingInfo(w)
end

_L.mt.__call = _L.SetAttributes


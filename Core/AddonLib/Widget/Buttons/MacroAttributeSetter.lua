local GameTooltip = GameTooltip

local LibStub, M, A, P, LSM, W = ABP_WidgetConstants:LibPack()

local PrettyPrint, Table, String, L = ABP_LibGlobals:LibPackUtils()
local pformat = PrettyPrint.pformat

local BATTR, WAttr = W:LibPack_WidgetAttributes()
local TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT = TEXTURE_HIGHLIGHT, TEXTURE_EMPTY, ANCHOR_TOPLEFT

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
    btnUI:SetNormalTexture(icon)
    btnUI:SetHighlightTexture(TEXTURE_HIGHLIGHT)

    btnUI:SetScript("OnEnter", function(_btnUI) self:ShowTooltip(_btnUI, btnData)  end)

    --Cleanup

end

---@param link table The blizzard `GameTooltip` link
function _L:ShowTooltip(btnUI, btnData)
    if not btnUI or not btnData then return end
    local type = btnData.type
    if not type then return end

    local macroInfo = btnData[WAttr.MACRO]
    GameTooltip:SetOwner(btnUI, ANCHOR_TOPLEFT)
    ABP_PREFIX = '|cfdffffff{{|r|cfd2db9fbActionBarPlus|r|cfdfbeb2d%s|r|cfdffffff}}|r'

    local macroLabel = ' |cfd5a5a5a(Macro)|r'
    GameTooltip:SetText(macroInfo.name .. macroLabel)
end

_L.mt.__call = _L.SetAttributes

-- ## ------------ EVENTS --------------

local function OnMacrosUpdated(frame, event)
    _L:log(10, 'Frame: %s', frame:GetName())
    local buttons = P:GetButtonsByIndex(2)
    --print(ABP:DBG(buttons, 'Buttons #2'))
    --PrettyPrint:_ShowAll()
    --ABP:DBG( ABP_ActionType:GetOtherTypes('ITEM'), 'Other Types')
end

local frame = CreateFrame("Frame", "ABP_MacroAttributeSetterFrame", UIParent)
frame:SetScript("OnEvent", OnMacrosUpdated)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent('UPDATE_MACROS')

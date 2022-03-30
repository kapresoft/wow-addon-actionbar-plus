--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local IsUsableSpell = IsUsableSpell
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
-- LocalLibStub, Module, Assert, Profile, LibSharedMedia, WidgetLibFactory, CommonConstants, LibGlobals
local _, String = ABP_LibGlobals:LibPack_CommonUtils()
local _, NewLibrary = __K_Core:LibPack()

---Creates a global var ABP_WidgetUtil
---@class WidgetUtil
local _L = NewLibrary('WidgetUtil')
---@type WidgetUtil
ABP_WidgetUtil = _L

---@param buttonWidget ButtonUIWidget
function _L:UpdateUsable(buttonWidget)
    local profileButton = buttonWidget:GetConfig()
    local spell = profileButton.spell
    if not spell then return end
    local spellID = spell.id
    if String.IsBlank(spellID) then return end
    local isUsable, notEnoughMana = IsUsableSpell(spellID)
    --self:log('Spell[%s]: IsUsable=%s notEnoughMana=%s', spell.name, isUsable, notEnoughMana)
    -- Enable (1.0, 1.0, 1.0), Disabled (0.5, 0.5, 1.0)
    --_G['ActionbarPlusF4Button1']:GetNormalTexture():SetVertexColor(0.5, 0.5, 1.0)
    local normalTexture = buttonWidget.button:GetNormalTexture()
    if not normalTexture then return end
    -- energy based spells do not use 'notEnoughMana'
    if not isUsable then
        normalTexture:SetVertexColor(0.5, 0.5, 0.5)
    else
        normalTexture:SetVertexColor(1.0, 1.0, 1.0)
    end
end


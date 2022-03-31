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

local highlightTexture = TEXTURE_HIGHLIGHT2
local highlightTextureAlpha = 0.01
local highlightTextureInUseAlpha = 0.35

local IsBlank = String.IsBlank
---Creates a global var ABP_WidgetUtil
---@class WidgetUtil
local _L = NewLibrary('WidgetUtil')
---@type WidgetUtil
ABP_WidgetUtil = _L
--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param buttonWidget ButtonUIWidget
function _L:UpdateUsable(buttonWidget)
    local profileButton = buttonWidget:GetConfig()
    local spell = profileButton.spell
    if not spell then return end
    local spellID = spell.id
    if IsBlank(spellID) then return end
    local isUsable, notEnoughMana = IsUsableSpell(spellID)
    --self:log('Spell[%s]: IsUsable=%s notEnoughMana=%s', spell.name, isUsable, notEnoughMana)
    -- Enable (1.0, 1.0, 1.0), Disabled (0.5, 0.5, 1.0)
    --_G['ActionbarPlusF4Button1']:GetNormalTexture():SetVertexColor(0.5, 0.5, 1.0)
    self:SetSpellUsable(buttonWidget, isUsable)
end

---@param buttonWidget ButtonUIWidget
function _L:SetSpellUsable(buttonWidget, isUsable)
    local normalTexture = buttonWidget.button:GetNormalTexture()
    if not normalTexture then return end
    -- energy based spells do not use 'notEnoughMana'
    if not isUsable then
        normalTexture:SetVertexColor(0.3, 0.3, 0.3)
    else
        normalTexture:SetVertexColor(1.0, 1.0, 1.0)
    end
end

---@param btnWidget ButtonUIWidget
function _L:SetHighlightInUse(btnWidget)
    local hlt = btnWidget.button:GetHighlightTexture()
    hlt:SetDrawLayer(ARTWORK_DRAW_LAYER)
    hlt:SetAlpha(highlightTextureInUseAlpha)
end

function _L:ResetHighlight(btnWidget)
    local btnUI = btnWidget.button
    --btnUI:SetHighlightTexture(btnWidget.highlightTexture.highlight)
    btnUI:SetHighlightTexture(highlightTexture)
    btnUI:GetHighlightTexture():SetDrawLayer(HIGHLIGHT_DRAW_LAYER)
    btnUI:GetHighlightTexture():SetAlpha(highlightTextureAlpha)
end

---@param btnWidget ButtonUIWidget
function _L:SetTextures(btnWidget, icon)
    local btnUI = btnWidget.button

    -- DrawLayer is 'ARTWORK' by default for icons
    btnUI:SetNormalTexture(icon)
    btnUI:GetNormalTexture():SetAlpha(1.0)
    btnUI:GetNormalTexture():SetBlendMode('DISABLE')

    btnUI:SetHighlightTexture(highlightTexture)
    btnUI:GetHighlightTexture():SetDrawLayer(HIGHLIGHT_DRAW_LAYER)
    btnUI:GetHighlightTexture():SetAlpha(highlightTextureAlpha)

    btnUI:SetPushedTexture(icon)
    btnUI:GetPushedTexture():SetAlpha(0.5)
end

---@param profileButton ProfileButton
function _L:IsValidItemProfile(profileButton)
    return not (profileButton == nil
            or profileButton.item == nil
            or IsBlank(profileButton.item.id))
end

---@param profileButton ProfileButton
function _L:IsValidSpellProfile(profileButton)
    return not (profileButton == nil
            or profileButton.spell == nil
            or IsBlank(profileButton.spell.id))
end

---@param profileButton ProfileButton
function _L:IsValidMacroProfile(profileButton)
    return not (profileButton == nil
            or profileButton.macro == nil
            or IsBlank(profileButton.macro.index)
            or IsBlank(profileButton.macro.name))
end

---@param btnWidget ButtonUIWidget
function _L:IsMatchingItemSpell(btnWidget, eventItemSpellID)
    local btnProfile = btnWidget:GetConfig()
    if not self:IsValidItemProfile(btnProfile) then return end
    local _, btnItemSpellId = _API:GetItemSpellInfo(btnProfile.item.id)
    if eventItemSpellID == btnItemSpellId then return true end
    return false
end

---@param btnWidget ButtonUIWidget
function _L:IsMatchingSpell(btnWidget, eventSpellID)
    local btnProfile = btnWidget:GetConfig()
    if not self:IsValidSpellProfile(btnProfile) then return end
    if eventSpellID == btnProfile.spell.id then return true end
    return false
end
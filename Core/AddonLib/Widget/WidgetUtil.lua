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
local P = ABP_Profile

local highlightTexture = TEXTURE_HIGHLIGHT2
local pushedTextureMask = TEXTURE_HIGHLIGHT2
local highlightTextureAlpha = 0.2
local highlightTextureInUseAlpha = 0.5
local pushedTextureInUseAlpha = 0.5

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

function _L:ResetHighlight(btnWidget)
    self:SetHighlightDefault(btnWidget.button)
end

---#### See Also
--- - [UIOBJECT MaskTexture](https://wowpedia.fandom.com/wiki/UIOBJECT_MaskTexture)
--- - [Texture:SetTexture()](https://wowpedia.fandom.com/wiki/API_Texture_SetTexture)
--- - [alphamask](https://wow.tools/files/#search=alphamask&page=5&sort=1&desc=asc)
---@param btnWidget ButtonUIWidget
function _L:SetTextures(btnWidget, icon)
    local btnUI = btnWidget.button

    -- DrawLayer is 'ARTWORK' by default for icons
    btnUI:SetNormalTexture(icon)
    btnUI:GetNormalTexture():SetAlpha(1.0)
    btnUI:GetNormalTexture():SetBlendMode('DISABLE')

    self:SetHighlightDefault(btnUI)

    btnUI:SetPushedTexture(icon)
    local tex = btnUI:GetPushedTexture()
    tex:SetAlpha(pushedTextureInUseAlpha)
    local mask = btnUI:CreateMaskTexture()
    --mask:SetAllPoints(tex)
    mask:SetPoint("TOPLEFT", tex, "TOPLEFT", 2, -2)
    mask:SetPoint("BOTTOMRIGHT", tex, "BOTTOMRIGHT", -2, 2)
    mask:SetTexture(pushedTextureMask, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    tex:AddMaskTexture(mask)
end

---@param btnUI ButtonUI
function _L:SetHighlightDefault(btnUI)
    btnUI:SetHighlightTexture(highlightTexture)
    btnUI:GetHighlightTexture():SetDrawLayer(HIGHLIGHT_DRAW_LAYER)
    btnUI:GetHighlightTexture():SetAlpha(highlightTextureAlpha)
end

---@param btnUI ButtonUI
function _L:SetHighlightInUse(btnUI)
    local hlt = btnUI:GetHighlightTexture()
    hlt:SetDrawLayer(ARTWORK_DRAW_LAYER)
    hlt:SetAlpha(highlightTextureInUseAlpha)
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
---@param profileButton ProfileButton
function _L:IsMatchingItemSpell(profileButton, eventItemSpellID)
    --local profileButton = btnWidget:GetConfig()
    if not self:IsValidItemProfile(profileButton) then return end
    local _, btnItemSpellId = _API:GetItemSpellInfo(profileButton.item.id)
    if eventItemSpellID == btnItemSpellId then return true end
    return false
end

---@param btnWidget ButtonUIWidget
function _L:IsMatchingSpell(profileButton, eventSpellID)
    --local profileButton = btnWidget:GetConfig()
    if not self:IsValidSpellProfile(profileButton) then return end
    if eventSpellID == profileButton.spell.id then return true end
    return false
end

---@param isShown boolean Set to true to show action bar
function _L:SetEnabledActionBarStates(isShown)
    local bars = P:GetBars()
    for frameName, profileData in pairs(bars) do
        if profileData.enabled == true then
            ---@type ButtonFrameFactory
            local f = _G[frameName]
            if f and f.widget then
                ---@type FrameWidget
                local widget = f.widget
                widget:SetGroupState(isShown)
                --self:log('bar: %s shown=%s', frameName, isShown)
            end
        end
    end
end
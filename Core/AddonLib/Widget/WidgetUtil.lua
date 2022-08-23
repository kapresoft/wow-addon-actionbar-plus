--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip, IsUsableSpell, C_Timer = GameTooltip, IsUsableSpell, C_Timer
local GetNumBindings, GetBinding, GameTooltip_AddBlankLinesToTooltip = GetNumBindings, GetBinding, GameTooltip_AddBlankLinesToTooltip
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
-- LocalLibStub, Module, Assert, Profile, LibSharedMedia, WidgetLibFactory, CommonConstants, LibGlobals
local KEYBIND_FORMAT = '\n|cfd03c2fcKeybind ::|r |cfd5a5a5a%s|r'

local _, String = ABP_LibGlobals:LibPack_CommonUtils()
local _, M = ABP_LibGlobals:LibPack()
local _, NewLibrary = __K_Core:LibPack()
local P = ABP_Profile

local highlightTexture = TEXTURE_HIGHLIGHT2
local pushedTextureMask = TEXTURE_HIGHLIGHT2
local highlightTextureAlpha = 0.2
local highlightTextureInUseAlpha = 0.5
local pushedTextureInUseAlpha = 0.5

local IsBlank, IsNotBlank, ParseBindingDetails = String.IsBlank, String.IsNotBlank, String.ParseBindingDetails

local SPELL,ITEM,MACRO = 'spell','item','macro'

---Creates a global var ABP_WidgetUtil
---@class WidgetUtil
local _L = NewLibrary(M.WidgetUtil)
---@type WidgetUtil
ABP_WidgetUtil = _L
--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param buttonWidget ButtonUIWidget
function _L:UpdateUsable(buttonWidget)
    local cd = buttonWidget:GetCooldownInfo()
    if (cd == nil or cd.details == nil or cd.details.spell == nil) then
        return true
    end

    local profileButton = buttonWidget:GetConfig()
    local isUsableSpell = true
    if profileButton.type == SPELL then
        isUsableSpell = self:IsUsableSpell(buttonWidget, cd)
    elseif profileButton.type == MACRO then
        isUsableSpell = self:IsUsableMacro(buttonWidget, cd)
    end
    self:SetSpellUsable(buttonWidget, isUsableSpell)
end

---@param widget ButtonUIWidget
---@param cd CooldownInfo
function _L:IsUsableSpell(widget, cd)
    local spellID = cd.details.spell.id
    if IsBlank(spellID) then return true end
    return IsUsableSpell(spellID)
end


---@param widget ButtonUIWidget
---@param cd CooldownInfo
function _L:IsUsableMacro(widget, cd)
    local spellID = cd.details.spell.id
    if IsBlank(spellID) then return true end
    return IsUsableSpell(spellID)
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

function _L:SetCooldownTextures(btnWidget, icon)
    local btnUI = btnWidget.button
    btnUI:SetNormalTexture(icon)
    btnUI:SetPushedTexture(icon)
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

function _L:SetEnabledActionBarStatesDelayed(isShown, delayInSec)
    local actualDelayInSec = delayInSec
    local showActionBars = isShown == true
    if type(actualDelayInSec) ~= 'number' then actualDelayInSec = delayInSec end
    if actualDelayInSec <= 0 then actualDelayInSec = 1 end
    C_Timer.After(actualDelayInSec, function() self:SetEnabledActionBarStates(showActionBars) end)
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

---@class BindingInfo
local BindingInfoTemplate = {
    name = '<command-name>', btnName = '<button-name',
    category = '<category>', key1 = '<key1>', key1Short = '<key1Short>', key2 = '<key2>'
}

---@return table The binding map with button names as the key
---@param cached boolean Set to false to retrieve new values
function _L:GetBarBindingsMap()
    local barBindingsMap = {}
    local bindCount = GetNumBindings()
    if bindCount <=0 then return nil end
    for i = 1, bindCount do
        local command,cat,key1,key2 = GetBinding(i)
        local bindingDetails = ParseBindingDetails(command)
        if  bindingDetails then
            local key1Short = key1
            if IsNotBlank(key1Short) then
                key1Short = String.replace(key1Short, 'ALT', 'a')
                key1Short = String.replace(key1Short, 'CTRL', 'c')
                key1Short = String.replace(key1Short, 'SHIFT', 's')
                key1Short = String.replace(key1Short, 'META', 'm')
                key1Short = String.ReplaceAllCharButLast(key1Short, '-')
            end
            barBindingsMap[bindingDetails.buttonName] = {
                btnName = bindingDetails.buttonName, category = cat,
                key1 = key1, key1Short = key1Short, key2 = key2,
                details = { action = bindingDetails.action, buttonPressed = bindingDetails.buttonPressed }
            }
        end
    end
    return barBindingsMap
end

---@return BindingInfo
---@param btnName string The button name
function _L:GetBarBindingsXX(btnName)


end

---@return BindingInfo
---@param btnName string The button name
function _L:GetBarBindings(btnName)
    if IsBlank(btnName) then return nil end
    local bindCount = GetNumBindings()
    if bindCount <=0 then return nil end
    for i = 1, bindCount do
        local command,cat,key1,key2 = GetBinding(i)
        local bindingDetails = ParseBindingDetails(command)
        if  bindingDetails and btnName == bindingDetails.buttonName then
            local key1Short = key1
            if IsNotBlank(key1Short) then
                key1Short = String.replace(key1Short, 'ALT', 'a')
                key1Short = String.replace(key1Short, 'CTRL', 'c')
                key1Short = String.replace(key1Short, 'SHIFT', 's')
                key1Short = String.replace(key1Short, 'META', 'm')
                key1Short = String.ReplaceAllCharButLast(key1Short, '-')
            end
            return {
                name = command, btnName = btnName, category = cat,
                key1 = key1, key1Short = key1Short, key2 = key2
            }
        end
    end
    return nil
end

function _L:SetupTooltipKeybindingInfo(tooltip)
    local button = tooltip:GetOwner()
    if not button then return end
    local btnWidget = button.widget
    if btnWidget then
        self:AddKeybindingInfo(btnWidget)
    end
    tooltip:Show()
end

---@param btnWidget ButtonUIWidget
function _L:AddKeybindingInfo(btnWidget)
    if not btnWidget:HasKeybindings() then return end
    GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1)
    local bindings = btnWidget:GetBindings()
    if not bindings.key1 then return end
    GameTooltip:AddDoubleLine('Keybind ::', bindings.key1, 1, 0.5, 0, 0 , 0.5, 1);
end

function _L:AddItemKeybindingInfo(btnWidget)
    if not btnWidget:HasKeybindings() then return end
    local bindings = btnWidget:GetBindings()
    GameTooltip:AppendText(String.format(KEYBIND_FORMAT, bindings.key1))
end

function _L:IsDragKeyDown()
    local pickupAction = GetModifiedClick('PICKUPACTION')
    local isDragKeyDown = pickupAction == 'SHIFT' and IsShiftKeyDown() or pickupAction == 'ALT' and IsAltKeyDown() or pickupAction == 'CTRL' and IsControlKeyDown()
    return isDragKeyDown
end

function _L:HideTooltipDelayed(delayInSec)
    local actualDelayInSec = delayInSec
    if not actualDelayInSec or actualDelayInSec < 0 then
        GameTooltip:Hide()
        return
    end
    C_Timer.After(actualDelayInSec, function() GameTooltip:Hide() end)
end
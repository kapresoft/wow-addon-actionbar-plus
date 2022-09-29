--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetMacroSpell, GetMacroItem, GetItemInfoInstant = GetMacroSpell, GetMacroItem, GetItemInfoInstant
local IsUsableSpell, GetUnitName, C_Timer = IsUsableSpell, GetUnitName, C_Timer

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local tostring, format, strlower, tinsert = tostring, string.format, string.lower, table.insert

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local GC, MX = O.GlobalConstants, O.Mixin
local AO, API = O.AceLibFactory:A(), O.API
local LSM, String = AO.AceLibSharedMedia, O.String

local WAttr = O.GlobalConstants.WidgetAttributes
local SPELL, ITEM, MACRO, MOUNT = WAttr.SPELL, WAttr.ITEM, WAttr.MACRO, WAttr.MOUNT

local C, T = GC.C, GC.Textures
local UNIT = GC.UnitIDAttributes

local noIconTexture = LSM:Fetch(LSM.MediaType.BACKGROUND, "Blizzard Dialog Background")
local IsBlank, IsNotBlank, ParseBindingDetails = String.IsBlank, String.IsNotBlank, String.ParseBindingDetails

local highlightTexture = T.TEXTURE_HIGHLIGHT2
local pushedTextureMask = T.TEXTURE_HIGHLIGHT2
local highlightTextureAlpha = 0.2
local highlightTextureInUseAlpha = 0.5
local pushedTextureInUseAlpha = 0.5
local MIN_BUTTON_SIZE = GC.C.MIN_BUTTON_SIZE_FOR_HIDING_TEXTS

--[[-----------------------------------------------------------------------------
New Instance
self: widget
button: widget.button
-------------------------------------------------------------------------------]]
---@class ButtonMixin : ButtonProfileMixin @ButtonMixin extends ButtonProfileMixin
---@see ButtonUIWidget
local _L = LibStub:NewLibrary(Core.M.ButtonMixin)
local p = _L:GetLogger()
MX:Mixin(_L, O.ButtonProfileMixin)

--[[-----------------------------------------------------------------------------
Instance Methods
-------------------------------------------------------------------------------]]
function _L:Init()
    self:SetButtonLayout()
    self:InitTextures(noIconTexture)
end

function _L:SetButtonLayout()
    --self.placement.rowNum, self.placement.colNum
    local widget = self:W()
    local rowNum, colNum = widget.placement.rowNum, widget.placement.colNum

    ---@type FrameWidget
    local dragFrame = widget.dragFrame
    local barConfig = dragFrame:GetConfig()
    local buttonSize = barConfig.widget.buttonSize
    local buttonPadding = widget.buttonPadding
    local frameStrata = widget.frameStrata
    local button = widget.button
    local dragFrameWidget = widget.dragFrame

    local widthPaddingAdj = dragFrameWidget.padding
    local heightPaddingAdj = dragFrameWidget.padding + dragFrameWidget.dragHandleHeight
    local widthAdj = ((colNum - 1) * buttonSize) + widthPaddingAdj
    local heightAdj = ((rowNum - 1) * buttonSize) + heightPaddingAdj

    button:SetFrameStrata(frameStrata)
    button:SetSize(buttonSize - buttonPadding, buttonSize - buttonPadding)
    button:SetPoint(C.TOPLEFT, dragFrameWidget.frame, C.TOPLEFT, widthAdj, -heightAdj)

    self:Scale(buttonSize)

end

---@param buttonSize number
function _L:Scale(buttonSize)
    local button = self:B()
    button.keybindText.widget:ScaleWithButtonSize(buttonSize)
    self:ScaleCooldownWithButtonSize(buttonSize)
end

---@see "BlizzardInterfaceCode/Interface/SharedXML/SharedFontStyles.xml" for font styles
function _L:ScaleCooldownWithButtonSize(buttonSize)
    local widget = self:W()
    local hideCountdownNumbers = false
    local hideIndexText = false
    local hideKeybindText = false
    local countdownFont
    local profile = widget:GetButtonData():GetProfileData()

    if true == profile.hide_countdown_numbers then hideCountdownNumbers = true end

    if buttonSize > 80 then
        countdownFont = "GameFontNormalHuge4Outline"
    elseif buttonSize >= 70 and buttonSize <= 80 then
        countdownFont = "GameFontNormalHuge3Outline"
    elseif buttonSize >= 40 and buttonSize < 70 then
        countdownFont = "GameFontNormalLargeOutline"
    elseif buttonSize >= MIN_BUTTON_SIZE and buttonSize < 40 then
        countdownFont = "GameFontNormalMed3Outline"
    else
        countdownFont = "GameFontNormalOutline"
        if true == profile.hide_text_on_small_buttons then
            hideIndexText = true
            hideCountdownNumbers = true
            hideKeybindText = true
        end
    end

    widget.cooldown:SetCountdownFont(countdownFont)
    self:HideCountdownNumbers(hideCountdownNumbers)
    self:SetHideIndexText(hideIndexText)
    self:SetHideKeybindText(hideKeybindText)
end

function _L:RefreshTexts()
    local widget = self:W()
    local profile = widget:GetButtonData():GetProfileData()
    self:HideCountdownNumbers(true == profile.hide_countdown_numbers)
    local hideTexts = true == profile.hide_text_on_small_buttons
    if not hideTexts then
        local fw = widget.dragFrame
        local barConf = fw:GetConfig()
        if true == barConf.show_button_index then
            self:SetHideIndexText(false)
        end
        return
    end

    local barConfig = widget.dragFrame:GetConfig()
    local buttonSize = barConfig.widget.buttonSize
    if buttonSize > MIN_BUTTON_SIZE then return end

    self:SetHideKeybindText(hideTexts)
    self:SetHideIndexText(hideTexts)
    if not profile.hide_countdown_numbers then self:HideCountdownNumbers(hideTexts) end
end

---@param state boolean
function _L:HideCountdownNumbers(state)
    self:W().cooldown:SetHideCountdownNumbers(state)
end

---@param state boolean
function _L:SetHideKeybindText(state)
    local widget = self:W()
    if true == state then
        widget.button.keybindText:Hide()
        return
    end

    widget.button.keybindText:Show()
end
---@param state boolean
function _L:SetHideIndexText(state)
    local widget = self:W()
    if true == state then
        widget.button.indexText:Hide()
        return
    end

    widget.button.indexText:Show()
end

---@param target any
function _L:Mixin(target, ...) return MX:MixinOrElseSelf(target, self, ...) end

--- - Call this function once only; otherwise *CRASH* if called N times
--- - [UIOBJECT MaskTexture](https://wowpedia.fandom.com/wiki/UIOBJECT_MaskTexture)
--- - [Texture:SetTexture()](https://wowpedia.fandom.com/wiki/API_Texture_SetTexture)
--- - [alphamask](https://wow.tools/files/#search=alphamask&page=5&sort=1&desc=asc)
---@param btnWidget ButtonUIWidget
function _L:InitTextures(icon)
    local btnUI = self:_Button()

    -- DrawLayer is 'ARTWORK' by default for icons
    btnUI:SetNormalTexture(icon)
    btnUI:GetNormalTexture():SetAlpha(1.0)
    btnUI:GetNormalTexture():SetBlendMode('DISABLE')

    self:SetHighlightDefault(btnUI)

    btnUI:SetPushedTexture(icon)
    local tex = btnUI:GetPushedTexture()
    tex:SetAlpha(pushedTextureInUseAlpha)
    local mask = btnUI:CreateMaskTexture()
    mask:SetPoint(C.TOPLEFT, tex, C.TOPLEFT, 3, -3)
    mask:SetPoint(C.BOTTOMRIGHT, tex, C.BOTTOMRIGHT, -3, 3)
    mask:SetTexture(pushedTextureMask, C.CLAMPTOBLACKADDITIVE, C.CLAMPTOBLACKADDITIVE)
    tex:AddMaskTexture(mask)
end

---@return ButtonUIWidget
function _L:W() return self end
---@return ButtonUI
function _L:B() return self.button end

---@return ButtonUI
function _L:_Button() return self.button end
---@return ButtonUIWidget
function _L:_Widget() return self end
---@return ButtonAttributes
function _L:GetButtonAttributes() return self:W().buttonAttributes end
function _L:GetIndex() return self:W().index end
function _L:GetFrameIndex() return self:W().frameIndex end
function _L:IsParentFrameShown() return self.dragFrame:IsShown() end

function _L:ResetConfig()
    self:_Widget().profile:ResetButtonData(self)
    self:ResetWidgetAttributes()
end

function _L:SetButtonAsEmpty()
    self:ResetConfig()
    self:SetTextureAsEmpty()
end

function _L:Reset()
    self:ResetCooldown()
    self:ClearAllText()
end

function _L:ResetCooldown() self:SetCooldown(0, 0) end
function _L:SetCooldown(start, duration) self.cooldown:SetCooldown(start, duration) end


---@type BindingInfo
function _L:GetBindings()
    return (self.addon.barBindings and self.addon.barBindings[self.buttonName]) or nil
end

---@param text string
function _L:SetText(text)
    if String.IsBlank(text) then text = '' end
    self:_Button().text:SetText(text)
end
---@param state boolean true will show the button index number
function _L:ShowIndex(state)
    local text = ''
    if true == state then text = self:_Widget().index end
    self:_Button().indexText:SetText(text)
    self:RefreshTexts()
end

---@param state boolean true will show the button index number
function _L:ShowKeybindText(state)
    local text = ''
    local button = self:_Button()
    if not self:HasKeybindings() then
        button.keybindText:SetText(text)
        return
    end

    if true == state then
        local bindings = self:GetBindings()
        if bindings and bindings.key1Short then
            text = bindings.key1Short
        end
    end
    button.keybindText:SetText(text)
    self:RefreshTexts()
end

function _L:HasKeybindings()
    local b = self:GetBindings()
    if not b then return false end
    return b and String.IsNotBlank(b.key1)
end
function _L:ClearAllText()
    self:SetText('')
    self.button.keybindText:SetText('')
end

---@return CooldownInfo
function _L:GetCooldownInfo()
    local btnData = self:GetConfig()
    if btnData == nil or String.IsBlank(btnData.type) then return nil end
    local type = btnData.type

    ---@class CooldownInfo
    local cd = {
        type=type,
        start=nil,
        duration=nil,
        enabled=0,
        details = {}
    }
    if type == SPELL then return self:GetSpellCooldown(cd)
    elseif type == MACRO then return self:GetMacroCooldown(cd)
    elseif type == ITEM then return self:GetItemCooldown(cd)
    end
    return nil
end

---@param cd CooldownInfo The cooldown info
---@return SpellCooldown
function _L:GetSpellCooldown(cd)
    local spell = self:GetSpellData()
    if not spell then return nil end
    local spellCD = API:GetSpellCooldown(spell.id, spell)
    if spellCD ~= nil then
        cd.details = spellCD
        cd.start = spellCD.start
        cd.duration = spellCD.duration
        cd.enabled = spellCD.enabled
        return cd
    end
    return nil
end

---@param cd CooldownInfo The cooldown info
---@return ItemCooldown
function _L:GetItemCooldown(cd)
    local item = self:GetItemData()
    if not (item and item.id) then return nil end
    local itemCD = API:GetItemCooldown(item.id, item)
    if itemCD ~= nil then
        cd.details = itemCD
        cd.start = itemCD.start
        cd.duration = itemCD.duration
        cd.enabled = itemCD.enabled
        return cd
    end
    return nil
end

---@param cd CooldownInfo The cooldown info
function _L:GetMacroCooldown(cd)
    local spellCD = self:GetMacroSpellCooldown();

    if spellCD ~= nil then
        cd.details = spellCD
        cd.start = spellCD.start
        cd.duration = spellCD.duration
        cd.enabled = spellCD.enabled
        cd.icon = spellCD.spell.icon
        return cd
    else
        local itemCD = self:GetMacroItemCooldown()
        if itemCD ~= nil then
            cd.details = itemCD
            cd.start = itemCD.start
            cd.duration = itemCD.duration
            cd.enabled = itemCD.enabled
            return cd
        end
    end

    return nil;
end

---@return SpellCooldown
function _L:GetMacroSpellCooldown()
    local macro = self:GetMacroData();
    if not macro then return nil end
    local spellId = GetMacroSpell(macro.index)
    if not spellId then return nil end
    return API:GetSpellCooldown(spellId)
end

---@return number The spellID for macro
function _L:GetMacroSpellId()
    local macro = self:GetMacroData();
    if not macro then return nil end
    return GetMacroSpell(macro.index)
end

---@return ItemCooldown
function _L:GetMacroItemCooldown()
    local macro = self:GetMacroData();
    if not macro then return nil end

    local itemName = GetMacroItem(macro.index)
    if not itemName then return nil end

    local itemID = GetItemInfoInstant(itemName)
    return API:GetItemCooldown(itemID)
end

function _L:ContainsValidAction() return self:_Widget().buttonData:ContainsValidAction() end

function _L:ResetWidgetAttributes()
    local button = self:_Button()
    for _, v in pairs(self:GetButtonAttributes()) do
        button:SetAttribute(v, nil)
    end
end

function _L:UpdateItemState()
    self:ClearAllText()
    local btnData = self:GetConfig()
    if self:invalidButtonData(btnData, ITEM) then return end
    local itemID = btnData.item.id
    local itemInfo = API:GetItemInfo(itemID)
    if itemInfo == nil then return end
    if API:IsToyItem(itemID) then self:SetSpellUsable(true); return end

    local stackCount = itemInfo.stackCount or 1
    local count = itemInfo.count
    btnData.item.count = count
    btnData.item.stackCount = stackCount
    if stackCount > 1 then self:SetText(btnData.item.count) end
    if count <= 0 then self:SetSpellUsable(false)
    else self:SetSpellUsable(true) end
end

function _L:UpdateUsable()
    local cd = self:GetCooldownInfo()
    if (cd == nil or cd.details == nil or cd.details.spell == nil) then
        return true
    end

    local c = self:GetConfig()
    local isUsableSpell = true
    if c.type == SPELL then
        isUsableSpell = self:IsUsableSpell(cd)
    elseif c.type == MACRO then
        -- TODO:
        isUsableSpell = self:IsUsableMacro(cd)
    end
    -- TODO:
    self:SetSpellUsable(isUsableSpell)
end

function _L:UpdateState()
    self:UpdateCooldown()
    self:UpdateItemState()
    self:UpdateUsable()
    self:UpdateRangeIndicator()
end
function _L:UpdateStateDelayed(inSeconds) C_Timer.After(inSeconds, function() self:UpdateState() end) end
function _L:UpdateCooldown()
    local cd = self:GetCooldownInfo()
    if not cd or cd.enabled == 0 then return end
    -- Instant cast spells have zero duration, skip
    if cd.duration <= 0 then
        self:ResetCooldown()
        return
    end
    self:SetCooldown(cd.start, cd.duration)
end
function _L:UpdateCooldownDelayed(inSeconds) C_Timer.After(inSeconds, function() self:UpdateCooldown() end) end


---@return ActionBarInfo
function _L:GetActionbarInfo()
    local index = self.index
    local dragFrame = self.dragFrame;
    local frameName = dragFrame:GetName()
    local btnName = format('%sButton%s', frameName, tostring(index))

    ---@class ActionBarInfo
    local info = {
        name = frameName, index = dragFrame:GetFrameIndex(),
        button = { name = btnName, index = index },
    }
    return info
end

function _L:ClearHighlight() self:_Button():SetHighlightTexture(nil) end
function _L:ResetHighlight() self:SetHighlightDefault() end
function _L:SetTextureAsEmpty() self:_Widget():SetIcon(noIconTexture) end
function _L:SetCooldownTextures(icon)
    local btnUI = self:_Button()
    btnUI:SetNormalTexture(icon)
    btnUI:SetPushedTexture(icon)
end
---Typically used when casting spells that take longer than GCD
function _L:SetHighlightInUse()
    local hlt = self:B():GetHighlightTexture()
    --highlight texture could be nil if action_button_mouseover_glow is disabled
    if not hlt then return end
    hlt:SetDrawLayer(C.ARTWORK_DRAW_LAYER)
    hlt:SetAlpha(highlightTextureInUseAlpha)
end
function _L:SetHighlightDefault() self:SetHighlightEnabled(self:P():IsActionButtonMouseoverGlowEnabled()) end

function _L:RefreshHighlightEnabled()
    local profile = self:W():GetButtonData():GetProfileData()
    self:SetHighlightEnabled(true == profile.action_button_mouseover_glow)
end

---@param state boolean true, to enable highlight
function _L:SetHighlightEnabled(state)
    local btnUI = self:B()
    if state == true then
        btnUI:SetHighlightTexture(highlightTexture)
        btnUI:GetHighlightTexture():SetDrawLayer(GC.C.HIGHLIGHT_DRAW_LAYER)
        btnUI:GetHighlightTexture():SetAlpha(highlightTextureAlpha)
        return
    end
    btnUI:SetHighlightTexture(nil)
end


---@param spellID string The spellID to match
---@param optionalBtnConf ProfileButton
---@return boolean
function _L:IsMatchingItemSpellID(spellID, optionalBtnConf)
    --return WU:IsMatchingItemSpellID(spellID, optionalProfileButton or self:GetConfig())
    --local profileButton = btnWidget:GetConfig()
    if not self:IsValidItemProfile(optionalBtnConf) then return end
    local _, btnItemSpellId = API:GetItemSpellInfo(optionalBtnConf.item.id)
    if spellID == btnItemSpellId then return true end
    return false
end

---@param spellID string The spellID to match
---@param optionalBtnConf ProfileButton
---@return boolean
function _L:IsMatchingSpellID(spellID, optionalBtnConf)
    --return WU:IsMatchingSpellID(spellID, optionalProfileButton or self:GetConfig())
    local buttonData = optionalBtnConf or self:GetConfig()
    local w = self:W()
    if w:IsSpell() then
        return spellID == buttonData.spell.id
    elseif w:IsItem() then
        return w:IsMatchingItemSpellID(spellID, buttonData)
    elseif w:IsMount() then
        return spellID == buttonData.mount.spell.id
    end
    return false
end

---@param widget ButtonUIWidget
---@param spellName string The spell name
---@param buttonData ProfileButton
function _L:IsMatchingSpellName(spellName, buttonData)
    local s = buttonData or self:GetConfig()
    if not (s.spell and s.spell.name) then return false end
    if not (s and spellName == s.spell.name) then return false end
    return true
end

---@param spellID string
---@param optionalProfileButton ProfileButton
function _L:IsMatchingMacroSpellID(spellID, optionalProfileButton)
    optionalProfileButton = optionalProfileButton or self:GetConfig()
    if not self:IsValidMacroProfile(optionalProfileButton) then return end
    local macroSpellId =  GetMacroSpell(optionalProfileButton.macro.index)
    if not macroSpellId then return false end
    if spellID == macroSpellId then return true end
    return false
end

---@param spellID string The spellID to match
---@return boolean
function _L:IsMatchingMacroOrSpell(spellID)
    ---@type ProfileButton
    local conf = self:GetConfig()
    if not conf and (conf.spell or conf.macro) then return false end
    if self:IsConfigOfType(conf, SPELL) then
        return spellID == conf.spell.id
    elseif self:IsConfigOfType(conf, MACRO) and conf.macro.index then
        local macroSpellId =  GetMacroSpell(conf.macro.index)
        return spellID == macroSpellId
    end

    return false;
end

---@param hasTarget boolean Player has a target
function _L:UpdateRangeIndicatorWithShowKeybindOn(hasTarget)
    -- if no target, do nothing and return
    local widget = self:_Widget()
    local fs = widget.button.keybindText
    if not hasTarget then fs.widget:SetVertexColorNormal(); return end
    if widget:IsMacro() then return end
    if not widget:HasKeybindings() then fs.widget:SetTextWithRangeIndicator() end

    -- else if in range, color is "white"
    local inRange = API:IsActionInRange(widget:GetConfig(), UNIT.TARGET)
    --self:log('%s in-range: %s', widget:GetName(), tostring(inRange))
    fs.widget:SetVertexColorNormal()
    if inRange == false then
        fs.widget:SetVertexColorOutOfRange()
    elseif inRange == nil then
        -- spells, items, macros where range is not applicable
        if not widget:HasKeybindings() then fs.widget:ClearText() end
    end
end

---@param hasTarget boolean Player has a target
function _L:UpdateRangeIndicatorWithShowKeybindOff(hasTarget)
    -- if no target, clear text and return
    local fs = self:_Button().keybindText
    if not hasTarget then
        fs.widget:ClearText()
        fs.widget:SetVertexColorNormal()
        return
    end

    local widget = self:_Widget()
    if widget:IsMacro() then return end

    -- has target, set text as range indicator
    fs.widget:SetTextWithRangeIndicator()

    local inRange = API:IsActionInRange(widget:GetConfig(), UNIT.TARGET)
    --self:log('%s in-range: %s', widget:GetName(), tostring(inRange))
    fs.widget:SetVertexColorNormal()
    if inRange == false then
        fs.widget:SetVertexColorOutOfRange()
    elseif inRange == nil then
        fs.widget:ClearText()
    end
end

function _L:UpdateRangeIndicator()
    if not self:ContainsValidAction() then return end
    local widget = self:_Widget()
    local configIsShowKeybindText = widget.dragFrame:IsShowKeybindText()
    local hasTarget = GetUnitName(UNIT.TARGET) ~= null
    widget:ShowKeybindText(configIsShowKeybindText)

    if configIsShowKeybindText == true then
        return self:UpdateRangeIndicatorWithShowKeybindOn(hasTarget)
    end
    self:UpdateRangeIndicatorWithShowKeybindOff(hasTarget)
end

function _L:SetSpellUsable(isUsable)
    local normalTexture = self:_Button():GetNormalTexture()
    if not normalTexture then return end
    -- energy based spells do not use 'notEnoughMana'
    if not isUsable then
        normalTexture:SetVertexColor(0.3, 0.3, 0.3)
    else
        normalTexture:SetVertexColor(1.0, 1.0, 1.0)
    end
end

---@param cd CooldownInfo
function _L:IsUsableSpell(cd)
    local spellID = cd.details.spell.id
    -- why true by default?
    if IsBlank(spellID) then return true end
    return IsUsableSpell(spellID)
end

---@param cd CooldownInfo
function _L:IsUsableMacro(cd)
    local spellID = cd.details.spell.id
    if IsBlank(spellID) then return true end
    return IsUsableSpell(spellID)
end

---@param icon string Blizzard Icon
function _L:SetIcon(icon)
    self:_Button():SetNormalTexture(icon)
    self:_Button():SetPushedTexture(icon)
end

---@param buttonData ProfileButton
function _L:IsValidItemProfile(buttonData)
    return not (buttonData == nil or buttonData.item == nil
            or IsBlank(buttonData.item.id))
end

---@param buttonData ProfileButton
function _L:IsValidSpellProfile(buttonData)
    return not (buttonData == nil or buttonData.spell == nil
            or IsBlank(buttonData.spell.id))
end

---@param buttonData ProfileButton
function _L:IsValidMacroProfile(buttonData)
    return not (buttonData == nil or buttonData.macro == nil
            or IsBlank(buttonData.macro.index)
            or IsBlank(buttonData.macro.name))
end

---@return ButtonData
function _L:GetButtonData() return self:W().buttonData end
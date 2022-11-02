--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetMacroSpell, GetMacroItem, GetItemInfoInstant = GetMacroSpell, GetMacroItem, GetItemInfoInstant
local IsUsableSpell, IsUsableItem, GetUnitName, C_Timer = IsUsableSpell, IsUsableItem, GetUnitName, C_Timer

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
local IsBlank, IsNotBlank, ParseBindingDetails = String.IsBlank, String.IsNotBlank, String.ParseBindingDetails

local WAttr = O.GlobalConstants.WidgetAttributes
local SPELL, ITEM, MACRO, MOUNT = WAttr.SPELL, WAttr.ITEM, WAttr.MACRO, WAttr.MOUNT

local C, T = GC.C, GC.Textures
local UNIT = GC.UnitIDAttributes

local emptyTexture = GC.Textures.TEXTURE_EMPTY
local emptyGridTexture = GC.Textures.TEXTURE_EMPTY_GRID
local highlightTexture = T.TEXTURE_HIGHLIGHT2
local pushedTextureMask = T.TEXTURE_HIGHLIGHT2

local highlightTextureAlpha = 0.2
local highlightTextureInUseAlpha = 0.5
local pushedTextureInUseAlpha = 0.5
local nonEmptySlotAlpha = 1.0
local showEmptyGridAlpha = 0.6
local MIN_BUTTON_SIZE = GC.C.MIN_BUTTON_SIZE_FOR_HIDING_TEXTS

--[[-----------------------------------------------------------------------------
New Instance
self: widget
button: widget.button
-------------------------------------------------------------------------------]]
---@class ButtonMixin : ButtonProfileMixin @ButtonMixin extends ButtonProfileMixin
---@see ButtonUIWidget
local L = LibStub:NewLibrary(Core.M.ButtonMixin)
---@type LoggerTemplate
local p = L:GetLogger()

MX:Mixin(L, O.ButtonProfileMixin)

--[[-----------------------------------------------------------------------------
Instance Methods
-------------------------------------------------------------------------------]]
function L:Init()
    self:SetButtonLayout()
    self:InitTextures(emptyTexture)
    if self:IsEmpty() then self:SetTextureAsEmpty() end
end

function L:SetButtonLayout()
    --self.placement.rowNum, self.placement.colNum
    local widget = self:W()
    local rowNum, colNum = widget.placement.rowNum, widget.placement.colNum

    ---@type FrameWidget
    local dragFrame = widget.dragFrame
    local barConfig = dragFrame:GetConfig()
    local buttonSize = barConfig.widget.buttonSize
    local buttonPadding = widget.buttonPadding
    local frameStrata = widget.frameStrata
    local frameLevel = widget.frameLevel
    local button = widget.button
    local dragFrameWidget = widget.dragFrame

    local widthPaddingAdj = dragFrameWidget.padding
    local heightPaddingAdj = dragFrameWidget.padding + dragFrameWidget.dragHandleHeight
    local widthAdj = ((colNum - 1) * buttonSize) + widthPaddingAdj
    local heightAdj = ((rowNum - 1) * buttonSize) + heightPaddingAdj

    button:SetFrameStrata(frameStrata)
    button:SetFrameLevel(frameLevel)
    button:SetSize(buttonSize - buttonPadding, buttonSize - buttonPadding)
    button:SetPoint(C.TOPLEFT, dragFrameWidget.frame, C.TOPLEFT, widthAdj, -heightAdj)

    --local index = widget.index
    --if index == 1 then
    --    button:SetPoint(C.TOPLEFT, dragFrameWidget.frame, C.TOPLEFT, widthAdj, -heightAdj)
    --end
    --local previous = widget.dragFrame:GetName() .. 'Button' .. (index - 1)
    --local pb = _G[previous]
    --if pb and index > 1 then
    --    button:SetPoint('TOPLEFT', pb, 'TOPRIGHT', 0, 0)
    --end

    self:Scale(buttonSize)

end

---@param buttonSize number
function L:Scale(buttonSize)
    local button = self:B()
    button.keybindText.widget:ScaleWithButtonSize(buttonSize)
    --todo next: move to a ButtonScaleMixin?
    self:ScaleButtonTextsWithButtonSize(buttonSize)
    self:ScaleItemCountOffset(buttonSize)
end

---@param buttonSize number
function L:ScaleItemCountOffset(buttonSize)
    local offsetX = -2
    local offsetY = 7
    local scaleFactorX = 50
    local scaleFactorY = 100
    offsetX = (buttonSize/100) - (offsetX + buttonSize/15)
    local scaleXOffset = buttonSize/scaleFactorX * offsetX
    local scaleYOffset = buttonSize/scaleFactorY * offsetY
    self:B().text:SetPoint("BOTTOMRIGHT", scaleXOffset, scaleYOffset)
end

---@see "BlizzardInterfaceCode/Interface/SharedXML/SharedFontStyles.xml" for font styles
---@param buttonSize number
function L:ScaleButtonTextsWithButtonSize(buttonSize)
    local widget = self:W()
    local hideItemCountText = false
    local hideCountdownNumbers = false
    local hideIndexText = false
    local hideKeybindText = false
    local countdownFont
    local itemCountFont
    local profile = widget:GetButtonData():GetProfileConfig()
    local textUI = widget.button.text
    local itemCountFontHeight = textUI.textDefaultFontHeight

    if true == profile.hide_countdown_numbers then hideCountdownNumbers = true end

    if buttonSize > 80 then
        itemCountFont = "GameFontNormalOutline"
        countdownFont = "GameFontNormalHuge4Outline"
        itemCountFontHeight = textUI.textDefaultFontHeight
    elseif buttonSize >= 70 and buttonSize <= 80 then
        itemCountFontHeight = 12
        countdownFont = "GameFontNormalHuge3Outline"
    elseif buttonSize >= 40 and buttonSize < 70 then
        itemCountFontHeight = 11
        countdownFont = "GameFontNormalLargeOutline"
    elseif buttonSize >= MIN_BUTTON_SIZE and buttonSize < 40 then
        itemCountFontHeight = 10
        countdownFont = "GameFontNormalMed3Outline"
    else
        countdownFont = "GameFontNormalOutline"
        itemCountFontHeight = 9

        if true == profile.hide_text_on_small_buttons then
            hideItemCountText = true
            hideIndexText = true
            hideCountdownNumbers = true
            hideKeybindText = true
        end

    end
    local fontName, _, fontAttr = textUI:GetFont()
    textUI:SetFont(fontName, itemCountFontHeight, fontAttr)

    widget.cooldown:SetCountdownFont(countdownFont)
    self:HideCountdownNumbers(hideCountdownNumbers)
    self:SetHideItemCountText(hideItemCountText)
    self:SetHideIndexText(hideIndexText)
    self:SetHideKeybindText(hideKeybindText)

end

function L:RefreshTexts()
    local widget = self:W()
    local profile = widget:GetButtonData():GetProfileConfig()
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
function L:HideCountdownNumbers(state)
    self:W().cooldown:SetHideCountdownNumbers(state)
end

---This is the item count text
---@param state boolean
function L:SetHideItemCountText(state)
    local btn = self:B()
    if true == state then
        btn.text:Hide()
        return
    end

    btn.text:Show()
end

---@param state boolean
function L:SetHideKeybindText(state)
    local btn = self:B()
    if true == state then
        btn.keybindText:Hide()
        return
    end

    btn.keybindText:Show()
end
---@param state boolean
function L:SetHideIndexText(state)
    local btn = self:B()
    if true == state then
        btn.indexText:Hide()
        return
    end

    btn.indexText:Show()
end

---@param btn _Button
---@param texture _Texture
---@param texturePath string
local function CreateMask(btn, texture, texturePath)
    local mask = btn:CreateMaskTexture()
    local topx, topy = 1, -1
    local botx, boty = -1, 1
    mask:SetPoint(C.TOPLEFT, texture, C.TOPLEFT, topx, topy)
    mask:SetPoint(C.BOTTOMRIGHT, texture, C.BOTTOMRIGHT, botx, boty)
    mask:SetTexture(texturePath, C.CLAMPTOBLACKADDITIVE, C.CLAMPTOBLACKADDITIVE)
    texture.mask = mask
    texture:AddMaskTexture(mask)
    return mask
end

---@param target any
function L:Mixin(target, ...) return MX:MixinOrElseSelf(target, self, ...) end

--- - Call this function once only; otherwise *CRASH* if called N times
--- - [UIOBJECT MaskTexture](https://wowpedia.fandom.com/wiki/UIOBJECT_MaskTexture)
--- - [Texture:SetTexture()](https://wowpedia.fandom.com/wiki/API_Texture_SetTexture)
--- - [alphamask](https://wow.tools/files/#search=alphamask&page=5&sort=1&desc=asc)
---@param icon string The icon texture path
function L:InitTextures(icon)
    local btnUI = self:B()

    -- DrawLayer is 'ARTWORK' by default for icons
    btnUI:SetNormalTexture(icon)
    --Blend mode "Blend" gets rid of the dark edges in buttons
    btnUI:GetNormalTexture():SetBlendMode(GC.BlendMode.BLEND)

    self:SetHighlightDefault(btnUI)
    btnUI:SetPushedTexture(icon)
    local tex = btnUI:GetPushedTexture()
    CreateMask(btnUI, tex, pushedTextureMask)

    tex:SetAlpha(pushedTextureInUseAlpha)
    local mask = btnUI:CreateMaskTexture()
    mask:SetPoint(C.TOPLEFT, tex, C.TOPLEFT, 3, -3)
    mask:SetPoint(C.BOTTOMRIGHT, tex, C.BOTTOMRIGHT, -3, 3)
    mask:SetTexture(pushedTextureMask, C.CLAMPTOBLACKADDITIVE, C.CLAMPTOBLACKADDITIVE)
    tex:AddMaskTexture(mask)

    local hTexture = btnUI:GetHighlightTexture()
    if hTexture and not hTexture.mask then
        hTexture.mask = CreateMask(btnUI, hTexture, GC.Textures.TEXTURE_BUTTON_HILIGHT_SQUARE_BLUE)
    end
end

---@return ButtonUIWidget
function L:W() return self end
---@return ButtonUI
function L:B() return self.button end

---@return ButtonUI
function L:B() return self.button end
---@return ButtonUIWidget
function L:W() return self end
---@return ButtonAttributes
function L:GetButtonAttributes() return self:W().buttonAttributes end
function L:GetIndex() return self:W().index end
function L:GetFrameIndex() return self:W().frameIndex end
---Only used for prefixing logs
function L:N() return "F" .. self.frameIndex .. "_B" .. self.index end
function L:IsParentFrameShown() return self.dragFrame:IsShown() end

function L:ResetConfig()
    self:W().profile:ResetButtonData(self)
    self:ResetWidgetAttributes()
end

function L:SetButtonAsEmpty()
    self:ResetConfig()
    self:SetTextureAsEmpty()
end

function L:Reset()
    self:ResetCooldown()
    self:ClearAllText()
end

function L:ResetCooldown() self:SetCooldown(0, 0) end
function L:SetCooldown(start, duration) self.cooldown:SetCooldown(start, duration) end


---@type BindingInfo
function L:GetBindings()
    return (self.addon.barBindings and self.addon.barBindings[self.buttonName]) or nil
end

---@param text string
function L:SetText(text)
    if String.IsBlank(text) then text = '' end
    self:B().text:SetText(text)
end
---@param state boolean true will show the button index number
function L:ShowIndex(state)
    local text = ''
    if true == state then text = self:W().index end
    self:B().indexText:SetText(text)
    self:RefreshTexts()
end

---@param state boolean true will show the button index number
function L:ShowKeybindText(state)
    local text = ''
    local button = self:B()
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

function L:HasKeybindings()
    local b = self:GetBindings()
    if not b then return false end
    return b and String.IsNotBlank(b.key1)
end
function L:ClearAllText()
    self:SetText('')
    self.button.keybindText:SetText('')
end

---@return CooldownInfo
function L:GetCooldownInfo()
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
function L:GetSpellCooldown(cd)
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
function L:GetItemCooldown(cd)
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
function L:GetMacroCooldown(cd)
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
function L:GetMacroSpellCooldown()
    local macro = self:GetMacroData();
    if not macro then return nil end
    local spellId = GetMacroSpell(macro.index)
    if not spellId then return nil end
    return API:GetSpellCooldown(spellId)
end

---@return number The spellID for macro
function L:GetMacroSpellId()
    local macro = self:GetMacroData();
    if not macro then return nil end
    return GetMacroSpell(macro.index)
end

---@return ItemCooldown
function L:GetMacroItemCooldown()
    local macro = self:GetMacroData();
    if not macro then return nil end

    local itemName = GetMacroItem(macro.index)
    if not itemName then return nil end

    local itemID = GetItemInfoInstant(itemName)
    return API:GetItemCooldown(itemID)
end

function L:ContainsValidAction() return self:W().buttonData:ContainsValidAction() end

function L:ResetWidgetAttributes()
    local button = self:B()
    for _, v in pairs(self:GetButtonAttributes()) do
        button:SetAttribute(v, nil)
    end
end

function L:UpdateItemState()
    self:ClearAllText()
    local btnData = self:GetConfig()
    if self:invalidButtonData(btnData, ITEM) then return end
    local itemID = btnData.item.id
    local itemInfo = API:GetItemInfo(itemID)
    if itemInfo == nil then return end
    if API:IsToyItem(itemID) then self:SetActionUsable(true); return end

    local stackCount = itemInfo.stackCount or 1
    local count = itemInfo.count
    btnData.item.count = count
    btnData.item.stackCount = stackCount
    if stackCount > 1 then self:SetText(btnData.item.count) end
    if count <= 0 then self:SetActionUsable(false)
    else self:SetActionUsable(self:IsUsableItem(itemID)) end
    return
end

function L:UpdateUsable()
    local cd = self:GetCooldownInfo()
    if (cd == nil or cd.details == nil or cd.details.spell == nil) then
        if self:IsCompanion() then self:SetActionUsable(true) end
        return
    end

    local c = self:GetConfig()
    local isUsableSpell = true
    if c.type == SPELL then
        isUsableSpell = self:IsUsableSpell(cd)
    elseif c.type == MACRO then
        isUsableSpell = self:IsUsableMacro(cd)
    end
    self:SetActionUsable(isUsableSpell)
end

function L:UpdateState()
    self:UpdateCooldown()
    self:UpdateItemState()
    self:UpdateUsable()
    self:UpdateRangeIndicator()
    self:SetHighlightDefault()
    self:SetNormalIconAlphaDefault()
    self:UpdateKeybindTextState()
end

--Dynamic toggling of keybind text for
--the actionbar grid event
function L:UpdateKeybindTextState()
    if not self:GetButtonData():IsShowKeybindText() then
        self:B().keybindText:Hide()
        return
    end

    if self:IsEmpty() then
        if self:GetButtonData():IsShowEmptyButtons() then
            self:B().keybindText:Show()
        else
            self:B().keybindText:Hide()
        end
        return
    end

    if not self:IsEmpty() then self:B().keybindText:Show() end
end

function L:UpdateStateDelayed(inSeconds) C_Timer.After(inSeconds, function() self:UpdateState() end) end
function L:UpdateCooldown()
    local cd = self:GetCooldownInfo()
    if not cd or cd.enabled == 0 then return end
    -- Instant cast spells have zero duration, skip
    if cd.duration <= 0 then
        self:ResetCooldown()
        return
    end
    self:SetCooldown(cd.start, cd.duration)
end
function L:UpdateCooldownDelayed(inSeconds) C_Timer.After(inSeconds, function() self:UpdateCooldown() end) end


---@return ActionBarInfo
function L:GetActionbarInfo()
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

function L:ClearHighlight() self:B():SetHighlightTexture(nil) end
function L:ResetHighlight() self:SetHighlightDefault() end

---@param texture string
function L:SetNormalTexture(texture) self:B():SetNormalTexture(texture) end
---@param texture string
function L:SetPushedTexture(texture) self:B():SetPushedTexture(texture) end
---@param texture string
function L:SetHighlightTexture(texture) self:B():SetHighlightTexture(texture) end

function L:SetTextureAsEmpty()
    self:SetNormalTexture(emptyTexture)
    self:SetPushedTexture(nil)
    self:SetHighlightTexture(nil)
    self:SetNormalIconAlphaAsEmpty()
    self:SetVertexColorNormal()
end

function L:SetNormalIconAlphaAsEmpty()
    local alpha = showEmptyGridAlpha
    if true ~= self:W():GetButtonData():IsShowEmptyButtons() then alpha = 0 end
    self:SetNormalIconAlpha(alpha)
end

---@param alpha number 0.0 to 1.0
function L:SetNormalIconAlpha(alpha) self:B():GetNormalTexture():SetAlpha(alpha or 1.0) end
function L:SetVertexColorNormal() self:B():GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0) end

function L:SetNormalIconAlphaDefault()
    if self:IsEmpty() then
        self:SetNormalIconAlphaAsEmpty()
        return
    end
    self:SetNormalIconAlpha(nonEmptySlotAlpha)
end

function L:SetPushedTextureDisabled() self:B():SetPushedTexture(nil) end

---This is used when an action button starts dragging to highlight other drag targets (empty slots).
function L:ShowEmptyGrid()
    if not self:IsEmpty() then return end
    self:SetNormalTexture(emptyTexture)
    self:SetHighlightEmptyButtonEnabled(false)
end

function L:ShowEmptyGridEvent()
    if not self:IsEmpty() then return end
    self:SetButtonAsEmpty()
    self:ShowEmptyGrid()
    self:ShowKeybindText(true)

    if not self:GetButtonData():IsShowKeybindText() then
        self:B().keybindText:Hide()
    elseif self:IsEmpty() then
        self:B().keybindText:Show()
    end
end

function L:HideEmptyGridEvent()
    if not self:IsEmpty() then return end
    self:SetTextureAsEmpty()
    self:SetHighlightEmptyButtonEnabled(true)
    self:SetNormalTexture(emptyTexture)
    self:SetNormalIconAlphaAsEmpty()
    if self:IsEmpty() and not self:GetButtonData():IsShowEmptyButtons() then
        self:B().keybindText:Hide()
    end
end

function L:SetCooldownTextures(icon)
    local btnUI = self:B()
    btnUI:SetNormalTexture(icon)
    btnUI:SetPushedTexture(icon)
end

function L:SetButtonStateNormal() self:B():SetButtonState('NORMAL') end
function L:SetButtonStatePushed() self:B():SetButtonState('PUSHED') end

---Typically used when casting spells that take longer than GCD
function L: SetHighlightInUse()
    --todo next: action_button_mouseover_glow is different from highlight in use
    --this feature is being masked by action_button_mouseover_glow
    --need to highlight an action being in-use state regardless
    local btn = self:B()
    local hltTexture = btn:GetHighlightTexture()
    --highlight texture could be nil if action_button_mouseover_glow is disabled
    if not hltTexture then return end
    hltTexture:SetDrawLayer(C.ARTWORK_DRAW_LAYER)
    hltTexture:SetAlpha(highlightTextureInUseAlpha)

    if hltTexture and not hltTexture.mask then
        -- so that we can show a indicator that a spell is being casted
        hltTexture.mask = CreateMask(btn, hltTexture, GC.Textures.TEXTURE_BUTTON_HILIGHT_SQUARE_BLUE)
    end
end
function L:SetHighlightDefault()
    if self:IsEmpty() then return end
    self:SetHighlightEnabled(self:P():IsActionButtonMouseoverGlowEnabled())
end

function L:RefreshHighlightEnabled()
    local profile = self:W():GetButtonData():GetProfileConfig()
    self:SetHighlightEnabled(true == profile.action_button_mouseover_glow)
end

---@param state boolean true, to enable highlight
function L:SetHighlightEnabled(state)
    local btnUI = self:B()
    if state == true then
        btnUI:SetHighlightTexture(highlightTexture)
        btnUI:GetHighlightTexture():SetBlendMode(GC.BlendMode.ADD)
        btnUI:GetHighlightTexture():SetDrawLayer(GC.DrawLayer.HIGHLIGHT)
        btnUI:GetHighlightTexture():SetAlpha(highlightTextureAlpha)
        return
    end
    btnUI:SetHighlightTexture(nil)
end

---This is used for mouseover when dragging a cursor
---to highlight an empty slot
function L:SetHighlightEmptyButtonEnabled(state)
    if not self:IsEmpty() then return end
    if true == state then
        self:SetNormalTexture(emptyGridTexture)
        self:SetNormalIconAlpha(showEmptyGridAlpha)
        return
    end
    self:SetNormalTexture(emptyTexture)
    self:SetNormalIconAlpha(showEmptyGridAlpha)
end

---@param spellID string The spellID to match
---@param optionalBtnConf Profile_Button
---@return boolean
function L:IsMatchingItemSpellID(spellID, optionalBtnConf)
    if not self:IsValidItemProfile(optionalBtnConf) then return end
    local _, btnItemSpellId = API:GetItemSpellInfo(optionalBtnConf.item.id)
    if spellID == btnItemSpellId then return true end
    return false
end

---@param spellID string The spellID to match
---@param optionalBtnConf Profile_Button
---@return boolean
function L:IsMatchingSpellID(spellID, optionalBtnConf)
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
---@param buttonData Profile_Button
function L:IsMatchingSpellName(spellName, buttonData)
    local s = buttonData or self:GetConfig()
    if not (s.spell and s.spell.name) then return false end
    if not (s and spellName == s.spell.name) then return false end
    return true
end

---@param spellID string
---@param optionalProfileButton Profile_Button
function L:IsMatchingMacroSpellID(spellID, optionalProfileButton)
    optionalProfileButton = optionalProfileButton or self:GetConfig()
    if not self:IsValidMacroProfile(optionalProfileButton) then return end
    local macroSpellId =  GetMacroSpell(optionalProfileButton.macro.index)
    if not macroSpellId then return false end
    if spellID == macroSpellId then return true end
    return false
end

---@param spellID string The spellID to match
---@return boolean
function L:IsMatchingMacroOrSpell(spellID)
    ---@type Profile_Button
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
function L:UpdateRangeIndicatorWithShowKeybindOn(hasTarget)
    local show = self:W().frameIndex == 1 and (self:W().index == 1 or self:W().index == 2)
    --if show then p:log('UpdateRangeIndicatorWithShowKeybindOn: %s', hasTarget) end
    -- if no target, do nothing and return
    local widget = self:W()
    local fs = widget.button.keybindText
    if not hasTarget then fs.widget:SetVertexColorNormal(); return end

    if not widget:HasKeybindings() then fs.widget:SetTextWithRangeIndicator() end

    -- else if in range, color is "white"
    local inRange = API:IsActionInRange(widget:GetConfig(), UNIT.TARGET)
    --if show then p:log('Target InRange: %s', tostring(inRange)) end
    --p:log('%s in-range: %s', widget:GetName(), tostring(inRange))
    fs.widget:SetVertexColorNormal()
    if inRange == false then
        fs.widget:SetVertexColorOutOfRange()
    elseif inRange == nil then
        -- spells, items, macros where range is not applicable
        if not widget:HasKeybindings() then fs.widget:ClearText() end
    end
end

---@param hasTarget boolean Player has a target
function L:UpdateRangeIndicatorWithShowKeybindOff(hasTarget)
    local show = self:W().frameIndex == 1 and self:W().index == 1
    --if show then p:log('UpdateRangeIndicatorWithShowKeybindOff: %s', hasTarget) end
    -- if no target, clear text and return
    local fs = self:B().keybindText
    if not hasTarget then
        fs.widget:ClearText()
        fs.widget:SetVertexColorNormal()
        return
    end
    local widget = self:W()

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

function L:UpdateRangeIndicator()
    if not self:ContainsValidAction() then return end
    local widget = self:W()
    local configIsShowKeybindText = widget.dragFrame:IsShowKeybindText()
    widget:ShowKeybindText(configIsShowKeybindText)

    local hasTarget = API:IsValidActionTarget()
    if configIsShowKeybindText == true then
        return self:UpdateRangeIndicatorWithShowKeybindOn(hasTarget)
    end
    self:UpdateRangeIndicatorWithShowKeybindOff(hasTarget)
end

function L:SetActionUsable(isUsable)
    local normalTexture = self:B():GetNormalTexture()
    if not normalTexture then return end
    -- energy based spells do not use 'notEnoughMana'
    if not isUsable then
        normalTexture:SetVertexColor(0.3, 0.3, 0.3)
    else
        normalTexture:SetVertexColor(1.0, 1.0, 1.0)
    end
end

---@param cd CooldownInfo
function L:IsUsableSpell(cd)
    local spellID = cd.details.spell.id
    -- why true by default?
    if IsBlank(spellID) then return true end
    return IsUsableSpell(spellID)
end

---@param cdOrItemID CooldownInfo|number
function L:IsUsableItem(cdOrItemID)
    if 'number' == type(cdOrItemID) then return IsUsableItem(cdOrItemID) end
    local itemID = cdOrItemID.details.item.id
    if IsBlank(itemID) then return true end
    return IsUsableItem(itemID)
end

---@param cd CooldownInfo
function L:IsUsableMacro(cd)
    local spellID = cd.details.spell.id
    if IsBlank(spellID) then return true end
    return IsUsableSpell(spellID)
end

---@param icon string Blizzard Icon
function L:SetIcon(icon)
    local btn = self:B()
    btn:SetNormalTexture(icon)
    btn:SetPushedTexture(icon)

    local nTexture = btn:GetNormalTexture()
    if not nTexture.mask then
        nTexture.mask = CreateMask(btn, nTexture, GC.Textures.TEXTURE_HIGHLIGHT_BUTTON_OUTLINE)
    end

end

---@param buttonData Profile_Button
function L:IsValidItemProfile(buttonData)
    return not (buttonData == nil or buttonData.item == nil
            or IsBlank(buttonData.item.id))
end

---@param buttonData Profile_Button
function L:IsValidSpellProfile(buttonData)
    return not (buttonData == nil or buttonData.spell == nil
            or IsBlank(buttonData.spell.id))
end

---@param buttonData Profile_Button
function L:IsValidMacroProfile(buttonData)
    return not (buttonData == nil or buttonData.macro == nil
            or IsBlank(buttonData.macro.index)
            or IsBlank(buttonData.macro.name))
end

---@return ButtonData
function L:GetButtonData() return self:W().buttonData end
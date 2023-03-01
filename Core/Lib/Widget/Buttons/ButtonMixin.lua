--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetMacroSpell, GetMacroItem, GetItemInfoInstant = GetMacroSpell, GetMacroItem, GetItemInfoInstant
local IsUsableSpell, IsUsableItem, GetUnitName, C_Timer = IsUsableSpell, IsUsableItem, GetUnitName, C_Timer
local IsStealthed = IsStealthed

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local tostring, format, strlower, tinsert = tostring, string.format, string.lower, table.insert

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub, API = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub, ns.O.API
local pformat = ns.pformat
local P, AO, BaseAPI = O.Profile, O.AceLibFactory:A(), O.BaseAPI
local LSM, String = AO.AceLibSharedMedia, O.String
local IsBlank, IsNotBlank, ParseBindingDetails = String.IsBlank, String.IsNotBlank, String.ParseBindingDetails

local WAttr = O.GlobalConstants.WidgetAttributes
local SPELL, ITEM, MACRO, MOUNT = WAttr.SPELL, WAttr.ITEM, WAttr.MACRO, WAttr.MOUNT

local C, T = GC.C, GC.Textures
local UNIT = GC.UnitIDAttributes

local emptyTexture = GC.Textures.TEXTURE_EMPTY
local emptyGridTexture = GC.Textures.TEXTURE_EMPTY_GRID
local highlightTexture = GC.Textures.TEXTURE_EMPTY_GRID
local pushedTextureMask = GC.Textures.TEXTURE_EMPTY_GRID

local highlightTextureAlpha = 0.5
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
--- @class ButtonMixin : ButtonProfileMixin @ButtonMixin extends ButtonProfileMixin
--- @see ButtonUIWidget
local L = LibStub:NewLibrary(M.ButtonMixin); if not L then return end
local p = L:GetLogger()

--[[-----------------------------------------------------------------------------
Instance Methods
-------------------------------------------------------------------------------]]

---@param o ButtonMixin
local function PropsAndMethods(o)

    --- Create a new ButtonMixin instance and
    --- @param widget ButtonUIWidget
    function o:Mixin(widget) ns:K():Mixin(widget, self:New(widget)) end

    --- @param widget ButtonUIWidget
    --- @return ButtonMixin
    function o:New(widget)
        local newObj = ns:K():CreateAndInitFromMixin(o, widget)
        ns:K():Mixin(newObj, O.ButtonProfileMixin:New(widget))
        return newObj
    end

    --- @param widget ButtonUIWidget
    function o:Init(widget)
        self.w = widget
    end

    function o:GetName() return self.w.button:GetName() end

    function o:InitWidget()
        self:SetButtonProperties()
        self:InitTextures(emptyTexture)
        if self:IsEmpty() then self:SetTextureAsEmpty() end
    end

    function o:SetButtonProperties()
        --- @type FrameWidget
        local dragFrame = self.w.dragFrame
        local barConfig = dragFrame:GetConfig()
        local buttonSize = barConfig.widget.buttonSize
        local buttonPadding = self.w.dragFrame.horizontalButtonPadding
        local frameStrata = self.w.frameStrata
        local frameLevel = self.w.frameLevel
        local button = self.w.button

        button:SetFrameStrata(frameStrata)
        button:SetFrameLevel(frameLevel)
        button:SetSize(buttonSize - buttonPadding, buttonSize - buttonPadding)

        self:Scale(buttonSize)
    end

    --- @param buttonSize number
    function o:Scale(buttonSize)
        local button = self.w.button
        button.keybindText.widget:ScaleWithButtonSize(buttonSize)
        --todo next: move to a ButtonScaleMixin?
        self:ScaleButtonTextsWithButtonSize(buttonSize)
        self:ScaleItemCountOffset(buttonSize)
    end

    --- @param buttonSize number
    function o:ScaleItemCountOffset(buttonSize)
        local offsetX = -2
        local offsetY = 7
        local scaleFactorX = 50
        local scaleFactorY = 100
        offsetX = (buttonSize/100) - (offsetX + buttonSize/15)
        local scaleXOffset = buttonSize/scaleFactorX * offsetX
        local scaleYOffset = buttonSize/scaleFactorY * offsetY
        self.w.button.text:SetPoint("BOTTOMRIGHT", scaleXOffset, scaleYOffset)
    end

    --- @see "BlizzardInterfaceCode/Interface/SharedXML/SharedFontStyles.xml" for font styles
    --- @param buttonSize number
    function o:ScaleButtonTextsWithButtonSize(buttonSize)
        local hideItemCountText = false
        local hideCountdownNumbers = false
        local hideIndexText = false
        local hideKeybindText = false
        local countdownFont
        local itemCountFont
        local profile = self.w:GetProfileConfig()
        local textUI = self.w.button.text
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

        self.w.cooldown:SetCountdownFont(countdownFont)
        self:HideCountdownNumbers(hideCountdownNumbers)
        self:SetHideItemCountText(hideItemCountText)
        self:SetHideIndexText(hideIndexText)
        self:SetHideKeybindText(hideKeybindText)

    end

    function o:RefreshTexts()
        local profile = self.w:GetProfileConfig()
        self:HideCountdownNumbers(true == profile.hide_countdown_numbers)
        local hideTexts = true == profile.hide_text_on_small_buttons
        if not hideTexts then
            local fw = self.w.dragFrame
            local barConf = fw:GetConfig()
            if true == barConf.show_button_index then
                self:SetHideIndexText(false)
            end
            return
        end

        local barConfig = self.w.dragFrame:GetConfig()
        local buttonSize = barConfig.widget.buttonSize
        if buttonSize > MIN_BUTTON_SIZE then return end

        self:SetHideKeybindText(hideTexts)
        self:SetHideIndexText(hideTexts)
        if not profile.hide_countdown_numbers then self:HideCountdownNumbers(hideTexts) end
    end

    --- @param state boolean
    function o:HideCountdownNumbers(state)
        self.w.cooldown:SetHideCountdownNumbers(state)
    end

    ---This is the item count text
    --- @param state boolean
    function o:SetHideItemCountText(state)
        local btn = self.w.button
        if true == state then
            btn.text:Hide()
            return
        end

        btn.text:Show()
    end

    --- @param state boolean
    function o:SetHideKeybindText(state)
        local btn = self.w.button
        if true == state then
            btn.keybindText:Hide()
            return
        end

        btn.keybindText:Show()
    end
    --- @param state boolean
    function o:SetHideIndexText(state)
        local btn = self.w.button
        if true == state then
            btn.indexText:Hide()
            return
        end

        btn.indexText:Show()
    end

    --- @param btn _Button
    --- @param texture _Texture
    --- @param texturePath string
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

    --- - Call this function once only; otherwise *CRASH* if called N times
    --- - [UIOBJECT MaskTexture](https://wowpedia.fandom.com/wiki/UIOBJECT_MaskTexture)
    --- - [Texture:SetTexture()](https://wowpedia.fandom.com/wiki/API_Texture_SetTexture)
    --- - [alphamask](https://wow.tools/files/#search=alphamask&page=5&sort=1&desc=asc)
    --- @param icon string The icon texture path
    function o:InitTextures(icon)
        local btnUI = self.w.button

        -- DrawLayer is 'ARTWORK' by default for icons
        btnUI:SetNormalTexture(icon)
        --Blend mode "Blend" gets rid of the dark edges in buttons
        btnUI:GetNormalTexture():SetBlendMode(GC.BlendMode.BLEND)

        self:SetHighlightDefault(btnUI)
        btnUI:SetPushedTexture(icon)

        local tex = btnUI:GetPushedTexture()
        CreateMask(btnUI, tex, pushedTextureMask)
        tex:SetAlpha(pushedTextureInUseAlpha)

        local hTexture = btnUI:GetHighlightTexture()
        if hTexture and not hTexture.mask then
            CreateMask(btnUI, hTexture, highlightTexture)
        end
    end

    --- @return ButtonAttributes
    function o:GetButtonAttributes() return self.w.buttonAttributes end
    function o:GetIndex() return self.w.index end
    function o:GetFrameIndex() return self.w.frameIndex end
    ---Only used for prefixing logs
    function o:N() return "F" .. self.frameIndex .. "_B" .. self.index end
    function o:IsParentFrameShown() return self.dragFrame:IsShown() end

    function o:ResetConfig()
        self.w:ResetButtonData()
        self:ResetWidgetAttributes()
    end

    function o:SetButtonAsEmpty()
        self:ResetConfig()
        self:SetTextureAsEmpty()
    end

    function o:Reset()
        self:ResetCooldown()
        self:ClearAllText()
    end

    function o:ResetCooldown() self:SetCooldown(0, 0) end
    function o:SetCooldown(start, duration) self.cooldown:SetCooldown(start, duration) end


    --- @type BindingInfo
    function o:GetBindings()
        return (self.addon.barBindings and self.addon.barBindings[self.buttonName]) or nil
    end

    --- @param text string
    function o:SetText(text)
        if String.IsBlank(text) then text = '' end
        self.w.button.text:SetText(text)
    end
    --- @param state boolean true will show the button index number
    function o:ShowIndex(state)
        local text = ''
        if true == state then text = self.w.index end
        self.w.button.indexText:SetText(text)
        self:RefreshTexts()
    end

    --- @param state boolean true will show the button index number
    function o:ShowKeybindText(state)
        local text = ''
        local button = self.w.button
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

    function o:HasKeybindings()
        local b = self:GetBindings()
        if not b then return false end
        return b and String.IsNotBlank(b.key1)
    end
    function o:ClearAllText()
        self:SetText('')
        self.button.keybindText:SetText('')
    end

    --- @return CooldownInfo
    function o:GetCooldownInfo()
        local btnData = self.w.config
        if btnData == nil or String.IsBlank(btnData.type) then return nil end
        local type = btnData.type

        --- @class CooldownInfo
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

    --- @param cd CooldownInfo The cooldown info
    --- @return SpellCooldown
    function o:GetSpellCooldown(cd)
        local spell = self:GetSpellData()
        if self:IsInvalidSpell(spell) then return end
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

    --- @param cd CooldownInfo The cooldown info
    --- @return ItemCooldown
    function o:GetItemCooldown(cd)
        local item = self:GetItemData()
        if self:IsInvalidItem(item) then return nil end
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

    --- @param cd CooldownInfo The cooldown info
    function o:GetMacroCooldown(cd)
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

    --- @return SpellCooldown
    function o:GetMacroSpellCooldown()
        local macro = self:GetMacroData();
        if not macro then return nil end
        local spellId = GetMacroSpell(macro.index)
        if not spellId then return nil end
        return API:GetSpellCooldown(spellId)
    end

    --- @return number The spellID for macro
    function o:GetMacroSpellId()
        local macro = self:GetMacroData();
        if not macro then return nil end
        return GetMacroSpell(macro.index)
    end

    --- @return ItemCooldown
    function o:GetMacroItemCooldown()
        local macro = self:GetMacroData();
        if not macro then return nil end

        local itemName = GetMacroItem(macro.index)
        if not itemName then return nil end

        local itemID = GetItemInfoInstant(itemName)
        return API:GetItemCooldown(itemID)
    end

    function o:ResetWidgetAttributes()
        local button = self.w.button
        for _, v in pairs(self:GetButtonAttributes()) do
            button:SetAttribute(v, nil)
        end
    end

    function o:UpdateItemState()
        self:ClearAllText()
        local item = self.w:GetItemData()
        if self:IsInvalidItem(item) then return end
        local itemID = item.id
        local itemInfo = API:GetItemInfo(itemID)
        if itemInfo == nil then return end
        if API:IsToyItem(itemID) then self:SetActionUsable(true); return end

        local stackCount = itemInfo.stackCount or 1
        local count = itemInfo.count
        item.count = count
        item.stackCount = stackCount
        if stackCount > 1 then self:SetText(item.count) end
        if count <= 0 then self:SetActionUsable(false)
        else self:SetActionUsable(self:IsUsableItem(itemID)) end
        return
    end

    function o:UpdateUsable()
        local cd = self:GetCooldownInfo()
        if (cd == nil or cd.details == nil or cd.details.spell == nil) then
            if self:IsCompanion() then self:SetActionUsable(true)
            elseif self:IsEquipmentSet() then self:SetActionUsable(not InCombatLockdown()) end
            return
        end

        local c = self.w.config
        local isUsableSpell = true
        if c.type == SPELL then
            isUsableSpell = self:IsUsableSpell(cd)
        elseif c.type == MACRO then
            isUsableSpell = self:IsUsableMacro(cd)
            self:UpdateMacroState()
        end
        self:SetActionUsable(isUsableSpell)
    end

    function o:UpdateState()
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
    function o:UpdateKeybindTextState()
        if not self:IsShowKeybindText() then
            self.w.button.keybindText:Hide()
            return
        end

        if self:IsEmpty() then
            if self:IsShowEmptyButtons() then
                self.w.button.keybindText:Show()
            else
                self.w.button.keybindText:Hide()
            end
            return
        end

        if not self:IsEmpty() then self.w.button.keybindText:Show() end
    end

    function o:UpdateStateDelayed(inSeconds) C_Timer.After(inSeconds, function() self:UpdateState() end) end
    function o:UpdateCooldown()
        local cd = self:GetCooldownInfo()
        if not cd or cd.enabled == 0 then return end
        -- Instant cast spells have zero duration, skip
        if (not cd.duration) or cd.duration <= 0 then
            self:ResetCooldown()
            return
        end
        self:SetCooldown(cd.start, cd.duration)
    end
    function o:UpdateCooldownDelayed(inSeconds) C_Timer.After(inSeconds, function() self:UpdateCooldown() end) end

    --- Note: Equipment Set Name cannot be updated.
    --- The Equipment Manager always creates a new unique name.
    function o:UpdateEquipmentSet()
        -- if index changed (similar to how macros are updated)
        -- if equipment set was deleted
        -- icon update
        p:log(30, 'Equipment-Set update called: %s', self:GetName())

        if self:IsMissingEquipmentSet() then self:SetButtonAsEmpty(); return end

        local equipmentSet = self.w:FindEquipmentSet()
        if not equipmentSet then self:SetButtonAsEmpty(); return end

        local btnData = self.w:GetEquipmentSetData()
        btnData.name = equipmentSet.name
        btnData.icon = equipmentSet.icon
        self:SetIcon(btnData.icon)
    end

    --- @return ActionBarInfo
    function o:GetActionbarInfo()
        local index = self.index
        local dragFrame = self.dragFrame;
        local frameName = dragFrame:GetName()
        local btnName = format('%sButton%s', frameName, tostring(index))

        --- @class ActionBarInfo
        local info = {
            name = frameName, index = dragFrame:GetFrameIndex(),
            button = { name = btnName, index = index },
        }
        return info
    end

    function o:ClearHighlight() self.w.button:SetHighlightTexture(nil) end
    function o:ResetHighlight() self:SetHighlightDefault() end

    --- @param texture string
    function o:SetNormalTexture(texture) self.w.button:SetNormalTexture(texture) end
    --- @param texture string
    function o:SetPushedTexture(texture)
        if texture then
            self.w.button:SetPushedTexture(texture)
            self:SetPushedTextureAlpha(pushedTextureInUseAlpha)
            return
        end
        self.w.button:SetPushedTexture(emptyTexture)
        if not self:IsShowEmptyButtons() then
            self:SetPushedTextureAlpha(0)
        end
    end

    --- @param texture string
    function o:SetHighlightTexture(texture)
        if texture then
            self.w.button:SetHighlightTexture(texture)
            self:SetHighlightTextureAlpha(highlightTextureAlpha)
            return
        end
        self.w.button:SetHighlightTexture(emptyTexture)
        self:SetHighlightTextureAlpha(0)
    end

    --- @param alpha number 1 (opaque) to zero (transparent)
    function o:SetPushedTextureAlpha(alpha) self.w.button:GetPushedTexture():SetAlpha(alpha or 1) end
    --- @param alpha number 1 (opaque) to zero (transparent)
    function o:SetHighlightTextureAlpha(alpha) self.w.button:GetHighlightTexture():SetAlpha(alpha or 1) end

    function o:SetTextureAsEmpty()
        self:SetNormalTexture(emptyTexture)
        self:SetPushedTexture(nil)
        self:SetHighlightTexture(nil)
        self:SetNormalIconAlphaAsEmpty()
        self:SetVertexColorNormal()
    end

    function o:SetNormalIconAlphaAsEmpty()
        local alpha = showEmptyGridAlpha
        if true ~= self.w:IsShowEmptyButtons() then alpha = 0 end
        self:SetNormalIconAlpha(alpha)
    end

    --- @param alpha number 0.0 to 1.0
    function o:SetNormalIconAlpha(alpha) self.w.button:GetNormalTexture():SetAlpha(alpha or 1.0) end
    function o:SetVertexColorNormal() self.w.button:GetNormalTexture():SetVertexColor(1.0, 1.0, 1.0) end

    function o:SetNormalIconAlphaDefault()
        if self:IsEmpty() then
            self:SetNormalIconAlphaAsEmpty()
            return
        end
        self:SetNormalIconAlpha(nonEmptySlotAlpha)
    end

    function o:SetPushedTextureDisabled() self.w.button:SetPushedTexture(nil) end

    ---This is used when an action button starts dragging to highlight other drag targets (empty slots).
    function o:ShowEmptyGrid()
        if not self:IsEmpty() then return end
        self:SetNormalTexture(emptyTexture)
        self:SetHighlightEmptyButtonEnabled(false)
    end

    function o:ShowEmptyGridEvent()
        if not self:IsEmpty() then return end
        self:SetButtonAsEmpty()
        self:ShowEmptyGrid()
        self:ShowKeybindText(true)

        if not self:IsShowKeybindText() then
            self.w.button.keybindText:Hide()
        elseif self:IsEmpty() then
            self.w.button.keybindText:Show()
        end
    end

    function o:HideEmptyGridEvent()
        if not self:IsEmpty() then return end
        self:SetTextureAsEmpty()
        self:SetHighlightEmptyButtonEnabled(true)
        self:SetNormalTexture(emptyTexture)
        self:SetNormalIconAlphaAsEmpty()
        if self:IsEmpty() and not self:IsShowEmptyButtons() then
            self.w.button.keybindText:Hide()
        end
    end

    function o:SetCooldownTextures(icon)
        local btnUI = self.w.button
        btnUI:SetNormalTexture(icon)
        btnUI:SetPushedTexture(icon)
    end

    function o:SetButtonStateNormal() self.w.button:SetButtonState('NORMAL') end
    function o:SetButtonStatePushed() self.w.button:SetButtonState('PUSHED') end

    ---Typically used when casting spells that take longer than GCD
    function o:SetHighlightInUse()
        local btn = self.w.button
        self:SetNormalIconAlpha(highlightTextureInUseAlpha)
        local hltTexture = btn:GetHighlightTexture()
        --highlight texture could be nil if action_button_mouseover_glow is disabled
        if not hltTexture then return end
        hltTexture:SetDrawLayer(C.ARTWORK_DRAW_LAYER)
        hltTexture:SetAlpha(highlightTextureInUseAlpha)
        if hltTexture and not hltTexture.mask then CreateMask(btn, hltTexture, highlightTexture) end
    end
    function o:SetHighlightDefault()
        if self:IsEmpty() then return end
        self:SetHighlightEnabled(P:IsActionButtonMouseoverGlowEnabled())
        self:SetNormalIconAlpha(1.0)
    end

    function o:RefreshHighlightEnabled()
        local profile = self.w:GetProfileConfig()
        self:SetHighlightEnabled(true == profile.action_button_mouseover_glow)
    end

    --- @param state boolean true, to enable highlight
    function o:SetHighlightEnabled(state)
        local btnUI = self.w.button
        if state == true then
            btnUI:SetHighlightTexture(highlightTexture)
            btnUI:GetHighlightTexture():SetBlendMode(GC.BlendMode.ADD)
            btnUI:GetHighlightTexture():SetDrawLayer(GC.DrawLayer.HIGHLIGHT)
            btnUI:GetHighlightTexture():SetAlpha(highlightTextureAlpha)
            return
        end
        self:SetHighlightTexture(nil)
    end

    ---This is used for mouseover when dragging a cursor
    ---to highlight an empty slot
    function o:SetHighlightEmptyButtonEnabled(state)
        if not self:IsEmpty() then return end
        if true == state then
            self:SetNormalTexture(emptyGridTexture)
            self:SetNormalIconAlpha(showEmptyGridAlpha)
            return
        end
        self:SetNormalTexture(emptyTexture)
        self:SetNormalIconAlpha(showEmptyGridAlpha)
    end

    --- @param spellID string The spellID to match
    --- @param optionalBtnConf Profile_Button
    --- @return boolean
    function o:IsMatchingItemSpellID(spellID, optionalBtnConf)
        if not self:IsValidItemProfile(optionalBtnConf) then return end
        local _, btnItemSpellId = API:GetItemSpellInfo(optionalBtnConf.item.id)
        if spellID == btnItemSpellId then return true end
        return false
    end

    --- @param spellID string The spellID to match
    --- @param optionalBtnConf Profile_Button
    --- @return boolean
    function o:IsMatchingSpellID(spellID, optionalBtnConf)
        local buttonData = optionalBtnConf or self.w.config
        local w = self.w
        if w:IsSpell() then
            return spellID == buttonData.spell.id
        elseif w:IsItem() then
            return w:IsMatchingItemSpellID(spellID, buttonData)
        elseif w:IsMount() then
            return spellID == buttonData.mount.spell.id
        end
        return false
    end

    --- @param widget ButtonUIWidget
    --- @param spellName string The spell name
    --- @param buttonData Profile_Button
    function o:IsMatchingSpellName(spellName, buttonData)
        local s = buttonData or self.w.config
        if not (s.spell and s.spell.name) then return false end
        if not (s and spellName == s.spell.name) then return false end
        return true
    end

    --- @param spellID string
    --- @param optionalProfileButton Profile_Button
    function o:IsMatchingMacroSpellID(spellID, optionalProfileButton)
        optionalProfileButton = optionalProfileButton or self.w.config
        if not self:IsValidMacroProfile(optionalProfileButton) then return end
        local macroSpellId =  GetMacroSpell(optionalProfileButton.macro.index)
        if not macroSpellId then return false end
        if spellID == macroSpellId then return true end
        return false
    end

    --- @param spellID string The spellID to match
    --- @return boolean
    function o:IsMatchingMacroOrSpell(spellID)
        --- @type Profile_Button
        local conf = self.w.config
        if not conf and (conf.spell or conf.macro) then return false end
        if self:IsConfigOfType(conf, SPELL) then
            return spellID == conf.spell.id
        elseif self:IsConfigOfType(conf, MACRO) and conf.macro.index then
            local macroSpellId =  GetMacroSpell(conf.macro.index)
            return spellID == macroSpellId
        end

        return false;
    end

    --- @param hasTarget boolean Player has a target
    function o:UpdateRangeIndicatorWithShowKeybindOn(hasTarget)
        local show = self.w.frameIndex == 1 and (self.w.index == 1 or self.w.index == 2)
        local fs = self.w.button.keybindText
        if not hasTarget then fs.widget:SetVertexColorNormal(); return end

        if not self.w:HasKeybindings() then fs.widget:SetTextWithRangeIndicator() end

        -- else if in range, color is "white"
        local inRange = API:IsActionInRange(self.w.config, UNIT.TARGET)
        fs.widget:SetVertexColorNormal()
        if inRange == false then
            fs.widget:SetVertexColorOutOfRange()
        elseif inRange == nil then
            -- spells, items, macros where range is not applicable
            if not self.w:HasKeybindings() then fs.widget:ClearText() end
        end
    end

    --- @param hasTarget boolean Player has a target
    function o:UpdateRangeIndicatorWithShowKeybindOff(hasTarget)
        local show = self.w.frameIndex == 1 and self.w.index == 1
        --if show then p:log('UpdateRangeIndicatorWithShowKeybindOff: %s', hasTarget) end
        -- if no target, clear text and return
        local fs = self.w.button.keybindText
        if not hasTarget then
            fs.widget:ClearText()
            fs.widget:SetVertexColorNormal()
            return
        end

        -- has target, set text as range indicator
        fs.widget:SetTextWithRangeIndicator()

        local inRange = API:IsActionInRange(self.w.config, UNIT.TARGET)

        --self:log('%s in-range: %s', widget:GetName(), tostring(inRange))
        fs.widget:SetVertexColorNormal()
        if inRange == false then
            fs.widget:SetVertexColorOutOfRange()
        elseif inRange == nil then
            fs.widget:ClearText()
        end
    end

    function o:UpdateRangeIndicator()
        if not self:ContainsValidAction() then return end
        local configIsShowKeybindText = self.w.dragFrame:IsShowKeybindText()
        self.w:ShowKeybindText(configIsShowKeybindText)

        local hasTarget = API:IsValidActionTarget()
        if configIsShowKeybindText == true then
            return self:UpdateRangeIndicatorWithShowKeybindOn(hasTarget)
        end
        self:UpdateRangeIndicatorWithShowKeybindOff(hasTarget)
    end

    function o:SetActionUsable(isUsable)
        local normalTexture = self.w.button:GetNormalTexture()
        if not normalTexture then return end
        -- energy based spells do not use 'notEnoughMana'
        if IsStealthed() or API:IsShapeShiftActive(self:GetSpellData()) then
            normalTexture:SetVertexColor(1.0, 1.0, 1.0)
        elseif not isUsable then
            normalTexture:SetVertexColor(0.3, 0.3, 0.3)
        else
            normalTexture:SetVertexColor(1.0, 1.0, 1.0)
        end
    end

    --- @param cd CooldownInfo
    function o:IsUsableSpell(cd)
        local spellID = cd.details.spell.id
        -- why true by default?
        if IsBlank(spellID) then return true end
        return IsUsableSpell(spellID)
    end

    --- @param cdOrItemID CooldownInfo|number
    function o:IsUsableItem(cdOrItemID)
        if 'number' == type(cdOrItemID) then return IsUsableItem(cdOrItemID) end
        local itemID = cdOrItemID.details.item.id
        if IsBlank(itemID) then return true end
        return IsUsableItem(itemID)
    end

    --- @param cd CooldownInfo
    function o:IsUsableMacro(cd)
        local spellID = cd.details.spell.id
        if IsBlank(spellID) then return true end
        return IsUsableSpell(spellID)
    end

    --- @param icon string Blizzard Icon
    function o:SetIcon(icon)
        local btn = self.w.button
        self:SetNormalTexture(icon)
        self:SetPushedTexture(icon)
        local nTexture = btn:GetNormalTexture()
        if not nTexture.mask then CreateMask(btn, nTexture, emptyTexture) end
    end

    --- @param buttonData Profile_Button
    function o:IsValidItemProfile(buttonData)
        return not (buttonData == nil or buttonData.item == nil
                or IsBlank(buttonData.item.id))
    end

    --- @param buttonData Profile_Button
    function o:IsValidSpellProfile(buttonData)
        return not (buttonData == nil or buttonData.spell == nil
                or IsBlank(buttonData.spell.id))
    end

    --- @param buttonData Profile_Button
    function o:IsValidMacroProfile(buttonData)
        return not (buttonData == nil or buttonData.macro == nil
                or IsBlank(buttonData.macro.index)
                or IsBlank(buttonData.macro.name))
    end

    function o:CanChangeEquipmentSet()
        if not (C_EquipmentSet and C_EquipmentSet.CanUseEquipmentSets()) then return false end
        return self:IsEquipmentSet()
    end

    function o:UpdateMacroState()
        local scd = self:GetMacroSpellCooldown()
        if not (scd and scd.spell) then return end
        local icon = scd.spell.icon
        if self:IsStealthSpell() then
            local spellInfo = self:GetSpellData()
            icon = API:GetSpellIcon(spellInfo)
        elseif self:IsShapeshiftSpell() then
            local spellInfo = self:GetSpellData()
            icon = API:GetSpellIcon(spellInfo)
        end
        self:SetIcon(icon)
        self:UpdateCooldown()
    end
end

PropsAndMethods(L)

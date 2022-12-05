--
-- ButtonFrameFactory
-- Creates the actionbar frame (anchor) for the buttons
--
--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateAnchor, GridLayoutMixin = CreateAnchor, GridLayoutMixin

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local _G = _G
local format, type, ipairs, tinsert = string.format, type, ipairs, table.insert
--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
---@type _AnchorUtil
local AnchorUtil = AnchorUtil
local C_Timer = C_Timer

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local Assert, Table, P = O.Assert, O.Table, O.Profile
local AO = O.AceLibFactory:A()
local AceEvent, AceGUI, LSM = AO.AceEvent, AO.AceGUI, AO.AceLibSharedMedia
local GC = O.GlobalConstants
local E = GC.E

-- post combat updates (SetAttribute* is not allowed during combat)
local PostCombatButtonUpdates = {}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class ButtonFrameFactory : ButtonFrameFactory_Methods
local _L = LibStub:NewLibrary(Core.M.ButtonFrameFactory)
---@type LoggerTemplate
local p = _L:GetLogger()

---@class WidgetBase
local WidgetBaseTemplate = {
    ---@param self WidgetBase
    ---@param name string
    ['Fire'] = function(self, name, ...) end,
    ---@param self WidgetBase
    ---@param name string
    ---@param func function The callback function
    ['SetCallback'] = function(self, name, func) end,
}

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param widget FrameWidget
---@param name string The widget name.
local function RegisterWidget(widget, name)
    assert(widget ~= nil)
    assert(name ~= nil)

    local WidgetBase = AceGUI.WidgetBase
    widget.userdata = {}
    widget.events = {}
    widget.base = WidgetBase
    widget.frame.obj = widget
    local mt = {
        __tostring = function() return name  end,
        __index = WidgetBase
    }
    setmetatable(widget, mt)
end

---@param widget ButtonUIWidget
local function SetButtonAttributes(widget)
    if widget:IsEmpty() then return end

    local btnConf = widget:GetConfig()
    local setter = O.ButtonFactory:GetAttributesSetter(btnConf.type)
    if setter then setter:SetAttributes(widget.frame, btnConf) end
end

---@param frameWidget FrameWidget
local function OnCooldownTextSettingsChanged(frameWidget, event)
    p:log(20,'%s: frame #%s', event, frameWidget:GetFrameIndex())
    ---@param bw ButtonUIWidget
    frameWidget:ApplyForEachButton(function(bw) bw:RefreshTexts()  end)
end
---@param frameWidget FrameWidget
local function OnTextSettingsChanged(frameWidget, event)
    p:log(20,'%s: frame #%s', event, frameWidget:GetFrameIndex())
    ---@param bw ButtonUIWidget
    frameWidget:ApplyForEachButton(function(bw) bw:RefreshTexts()  end)
end
---@param frameWidget FrameWidget
local function OnMouseOverGlowSettingsChanged(frameWidget, event)
    p:log(20,'%s: frame #%s', event, frameWidget:GetFrameIndex())
    ---@param bw ButtonUIWidget
    frameWidget:ApplyForEachButton(function(bw) bw:RefreshHighlightEnabled() end)
end

---@param frameWidget FrameWidget
local function OnButtonSizeChanged(frameWidget, event)
    p:log(20,'%s: frame #%s', event, frameWidget:GetFrameIndex())

    ---@param bw ButtonUIWidget
    frameWidget:ApplyForEachButton(function(bw)
        bw:SetButtonProperties()
        bw:RefreshTexts()
        bw:UpdateKeybindTextState()
    end)
    frameWidget:SetFrameDimensions()
    frameWidget:LayoutButtonGrid()
end

---@param frameWidget FrameWidget
local function OnButtonCountChanged(frameWidget, event)
    p:log(20,'%s: frame #%s', event, frameWidget:GetFrameIndex())

    local barConfig = frameWidget:GetConfig()
    local widget = barConfig.widget

    frameWidget:SetFrameDimensions()
    O.ButtonFactory:CreateButtons(frameWidget, widget.rowSize, widget.colSize)
    frameWidget:SetInitialState()
    frameWidget:ShowGroupIfEnabled()

    ---@param bw ButtonUIWidget
    frameWidget:ApplyForEachButton(function(bw)
        bw:SetButtonProperties()
        bw:RefreshTexts()
        bw:UpdateKeybindTextState()
    end)
end

---@param frameWidget FrameWidget
local function OnActionbarFrameAlphaUpdated(frameWidget, event, sourceFrameIndex)
    frameWidget:UpdateButtonAlpha()
end
---@param frameWidget FrameWidget
local function OnActionbarShowEmptyButtonsUpdated(frameWidget, event, sourceFrameIndex)
    frameWidget:UpdateEmptyButtonsSettings()
end

---Event is fired from ActionbarPlus#OnAddonLoaded
---@param w FrameWidget
local function OnAddonLoaded(w)
    p:log(30, 'OnAddonLoaded: %s', w:GetName())
    -- show delayed due to anchor not setting until UI is fully loaded
    C_Timer.After(1, function() w:InitAnchor() end)
    C_Timer.After(2, function() w:ShowGroupIfEnabled() end)
end

---Fired by FrameHandle when dragging stopped
---@param frameWidget FrameWidget
---@param event string
local function OnDragStop_FrameHandle(frameWidget, event) frameWidget:UpdateAnchor() end

---@param frameWidget FrameWidget
local function OnActionbarShowGrid(frameWidget, e, ...)
    ---@param bw ButtonUIWidget
    frameWidget:ApplyForEachButton(function(bw) bw:ShowEmptyGridEvent() end)
end
---@param frameWidget FrameWidget
local function OnActionbarHideGrid(frameWidget, e, ...)
    p:log(30, '%s called...', frameWidget.index)
    ---@param bw ButtonUIWidget
    frameWidget:ApplyForEachButton(function(bw) bw:HideEmptyGridEvent() end)
end
---@param frameWidget FrameWidget
local function OnMouseOverFrameHandleConfigChanged(frameWidget, e, ...) frameWidget.frameHandle:UpdateBackdropState() end

---@param frameWidget FrameWidget
local function OnFrameHandleAlphaConfigChanged(frameWidget, e, ...)
    p:log(30, '%s called...', frameWidget.index)
    local barConf = frameWidget:GetConfig()
    frameWidget.frameHandle:SetAlpha(barConf.widget.frame_handle_alpha or 1.0)
end

---Sometimes there's a delay. Fire immediately, then after a few seconds
---@param frameWidget FrameWidget
local function OnActionbarShowGroup(frameWidget, e, ...)
    if  true ~= P:IsBarEnabled(frameWidget.index) then return end
    frameWidget:ShowGroup()
    C_Timer.After(5, function() frameWidget:ShowGroup() end)
end

---Sometimes there's a delay. Fire immediately, then after a few seconds
---@param frameWidget FrameWidget
local function OnPlayerLeaveCombat(frameWidget, e, ...)
    OnActionbarShowGroup(frameWidget, e, ...)
    _L:PostCombatUpdateComplete()
end

---@param frameWidget FrameWidget
local function OnActionbarHideGroup(frameWidget, e, ...)
    frameWidget:HideGroup()
    C_Timer.After(5, function() frameWidget:HideGroup() end)
end

---@param frameWidget FrameWidget
local function OnUpdateItemStates(frameWidget, e, ...)
    p:log(30, '%s called...', frameWidget.index)
    ---@param bw ButtonUIWidget
    frameWidget:ApplyForEachItem(function(bw) bw:UpdateItemState() end)
end

local function RegisterCallbacks(widget)
    widget:SetCallback(E.OnAddonLoaded, OnAddonLoaded)
    widget:SetCallback(E.OnCooldownTextSettingsChanged, OnCooldownTextSettingsChanged)
    widget:SetCallback(E.OnTextSettingsChanged, OnTextSettingsChanged)
    widget:SetCallback(E.OnMouseOverGlowSettingsChanged, OnMouseOverGlowSettingsChanged)
    widget:SetCallback(E.OnButtonSizeChanged, OnButtonSizeChanged)
    widget:SetCallback(E.OnButtonCountChanged, OnButtonCountChanged)
    widget:SetCallback(O.FrameHandleMixin.E.OnDragStop_FrameHandle, OnDragStop_FrameHandle)

    widget:SetCallback(E.OnActionbarFrameAlphaUpdated, OnActionbarFrameAlphaUpdated)
    widget:SetCallback(E.OnActionbarShowEmptyButtonsUpdated, OnActionbarShowEmptyButtonsUpdated)
    widget:SetCallback(E.OnActionbarShowGrid, OnActionbarShowGrid)
    widget:SetCallback(E.OnActionbarHideGrid, OnActionbarHideGrid)

    widget:SetCallback(E.OnFrameHandleMouseOverConfigChanged, OnMouseOverFrameHandleConfigChanged)
    widget:SetCallback(E.OnFrameHandleAlphaConfigChanged, OnFrameHandleAlphaConfigChanged)
    widget:SetCallback(E.OnActionbarHideGroup, OnActionbarHideGroup)
    widget:SetCallback(E.OnActionbarShowGroup, OnActionbarShowGroup)
    widget:SetCallback(E.OnUpdateItemStates, OnUpdateItemStates)
    widget:SetCallback(E.OnPlayerLeaveCombat, OnPlayerLeaveCombat)

    --todo next: move events from ButtonUI to here 'coz it's more performant/efficient
    --widget:SetCallback("OnUnitSpellcastSent", OnUnitSpellcastSent)
    --widget:SetCallback("OnCurrentSpellcastChanged", OnCurrentSpellcastChanged)
end

---@param widget FrameWidget
local function RegisterEvents(widget)
    ---@param w FrameWidget
    local function OnPlayerEnterCombatFrameWidget(w) w:SetCombatLockState() end
    ---@param w FrameWidget
    local function OnPlayerLeaveCombatFrameWidget(w) w:SetCombatUnlockState() end

    widget:RegisterEvent(E.PLAYER_REGEN_DISABLED, OnPlayerEnterCombatFrameWidget, widget)
    widget:RegisterEvent(E.PLAYER_REGEN_ENABLED, OnPlayerLeaveCombatFrameWidget, widget)
    --todo next: move events from ButtonUI to here 'coz it's more performant/efficient
    --widget:RegisterEvent(E.UNIT_SPELLCAST_START, OnSpellCastStart, widget)
end

-----@param frame _Frame
-----@param event string
--local function OnEvent(frame, event, ...)
--    local BF = O.ButtonFactory
--    p:log('[%s]: %s', event, {...})
--    ---@param frameWidget FrameWidget
--    BF:ApplyForEachFrames(function(frameWidget)
--        p:log('hiding group: %s', frameWidget.index)
--        frameWidget:HideGroup()
--        --C_Timer.After(1, function()
--        --    print('hiding group')
--        --    frameWidget:HideGroup()
--        --end)
--    end)
--end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param widget FrameWidget
local function WidgetMethods(widget)
    local AssertThatMethodArgIsNotNil = Assert.AssertThatMethodArgIsNotNil

    local profile = widget.profile
    local frame = widget.frame

    function widget:GetName() return widget.frame:GetName() end

    ---@deprecated Use self#GetIndex()
    function widget:GetFrameIndex() return self:GetIndex() end
    function widget:GetIndex() return self.index end

    ---@return Profile_Bar
    function widget:GetConfig() return profile:GetBar(self:GetIndex()) end

    function widget:InitAnchor()
        local anchor = P:GetAnchor(self.index)
        local relativeTo = anchor.relativeTo and _G[anchor.relativeTo] or nil
        if GC:IsVerboseLogging() and frame:IsShown() then
            p:log('InitAnchor| anchor-from-profile[f.%s]: %s', self.index, anchor)
        end
        frame:ClearAllPoints()
        frame:SetPoint(anchor.point, relativeTo , anchor.relativePoint, anchor.x, anchor.y)
    end

    function widget:UpdateAnchor()
        local n = frame:GetNumPoints()
        if n <= 0 then return end

        ---@type _RegionAnchor
        local frameAnchor = AnchorUtil.CreateAnchorFromPoint(frame, 1)
        P:SaveAnchor(frameAnchor, self.index)

        p:log(20, 'OnDragStop_FrameHandle| new-anchor[f #%s]: %s', self.index, pformat:D2()(frameAnchor))
    end

    function widget:IsLockedInCombat() return profile:IsBarLockedInCombat(self:GetFrameIndex()) end
    function widget:SetCombatLockState() if self:IsLockedInCombat() then self:LockGroup() end end
    function widget:SetCombatUnlockState() if self:IsLockedInCombat() then self:UnlockGroup() end end

    ---@return boolean
    function widget:IsFrameEnabledInConfig() return P:IsBarNameEnabled(self:GetName()) end

    function widget:SetFrameState(isEnabled)
        local frameIndex = self:GetIndex()
        AssertThatMethodArgIsNotNil(frameIndex, 'frameIndex', 'SetFrameState(frameIndex)')
        P:SetBarEnabledState(frameIndex, isEnabled)
        if isEnabled then
            if self.ShowGroup then self:ShowGroup() end
            return
        end
        if self.HideGroup then self:HideGroup() end
    end

    -- Not sure what the use case is for this
    -- Synchronize UI and Profile data
    --[[function widget:IsShownInConfigSynchronize()
        local frameIndex = self:GetIndex()
        AssertThatMethodArgIsNotNil(frameIndex, 'frameIndex', 'IsShownInConfig(frameIndex)')
        local actualFrameIsShown = frame:IsShown()
        P:SetBarEnabledState(frameIndex, actualFrameIsShown)
        return P:IsBarEnabled(frameIndex)
    end]]

    -- Synchronize UI and Profile data
    function widget:IsShownInConfig() return P:IsBarEnabled(self.index) end

    function widget:IsShowIndex() return P:IsShowIndex(self:GetFrameIndex()) end
    function widget:IsShowKeybindText() return P:IsShowKeybindText(self:GetFrameIndex()) end

    ---@param state boolean true will show button indices
    function widget:ShowButtonIndices(state)
        local theState = (state == true)
        self:GetConfig().show_button_index = theState
        ---@param bw ButtonUIWidget
        self:ApplyForEachButton(function(bw) bw:ShowIndex(theState) end)
    end
    ---@param state boolean true will show button indices
    function widget:ShowKeybindText(state)
        local theState = (state == true)
        self:GetConfig().show_keybind_text = theState
        ---@param bw ButtonUIWidget
        self:ApplyForEachButton(function(bw)
            bw:ShowKeybindText(theState)
            bw:UpdateKeybindTextState()
        end)
    end

    function widget:UpdateKeybindText()
        self:ShowKeybindText(self:IsShowKeybindText())
    end

    ---@param applyFunction function(ButtonUIWidget) Should be in format function(buttonWidget) {}
    function widget:ApplyForEachButton(applyFunction)
        if self:HasEmptyButtons() then return end
        -- `_` is the index
        ---@param btn ButtonUI
        for _, btn in ipairs(self.buttonFrames) do applyFunction(btn.widget) end
    end

    ---@param applyFunction function(ButtonUIWidget) Should be in format function(buttonWidget) {}
    function widget:ApplyForEachItem(applyFunction)
        if self:HasEmptyButtons() then return end
        -- `_` is the index
        ---@param btn ButtonUI
        for _, btn in ipairs(self.buttonFrames) do
            if btn.widget:IsItem() then applyFunction(btn.widget) end
        end
    end

    ---@param applyFunction function(ButtonUIWidget) Should be in format function(buttonWidget) {}
    ---@param matchSpellId number
    function widget:ApplyForEachSpellOrMacroButtons(matchSpellId, applyFunction)
        ---@param btnWidget ButtonUIWidget
        return self:ApplyForEachButtonCondition(
                function(btnWidget) return btnWidget:IsMatchingMacroOrSpell(matchSpellId) end,
                applyFunction)
    end

    ---@param conditionFn function The condition function; Example: function(btnWidget) return true end
    ---@param applyFn function(ButtonUIWidget) Should be in format function(btnWidget) {}
    function widget:ApplyForEachButtonCondition(conditionFn, applyFn)
        if self:HasEmptyButtons() then return end
        -- `_` is the index
        ---@param btn ButtonUI
        for _, btn in ipairs(self.buttonFrames) do
            if true == conditionFn(btn.widget) then applyFn(btn.widget) end
        end
    end

    function widget:SetGroupState(isShown)
        if isShown == true then
            if self.ShowGroup then self:ShowGroup() end
            return
        end
        if self.HideGroup then self:HideGroup() end
    end

    function widget:ToggleVisibility()
        local barData = self:GetConfig()
        local enabled = barData.enabled
        barData.enabled = not enabled
        if enabled then
            self:HideGroup()
            return
        end

        self:ShowGroup()
    end

    function widget:LockGroup() self.frameHandle:Hide() end
    function widget:UnlockGroup() self.frameHandle:Show() end

    function widget:HideGroup()
        frame:Hide()
        self:HideButtons()
    end
    function widget:ShowGroup()
        frame:Show()
        self:ShowButtons()
    end
    function widget:ShowGroupIfEnabled()
        if self:IsFrameEnabledInConfig() then
            self:ShowGroup()
            return
        end
        self:HideGroup()
    end

    function widget:ShowButtons()
        local isShowKeybindText = self:IsShowKeybindText()
        ---@param bw ButtonUIWidget
        self:ApplyForEachButton(function(bw)
            bw:ShowKeybindText(isShowKeybindText)
            bw.button:Show()
        end)
    end

    ---@param state boolean
    function widget:UpdateActionButtonMouseoverState(state)
        ---@param bw ButtonUIWidget
        self:ApplyForEachButton(function(bw)
            bw:SetHighlightEnabled(state)
        end)
    end

    function widget:HideButtons()
        ---@param bf ButtonUI
        for _, bf in ipairs(self.buttonFrames) do bf:Hide() end
    end

    ---@param buttonFrame ButtonUI
    function widget:AddButtonFrame(buttonFrame)
        if not buttonFrame then return end
        tinsert(self.buttonFrames, buttonFrame)
    end

    function widget:GetButtonCount() return #self.buttonFrames end
    function widget:HasEmptyButtons() return self:GetButtonCount() <= 0 end
    --- hard code max button column size for now
    function widget:GetMaxButtonColSize() return 40 end
    function widget:GetButtons() return self.buttonFrames end

    function widget:GetButtonFrames() return self.buttonFrames end
    function widget:IsRendered() return self.rendered end
    function widget:IsNotRendered() return not self:IsRendered() end
    function widget:MarkRendered() self.rendered = true end

    function widget:SetInitialState()
        self:MarkRendered()
        self:SetLockedState()
        self:ShowButtonIndices(self:IsShowIndex())
        self:ShowKeybindText(self:IsShowKeybindText())
        self:SetInitialStateOnFrameHandle()
        self:UpdateButtonAlpha()
    end

    function widget:SetInitialStateOnFrameHandle() self.frameHandle:UpdateBackdropState() end

    function widget:UpdateButtonAlpha()
        local barConf = self:GetConfig()
        local buttonAlpha = barConf.widget.buttonAlpha
        if not buttonAlpha or buttonAlpha < 0 then buttonAlpha = 1.0 end
        ---@param bw ButtonUIWidget
        self:ApplyForEachButton(function(bw)
            bw.button:SetAlpha(buttonAlpha)
        end)
    end

    function widget:UpdateEmptyButtonsSettings()
        ---@param bw ButtonUIWidget
        self:ApplyForEachButton(function(bw)
            if not bw:IsEmpty() then return end
            bw:SetTextureAsEmpty()
            bw:UpdateKeybindTextState()
        end)
    end

    function widget:SetLockedState()
        local frameIndex = self:GetIndex()
        if P:IsBarLockedAlways(frameIndex) then
            self:LockGroup()
        else P:IsBarUnlocked(frameIndex)
            self:UnlockGroup()
        end
    end

    function widget:RefreshActionbarFrame()
        self:SetFrameDimensions()
        ---@param bw ButtonUIWidget
        self:ApplyForEachButton(function(bw) bw:SetButtonProperties() end)
    end

    function widget:SetFrameDimensions()
        local barData = self:GetConfig()
        local widgetData = barData.widget
        local f = self.frame
        local frameHandle = self.frameHandle
        local widthAdj = self.padding
        local heightAdj = self.padding + self.dragHandleHeight
        local frameWidth = (widgetData.colSize * widgetData.buttonSize) + widthAdj
        frameHandle:SetWidth(frameWidth)
        frameHandle:SetHeight(self.frameHandleHeight)

        f:SetWidth(frameWidth)
        f:SetHeight((widgetData.rowSize * widgetData.buttonSize) + heightAdj)

        --TODO: Clears the backdrop
        -- frame backdrop when button is empty state
        --f:ClearBackdrop()
        --f:SetBackdrop(BACKDROP_GOLD_DIALOG_32_32)
        --f:ApplyBackdrop()
        --f:SetAlpha(0)
    end

    function widget:ClearButtons() self.buttonFrames = {} end

    ---@param buttonIndex number
    function widget:GetButtonName(buttonIndex)
        return format('%sButton%s', self:GetName(), tostring(buttonIndex))
    end

    function widget:GetButtonUI(buttonIndex) return _G[self:GetButtonName(buttonIndex)] end


    function widget:LayoutButtonGrid()
        local barConfig = self:GetConfig()
        local buttonSize = barConfig.widget.buttonSize
        local paddingX = self.horizontalButtonPadding
        local paddingY = self.verticalButtonPadding
        local horizontalSpacing = buttonSize;
        local verticalSpacing = buttonSize;
        local stride = barConfig.widget.colSize;
        -- TopLeftToBottomRight
        -- TopLeftToBottomRightVertical
        local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight,
                stride, paddingX, paddingY, horizontalSpacing, verticalSpacing);
        --- Offset from the anchor point
        ---@param row number
        ---@param col number
        function layout:GetCustomOffset(row, col) return 0, 0 end

        ---@type _AnchorMixin
        local anchor = CreateAnchor("TOPLEFT", self:GetName(), "TOPLEFT", 0, -2);
        AnchorUtil.GridLayout(self.buttonFrames, anchor, layout);
    end
end

---@return _Frame
function _L:GetFrameByIndex(frameIndex)
    local frameName = P:GetFrameNameByIndex(frameIndex)
    return _G[frameName]
end

function _L:IsFrameShownByIndex(frameIndex)
    return self:GetFrameByIndex(frameIndex):IsShown()
end

---@param btnWidget ButtonUIWidget
function _L:AddPostCombatUpdate(btnWidget) table.insert(PostCombatButtonUpdates, btnWidget) end

function _L:PostCombatUpdateComplete()
    local count = #PostCombatButtonUpdates
    if count <= 0 then return end
    ---@param widget ButtonUIWidget
    for i, widget in ipairs(PostCombatButtonUpdates) do
        SetButtonAttributes(widget)
        PostCombatButtonUpdates[i] = nil
    end
end

function _L:Constructor(frameIndex)

    ---@class ActionbarFrame : _Frame
    local f = self:GetFrameByIndex(frameIndex)
    --TODO: NEXT: Move frame strata to Settings
    local frameStrata = 'MEDIUM'
    f:SetFrameStrata(frameStrata)
    ---Alpha needs to be zero so that we can hide the buttons
    f:SetAlpha(0)

    ---@class FrameWidget : WidgetBase
    local widget = {
        profile = P,
        index = frameIndex,
        frameHandleHeight = 4,
        dragHandleHeight = 0,
        padding = 2,
        --todo next: add to options UI
        horizontalButtonPadding = 1,
        verticalButtonPadding = 1,
        frameStrata = frameStrata,
        frameLevel = 1,
        frame = f,
        ---@type FrameHandle
        frameHandle = nil,
        rendered = false,
        buttons = {},
        buttonFrames = {}
    }
    -- Allows call to Use callbacks / RegisterEvent
    AceEvent:Embed(widget)

    widget.frame = f
    f.widget = widget

    widget.frameHandle = ABP_CreateFrameHandle(widget)
    widget.frameHandle:Show()

    RegisterWidget(widget, f:GetName() .. '::Widget')
    WidgetMethods(widget)
    RegisterCallbacks(widget)
    RegisterEvents(widget)

    widget:SetFrameDimensions()

    return widget
end

_L.mt.__call = _L.Constructor

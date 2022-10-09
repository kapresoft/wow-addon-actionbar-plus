--
-- ButtonFrameFactory
-- Creates the actionbar frame (anchor) for the buttons
--
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

---@param frameWidget FrameWidget
local function OnCooldownTextSettingsChanged(frameWidget, event)
    p:log(20,'%s: frame #%s', event, frameWidget:GetFrameIndex())
    ---@param btnWidget ButtonUIWidget
    frameWidget:ApplyForEachButtons(function(btnWidget) btnWidget:RefreshTexts()  end)
end
---@param frameWidget FrameWidget
local function OnTextSettingsChanged(frameWidget, event)
    p:log(20,'%s: frame #%s', event, frameWidget:GetFrameIndex())
    ---@param btnWidget ButtonUIWidget
    frameWidget:ApplyForEachButtons(function(btnWidget) btnWidget:RefreshTexts()  end)
end
---@param frameWidget FrameWidget
local function OnMouseOverGlowSettingsChanged(frameWidget, event)
    p:log(20,'%s: frame #%s', event, frameWidget:GetFrameIndex())
    ---@param btnWidget ButtonUIWidget
    frameWidget:ApplyForEachButtons(function(btnWidget) btnWidget:RefreshHighlightEnabled() end)
end

---@param frameWidget FrameWidget
local function OnButtonSizeChanged(frameWidget, event)
    p:log(20,'%s: frame #%s', event, frameWidget:GetFrameIndex())

    frameWidget:SetFrameDimensions()
    ---@param btnWidget ButtonUIWidget
    frameWidget:ApplyForEachButtons(function(btnWidget)
        btnWidget:SetButtonLayout()
        btnWidget:RefreshTexts()
        btnWidget:UpdateKeybindTextState()
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
    ---@param btnWidget ButtonUIWidget
    frameWidget:ApplyForEachButtons(function(btnWidget) btnWidget:ShowEmptyGridEvent() end)
end
---@param frameWidget FrameWidget
local function OnActionbarHideGrid(frameWidget, e, ...)
    ---@param btnWidget ButtonUIWidget
    frameWidget:ApplyForEachButtons(function(btnWidget) btnWidget:HideEmptyGridEvent() end)
end
---@param frameWidget FrameWidget
local function OnMouseOverFrameHandleConfigChanged(frameWidget, e, ...) frameWidget.frameHandle:UpdateBackdropState() end

---@param frameWidget FrameWidget
local function OnFrameHandleAlphaConfigChanged(frameWidget, e, ...)
    --p:log('f %s: called...', frameWidget.index)
    local barConf = frameWidget:GetConfig()
    frameWidget.frameHandle:SetAlpha(barConf.widget.frame_handle_alpha or 1.0)
end

---@param frameWidget FrameWidget
local function OnPetBattleStart(frameWidget, e, ...)
    C_Timer.After(3, function() frameWidget:HideGroup() end)

end
---@param frameWidget FrameWidget
local function OnPetBattleEnd(frameWidget, e, ...)
    if  true ~= P:IsBarEnabled(frameWidget.index) then return end
    C_Timer.After(2, function() frameWidget:ShowGroup()  end)
end

local function RegisterCallbacks(widget)
    widget:SetCallback(E.OnAddonLoaded, OnAddonLoaded)
    widget:SetCallback(E.OnCooldownTextSettingsChanged, OnCooldownTextSettingsChanged)
    widget:SetCallback(E.OnTextSettingsChanged, OnTextSettingsChanged)
    widget:SetCallback(E.OnMouseOverGlowSettingsChanged, OnMouseOverGlowSettingsChanged)
    widget:SetCallback(E.OnButtonSizeChanged, OnButtonSizeChanged)
    widget:SetCallback(O.FrameHandleMixin.E.OnDragStop_FrameHandle, OnDragStop_FrameHandle)

    widget:SetCallback(E.OnActionbarFrameAlphaUpdated, OnActionbarFrameAlphaUpdated)
    widget:SetCallback(E.OnActionbarShowEmptyButtonsUpdated, OnActionbarShowEmptyButtonsUpdated)
    widget:SetCallback(E.OnActionbarShowGrid, OnActionbarShowGrid)
    widget:SetCallback(E.OnActionbarHideGrid, OnActionbarHideGrid)

    widget:SetCallback(E.OnFrameHandleMouseOverConfigChanged, OnMouseOverFrameHandleConfigChanged)
    widget:SetCallback(E.OnFrameHandleAlphaConfigChanged, OnFrameHandleAlphaConfigChanged)
    widget:SetCallback(E.OnPetBattleStart, OnPetBattleStart)
    widget:SetCallback(E.OnPetBattleEnd, OnPetBattleEnd)
    --todo next: move events from ButtonUI to here 'coz it's more performant/efficient
    --widget:SetCallback("OnUnitSpellcastSent", OnUnitSpellcastSent)
    --widget:SetCallback("OnCurrentSpellcastChanged", OnCurrentSpellcastChanged)
end

---@param widget FrameWidget
local function RegisterEvents(widget)
    ---@param w FrameWidget
    local function OnPlayerEnterCombat(w) w:SetCombatLockState() end
    ---@param w FrameWidget
    local function OnPlayerLeaveCombat(w) w:SetCombatUnlockState() end
    widget:RegisterEvent(E.PLAYER_REGEN_DISABLED, OnPlayerEnterCombat, widget)
    widget:RegisterEvent(E.PLAYER_REGEN_ENABLED, OnPlayerLeaveCombat, widget)
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

    widget.rendered = false
    widget.buttons = {}
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
        _F = self
        if not self.index then error('hello') end
        P:SaveAnchor(frameAnchor, self.index)

        p:log(20, 'OnDragStop_FrameHandle| new-anchor[f #%s]: %s', self.index, pformat:D2()(frameAnchor))
    end

    function widget:IsLockedInCombat() return profile:IsBarLockedInCombat(self:GetFrameIndex()) end
    function widget:SetCombatLockState() if self:IsLockedInCombat() then self:LockGroup() end end
    function widget:SetCombatUnlockState() if self:IsLockedInCombat() then self:UnlockGroup() end end

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

    -- Synchronize UI and Profile data
    function widget:IsShownInConfig()
        local frameIndex = self:GetIndex()
        AssertThatMethodArgIsNotNil(frameIndex, 'frameIndex', 'IsShownInConfig(frameIndex)')
        local actualFrameIsShown = frame:IsShown()
        P:SetBarEnabledState(frameIndex, actualFrameIsShown)
        return P:IsBarEnabled(frameIndex)
    end

    function widget:IsShowIndex() return P:IsShowIndex(self:GetFrameIndex()) end
    function widget:IsShowKeybindText() return P:IsShowKeybindText(self:GetFrameIndex()) end

    ---@param state boolean true will show button indices
    function widget:ShowButtonIndices(state)
        local theState = (state == true)
        self:GetConfig().show_button_index = theState
        ---@param btn ButtonUIWidget
        self:ApplyForEachButtons(function(btn) btn:ShowIndex(theState) end)
    end
    ---@param state boolean true will show button indices
    function widget:ShowKeybindText(state)
        local theState = (state == true)
        self:GetConfig().show_keybind_text = theState
        ---@param btn ButtonUIWidget
        self:ApplyForEachButtons(function(btn)
            btn:ShowKeybindText(theState)
            btn:UpdateKeybindTextState()
        end)
    end

    function widget:UpdateKeybindText()
        self:ShowKeybindText(self:IsShowKeybindText())
    end

    ---@param applyFunction function(ButtonUIWidget) Should be in format function(buttonWidget) {}
    function widget:ApplyForEachButtons(applyFunction)
        if #self.buttons <= 0 then return end
        -- `_` is the index
        for _, btnName in ipairs(self:GetButtons()) do
            applyFunction(_G[btnName].widget)
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
        if self:IsFrameEnabledInConfig() then self:ShowGroup() end
    end

    function widget:ShowButtons()
        local isShowKeybindText = self:IsShowKeybindText()
        ---@param btnWidget ButtonUIWidget
        self:ApplyForEachButtons(function(btnWidget)
            btnWidget:ShowKeybindText(isShowKeybindText)
            btnWidget.button:Show()
        end)
    end

    ---@param state boolean
    function widget:UpdateActionButtonMouseoverState(state)
        ---@param btnWidget ButtonUIWidget
        self:ApplyForEachButtons(function(btnWidget)
            btnWidget:SetHighlightEnabled(state)
        end)
    end

    function widget:HideButtons()
        for _, btnName in ipairs(self.buttons) do _G[btnName]:Hide() end
    end

    function widget:AddButton(buttonName)
        if type(buttonName) ~= 'string' then return end
        tinsert(self.buttons, buttonName)
    end

    function widget:GetButtonCount() return #self.buttons end
    function widget:GetButtons() return self.buttons end
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
        ---@param w ButtonUIWidget
        self:ApplyForEachButtons(function(w)
            w.button:SetAlpha(buttonAlpha)
        end)
    end

    function widget:UpdateEmptyButtonsSettings()
        ---@param w ButtonUIWidget
        self:ApplyForEachButtons(function(w)
            if not w:IsEmpty() then return end
            w:SetNormalIconAlphaAsEmpty()
            w:UpdateKeybindTextState()
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
        ---@param btnWidget ButtonUIWidget
        self:ApplyForEachButtons(function(btnWidget) btnWidget:SetButtonLayout() end)
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
end

---@return _Frame
function _L:GetFrameByIndex(frameIndex)
    local frameName = P:GetFrameNameByIndex(frameIndex)
    return _G[frameName]
end

function _L:IsFrameShownByIndex(frameIndex)
    return self:GetFrameByIndex(frameIndex):IsShown()
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
        frameStrata = frameStrata,
        frameLevel = 1,
        frame = f,
        ---@type FrameHandle
        frameHandle = nil,
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

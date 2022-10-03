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
---@type Blizzard_AnchorUtil
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
    end)
end

---@param frameWidget FrameWidget
local function OnActionbarFrameAlphaUpdated(frameWidget, event, sourceFrameIndex)
    p:log(20,'%s: frame #%s ', event, frameWidget:GetFrameIndex())
    local barConf = frameWidget:GetConfig()
    if barConf.widget.alpha < 0 then return end
    frameWidget.frame.background:SetAlpha(barConf.widget.alpha)
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

local function OnActionbarShowGrid(frameWidget, e, ...)
    ---@param btnWidget ButtonUIWidget
    frameWidget:ApplyForEachButtons(function(btnWidget)
        btnWidget:ShowGrid()
    end)
end
local function OnActionbarHideGrid(frameWidget, e, ...)
    ---@param btnWidget ButtonUIWidget
    frameWidget:ApplyForEachButtons(function(btnWidget)
        btnWidget:HideGrid()
    end)
end

-----@param frameWidget FrameWidget
--local function OnUnitSpellcastSent(frameWidget, e, ...)
--    ---@type Spellcast_Event_Data
--    local args = ...
--    --p:log('F%s %s: %s', frameWidget.index, e, args)
--    -----@param w ButtonUIWidget
--    --frameWidget:ApplyForEachButtons(function(w)
--    --    if w:IsEmpty() or not w:IsShown() then return end
--    --    if w:IsMatchingSpellID(args.spellID) then
--    --        --p:log('matches: %s', w:GetName())
--    --        w:SetHighlightInUse()
--    --    end
--    --end)
--end
--
-----@param frameWidget FrameWidget
--local function OnCurrentSpellcastChanged(frameWidget, e, ...)
--    local isCancelled = ...
--    local visible = frameWidget.frame:IsVisible()
--    if not (visible or isCancelled) then return end
--
--    --p:log('F%s %s: canclled=%s visible=%s',
--    --        frameWidget.index, e, isCancelled, visible)
--    ---@param w ButtonUIWidget
--
--    frameWidget:ApplyForEachButtons(function(w)
--        if w:IsEmpty() or not w:IsShown() then return end
--        w:SetHighlightDefault()
--    end)
--end
--
-----#### Non-Instant Start-Cast Handler
-----@param widget ButtonUIWidget
-----@param event string Event string
--local function OnSpellCastStart(frameWidget, event, ...)
--    if not frameWidget.frame:IsVisible() then return end
--    local unitTarget, castGUID, spellID = ...
--    if 'player' ~= unitTarget then return end
--
--    frameWidget:ApplyForEachButtons(function(w)
--        if w:IsEmpty() or not w:IsShown() then return end
--        --p:log('%s: %s', event, { unitTarget })
--        local btnConf = w:GetConfig()
--        if w:IsMatchingSpellID(spellID, btnConf) then
--            p:log(10, 'OnSpellCastStart| Is matching type[%s] spellID[%s]', btnConf.type, spellID)
--            w:SetHighlightInUse()
--        end
--    end)
--end

local function RegisterCallbacks(widget)
    widget:SetCallback(E.OnAddonLoaded, OnAddonLoaded)
    widget:SetCallback(E.OnCooldownTextSettingsChanged, OnCooldownTextSettingsChanged)
    widget:SetCallback(E.OnTextSettingsChanged, OnTextSettingsChanged)
    widget:SetCallback(E.OnMouseOverGlowSettingsChanged, OnMouseOverGlowSettingsChanged)
    widget:SetCallback(E.OnButtonSizeChanged, OnButtonSizeChanged)
    widget:SetCallback(E.OnActionbarFrameAlphaUpdated, OnActionbarFrameAlphaUpdated)
    widget:SetCallback(O.FrameHandleMixin.E.OnDragStop_FrameHandle, OnDragStop_FrameHandle)
    widget:SetCallback("OnActionbarShowGrid", OnActionbarShowGrid)
    widget:SetCallback("OnActionbarHideGrid", OnActionbarHideGrid)
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
    --widget:RegisterEvent(E.UNIT_SPELLCAST_START, OnSpellCastStart, widget)
end

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

        ---@type Blizzard_RegionAnchor
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
        self:ApplyForEachButtons(function(btn) btn:ShowKeybindText(theState) end)
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

---@return Frame
function _L:GetFrameByIndex(frameIndex)
    local frameName = P:GetFrameNameByIndex(frameIndex)
    return _G[frameName]
end

function _L:IsFrameShownByIndex(frameIndex)
    return self:GetFrameByIndex(frameIndex):IsShown()
end

function _L:Constructor(frameIndex)

    ---@class Frame
    local f = self:GetFrameByIndex(frameIndex)
    --TODO: NEXT: Move frame strata to Settings
    local frameStrata = 'MEDIUM'
    f:SetFrameStrata(frameStrata)
    --todo next if background is transparent (in settings/future), then
    --      set alpha to zero
    ---@class FrameWidget : WidgetBase
    local widget = {
        profile = P,
        index = frameIndex,
        frameHandleHeight = 5,
        dragHandleHeight = 0,
        padding = 2,
        frameStrata = frameStrata,
        frameLevel = 1,
        frame = f,
        ---@see FrameHandleMixin#Constructor()
        frameHandle = nil,
    }
    -- Allows call to Use callbacks / RegisterEvent
    AceEvent:Embed(widget)

    widget.frame = f
    f.widget = widget

    local fh = ABP_CreateFrameHandle(widget)
    fh:Show()

    RegisterWidget(widget, f:GetName() .. '::Widget')
    WidgetMethods(widget)
    RegisterCallbacks(widget)
    RegisterEvents(widget)

    widget:SetFrameDimensions()

    local frameAlpha = widget:GetConfig().widget.alpha or 0.5
    f.background:SetAlpha(frameAlpha)


    return widget
end

_L.mt.__call = _L.Constructor

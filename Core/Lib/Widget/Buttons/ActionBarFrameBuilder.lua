--
-- Module: ActionBarFrameBuilder
-- Creates the actionbar frame (anchor) for the buttons
--

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local _G = _G
local format, ipairs = string.format, ipairs
local tinsert, tsort = table.insert, table.sort

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateAnchor, GridLayoutMixin = CreateAnchor, GridLayoutMixin

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
--- @type _AnchorUtil
local AnchorUtil = AnchorUtil

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, LibStub, LC = ns.O, ns.GC, ns.LibStub, ns:LC()
local Assert, P = ns:Assert(), O.Profile
local AceGUI = ns:AceLibrary().AceGUI
local M, MSG = GC.M, GC.M
local configHandler = O.Settings
local evt = ns:AceEvent()

--- @see _ParentFrame.xml
local frameTemplate = 'ActionbarPlusFrameTemplate'

-- post combat updates (SetAttribute* is not allowed during combat)
local PostCombatButtonUpdates = {}
local libName = ns.M.ActionBarFrameBuilder
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class ActionBarFrameBuilder : BaseLibraryObject
local L = LibStub:NewLibrary(libName); if not L then return end
local p = LC.FRAME:NewLogger(libName)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function fh() return O.FrameHandleBuilderMixin end
local function abh() return O.ActionBarHandlerMixin end
local function abo() return O.ActionBarOperations end

--- @param widget ActionBarFrameWidget
--- @param name string The widget name.
local function RegisterWidget(widget, name)
    assert(widget ~= nil)
    assert(name ~= nil)

    --- WidgetBase provides convenience functions
    --- for self.frame operations
    --- @see Ace3/WidgetBase
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

--- @param fw ActionBarFrameWidget
local function InitAnchor(fw)
    local frame = fw.frame
    local anchor = P:GetAnchor(fw.index)
    local relativeTo = anchor.relativeTo and _G[anchor.relativeTo] or nil
    if frame:IsShown() then
        p:f1(function()
            return 'InitAnchor| anchor-from-profile[f.%s]: %s', fw.index, anchor
        end)
    end
    if InCombatLockdown() then return end
    frame:ClearAllPoints()
    frame:SetPoint(anchor.point, relativeTo , anchor.relativePoint, anchor.x, anchor.y)
end

--- Show delayed due to anchor not setting until UI is fully loaded
--- Event is fired from ActionbarPlus#OnAddonLoaded.
--- Avoid taint() and return if in combat
--- @param fw ActionBarFrameWidget
local function OnAddOnReady(fw)
    if InCombatLockdown() then return end
    C_Timer.After(0.1, function() InitAnchor(fw) end)
end

---@param widget ActionBarFrameWidget
local function RegisterMessages(widget)
    --- Use new AceEvent each time or else, the message handler will only be called once
    evt:RegisterMessage(M.OnAddOnReady, function() OnAddOnReady(widget) end)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param widget __ActionBarFrameWidget | Frame
local function WidgetMethods(widget)
    local AssertThatMethodArgIsNotNil = Assert.AssertThatMethodArgIsNotNil

    local profile = widget.profile
    local frame = widget.frame

    --- @return Name
    function widget:GetName() return frame:GetName() end

    --- This is the button UI name. No longer the config name.
    --- @param btnIndex Index
    --- @return Name
    function widget:GetButtonUIName(btnIndex) return self:GetName() .. 'Button' .. btnIndex end
    --- @return Index
    function widget:GetIndex() return self.index end

    --- @return Profile_Bar
    function widget:conf() return profile:GetBar(self:GetIndex()) end

    --- @deprecated Use #conf
    --- @return Profile_Bar
    function widget:GetConfig() return profile:GetBar(self:GetIndex()) end

    function widget:UpdateAnchor()
        local n = frame:GetNumPoints()
        if n <= 0 then return end

        --- @type _RegionAnchor
        local frameAnchor = AnchorUtil.CreateAnchorFromPoint(frame, 1)
        p:f3(function() return "New Frame Anchor: %s", frameAnchor end)
        P:SaveAnchor(frameAnchor, self.index)
    end

    function widget:ResetAnchor()
        local f = self.frame
        f:ClearAllPoints()
        f:SetPoint('CENTER', nil, 'CENTER', 0, 0)
        self:UpdateAnchor()
    end

    --- @return boolean
    function widget:IsLockedInCombat() return profile:IsBarLockedInCombat(self:GetIndex()) end
    function widget:SetCombatLockState() if self:IsLockedInCombat() then self:LockGroup() end end
    function widget:SetCombatUnlockState() if self:IsLockedInCombat() then self:UnlockGroup() end end

    --- @return boolean
    function widget:IsFrameEnabledInConfig() return P:IsBarEnabled(self:GetIndex()) end

    ---@param isEnabled boolean
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

    --- @return boolean
    function widget:IsShownInConfig() return P:IsBarEnabled(self.index) end
    --- @return boolean
    function widget:IsShowIndex() return P:IsShowIndex(self:GetIndex()) end
    --- @return boolean
    function widget:IsShowKeybindText() return P:IsShowKeybindText(self:GetIndex()) end

    --- @param state boolean true will show button indices
    function widget:ShowButtonIndices(state)
        local theState = (state == true)
        self:GetConfig().show_button_index = theState
        abh():ForEachButton(function(bw) bw:ShowIndex(theState) end)
    end

    ---@param isShown boolean
    function widget:SetGroupState(isShown)
        if isShown == true then
            if self.ShowGroup then self:ShowGroup() end
            return
        end
        if self.HideGroup then self:HideGroup() end
    end

    function widget:LockGroup() if InCombatLockdown() then return end; self.frameHandle:Hide() end
    function widget:UnlockGroup() if InCombatLockdown() then return end; self.frameHandle:Show() end
    function widget:Hide() if InCombatLockdown() then return end; frame:Hide() end
    function widget:Show() if InCombatLockdown() then return end; frame:Show() end

    function widget:HideGroup()
        self:Hide()
        self:HideButtons()
        evt:SendMessage(MSG.OnActionBarHideGroup, libName, self)
    end

    function widget:ShowGroup()
        InitAnchor(self)
        self:Show()
        self:ShowButtons()
        evt:SendMessage(MSG.OnActionBarShowGroup, libName, self)
    end

    --- @param predicateFn ButtonHandlerFunction | "function(btnWidget) return btnWidget:IsEmpty() end"
    --- @return ButtonUI
    function widget:FindFirst(predicateFn)
        for _, btn in ipairs(self.buttonFrames) do
            if predicateFn(btn.widget) then return btn end
        end
    end

    --- This is for resizing the rows and cols.
    --- If the button gets deleted due to rows and cols getting smaller,
    --- then try and find and empty button to save to.
    --- @see ButtonFactory#Init() Currently Disabled
    --- @param btnName string
    function widget:SaveButton(btnName)
        --- @type ButtonUI
        local sourceBtn = _G[btnName]; if not sourceBtn then return end
        local sourceWidget = sourceBtn.widget; if sourceWidget:IsEmpty() then return end

        local targetBtn = self:FindFirst(function(btnWidget)
            if btnWidget:IsEmpty() then return btnWidget end
        end)
        if not targetBtn then return end
        local conf = sourceWidget:conf()

        local btnWidget = targetBtn.widget
        local setter = btnWidget:GetAttributesSetter(conf.type)
        if setter then
            Mixin(btnWidget:conf(), conf)
            setter:SetAttributes(btnWidget.button())
            btnWidget:UpdateDelayed()
            btnWidget:EnableMouse(true)
        end
        sourceWidget:SetButtonAsEmpty()
    end

    function widget:ScrubEmptyButtons()
        abh():ForEachButton(function(bw)
            P:CleanupActionTypeData(bw.frameIndex, bw:GetName())
        end)
        self:SaveAndScrubDeletedButtons()
    end

    --- @param saveExisting BooleanOptional
    function widget:SaveAndScrubDeletedButtons(saveExisting)
        local save = saveExisting == true

        local barConf = self:conf()
        local start = (barConf.widget.rowSize * barConf.widget.colSize) + 1

        for i = start, configHandler.maxButtons do
            local uiName     = self:GetButtonUIName(i)
            local configName = P:GetButtonConfigName(uiName)
            if save == true then self:SaveButton(uiName) end
            if barConf.buttons[configName] then barConf.buttons[configName] = nil end
        end
    end

    function widget:HideUnusedButtons()
        local start = self:GetButtonCount() + 1
        local max =  O.Settings.maxButtons
        for i=start, max do
            --- @type ButtonUI
            local existingBtn = self:GetButtonUI(i)
            if existingBtn then existingBtn.widget:Hide() end
        end
    end

    function widget:ShowGroupIfEnabled()
        if self:IsFrameEnabledInConfig() then
            self:ShowGroup()
            return
        end
        self:HideGroup()
    end

    function widget:ShowButtons()
        abh():ForEachButton(function(bw)
            bw:Show()
            bw:UpdateUsable()
        end)
    end

    --- @param state boolean
    function widget:UpdateActionButtonMouseoverState(state)
        abh():ForEachButton(function(bw)
            bw:SetHighlightEnabled(state)
        end)
    end

    function widget:HideButtons()
        --- @param bf ButtonUI
        for _, bf in ipairs(self.buttonFrames) do
            bf.widget:Hide()
        end
    end

    --- @param buttonFrame ButtonUI
    function widget:AddButtonFrame(buttonFrame)
        if not buttonFrame then return end
        tinsert(self.buttonFrames, buttonFrame)
    end

    --- @return Count
    function widget:GetButtonCount() return #self.buttonFrames end
    --- @return boolean
    function widget:HasEmptyButtons() return self:GetButtonCount() <= 0 end
    --- hard code max button column size for now
    --- @return number
    function widget:GetMaxButtonColSize() return 40 end

    --- @return table<number, ButtonUI>
    function widget:GetButtons() return self.buttonFrames end

    --- Return a list of button frames that are currently visible
    --- @return table<number, ButtonUI>
    function widget:GetVisibleButtonFrames()
        --- @type table<number, ButtonUI>
        local visible = {}
        for _, btn in ipairs(self.buttonFrames) do
            if not btn.widget:IsHidden() then tinsert(visible, btn) end
        end
        return visible
    end
    --- @return boolean
    function widget:IsRendered() return self.rendered end
    --- @return boolean
    function widget:IsNotRendered() return not self:IsRendered() end
    function widget:MarkRendered() self.rendered = true end

    function widget:SetInitialState()
        self:MarkRendered()
        self:SetLockedState()
        self:ShowButtonIndices(self:IsShowIndex())
        self:SetInitialStateOnFrameHandle()
        self:UpdateButtonAlpha()
        C_Timer.After(0.1, function()
            abh():ForEachButton(function(bw)
                -- solved the problem of buttons being disabled
                -- after a primary talent switch
                bw:EnableMouse(not bw:IsEmpty())
            end)
        end)
    end

    function widget:SetInitialStateOnFrameHandle() self.frameHandle:UpdateBackdropState() end

    function widget:UpdateButtonAlpha()
        local barConf = self:GetConfig()
        local buttonAlpha = barConf.widget.buttonAlpha
        if not buttonAlpha or buttonAlpha < 0 then buttonAlpha = 1.0 end
        for _, btn in ipairs(self.buttonFrames) do
            btn:SetAlpha(buttonAlpha)
        end
    end

    function widget:UpdateFrameHandleAlpha()
        local barConf = self:GetConfig()
        self.frameHandle:SetAlpha(barConf.widget.frame_handle_alpha or 1.0)
    end

    function widget:SetLockedState()
        local frameIndex = self:GetIndex()
        if P:IsBarLockedAlways(frameIndex) then
            self:LockGroup()
        else P:IsBarUnlocked(frameIndex)
            self:UnlockGroup()
        end
    end

    --- @NotCombatSafe
    function widget:SetFrameDimensions()
        if InCombatLockdown() then return end

        local barData = self:GetConfig()
        local widgetData = barData.widget
        local f = self.frame
        local frameHandle = self.frameHandle

        local colSize = widgetData.colSize
        local rowSize = widgetData.rowSize
        local buttonSize = widgetData.buttonSize or 36

        local paddingX = self.horizontalButtonPadding or 0
        local paddingY = self.verticalButtonPadding or 0

        local widthAdj = self.padding or 0
        local heightAdj = (self.padding or 0) + (self.dragHandleHeight or 0)

        -- Frame dimensions to correctly account for spacing
        local visualFixOffset = 3
        local frameWidth  = (colSize * buttonSize) + ((colSize - 1) * paddingX) + widthAdj - visualFixOffset
        local frameHeight = (rowSize * buttonSize) + ((rowSize - 1) * paddingY) + heightAdj

        frameHandle:SetWidth(frameWidth)
        frameHandle:SetHeight(self.frameHandleHeight)

        f:SetWidth(frameWidth)
        f:SetHeight(frameHeight)

        --TODO: Clears the backdrop
        -- frame backdrop when button is empty state
        --f:ClearBackdrop()
        --f:SetBackdrop(BACKDROP_GOLD_DIALOG_32_32)
        --f:ApplyBackdrop()
        --f:SetAlpha(0)
end

    function widget:ClearButtons() self.buttonFrames = {} end

    --- @return ButtonUI
    function widget:GetButtonUI(buttonIndex) return _G[self:GetButtonUIName(buttonIndex)] end

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
        --- @param row number
        --- @param col number
        function layout:GetCustomOffset(row, col) return 0, 0 end

        --- @type _AnchorMixin
        local anchor = CreateAnchor("TOPLEFT", self:GetName(), "TOPLEFT", 0, -2);
        AnchorUtil.GridLayout(self.buttonFrames, anchor, layout);
    end

    --- @param rows number
    --- @param cols number
    function widget:SetButtonCount(rows, cols)
        assert(rows > 0 and cols > 0, 'Rows and Cols must be > 0')
        local wc = self:conf().widget
        wc.rowSize = rows
        wc.colSize = cols
        evt:SendMessage(MSG.OnButtonCountChanged, libName, self.index)
    end

    --- @param width number
    function widget:SetButtonWidth(width)
        assert(width > 10, 'Button width must be > 0')
        local wc = self:conf().widget
        wc.buttonSize = width
        evt:SendMessage(MSG.OnButtonSizeChanged, libName, self.index)
    end

    --- @param alpha Alpha
    function widget:SetButtonAlpha(alpha)
        assert(alpha > 0 and alpha <= 1.0, 'Alpha must be [0.0, 1.0]')
        local wc = self:conf().widget
        wc.buttonAlpha = alpha
        evt:SendMessage(MSG.OnActionbarFrameAlphaUpdated, libName, self.index)
    end

end

-- todo: delete PostCombat. This was for dragging buttons during combat. That is no longer allowed.
--- @param btnWidget ButtonUIWidget
function L:AddPostCombatUpdate(btnWidget) table.insert(PostCombatButtonUpdates, btnWidget) end

-- todo: delete this. This was for dragging buttons during combat. That is no longer allowed.
function L:PostCombatUpdateComplete()
    local count = #PostCombatButtonUpdates
    if count <= 0 then return end
    --- @param widget ButtonUIWidget
    for i, widget in ipairs(PostCombatButtonUpdates) do
        widget:SetButtonAttributes()
        PostCombatButtonUpdates[i] = nil
    end
end

--- Creates the Initial ActionBarFrame(s)
--- @param consumerFn ActionBarFrameBuilderConsumerFn
function L:CreateActionBarFrames(consumerFn)
    for i=1, abh():o():GetActionbarFrameCount() do
        local actionbarFrame = abo():CreateBarFrame(i)
        consumerFn(actionbarFrame:GetName(), i)
    end
end

--- @NotCombatSafe
--- @param frameIndex number
--- @public
--- @return ActionBarFrameWidget
function L:New(frameIndex)
    if InCombatLockdown() then return end

    --- @class __ActionBarFrame : Frame
    local f = abo():GetFrameByIndex(frameIndex)
    --- @alias ActionBarFrame __ActionBarFrame

    --TODO: NEXT: Move frame strata to Settings
    local frameStrata = 'MEDIUM'
    f:SetFrameStrata(frameStrata)
    -- Alpha needs to be zero so that we can hide the buttons
    f:SetAlpha(0)
    f:SetClampedToScreen(true)

    --- @alias ActionBarFrameWidget __ActionBarFrameWidget | _Frame
    --- @class __ActionBarFrameWidget : WidgetBase
    local __widget = {
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
        --- @type ActionBarFrame
        frame = f,
        --- @type FrameHandle
        frameHandle = nil,
        rendered = false,
        --- @type table<number, ButtonUI>
        buttonFrames = {}
    }

    --- @type ActionBarFrameWidget
    local widget = __widget

    -- Allows call to Use callbacks / RegisterEvent
    ns:AceEvent(widget)

    widget.frame = f
    f.widget = widget

    widget.frameHandle = fh():New(widget)
    widget.frameHandle:Show()

    RegisterWidget(widget, f:GetName() .. '::Widget')
    WidgetMethods(widget)
    RegisterMessages(widget)

    widget:SetFrameDimensions()

    return widget
end


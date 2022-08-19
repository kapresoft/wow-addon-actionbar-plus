--
-- ButtonFrameFactory
--
--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local _G = _G
local format, type, ipairs, tinsert = string.format, type, ipairs, table.insert

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame, BackdropTemplateMixin = CreateFrame, BackdropTemplateMixin

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub, M, Assert, P, LSM, _, _, G = ABP_WidgetConstants:LibPack()
local _, Table, String, LogFactory = ABP_LibGlobals:LibPackUtils()
local AceEvent, AceGUI = G:LibPack_AceLibrary()

local toStringSorted = Table.toStringSorted
---@class ButtonFrameFactory
local _L = LibStub:NewLibrary(M.ButtonFrameFactory)

---@type LogFactory
local p = LogFactory:NewLogger('ButtonFrameFactory')

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

local function RegisterCallbacks(widget)

    ---@param fw FrameWidget
    widget:SetCallback('OnRefreshSpellCooldowns', function(fw, event, ...)
        local sourceEvent, spellID = ...
        --local params = { sourceEvent=sourceEvent, spellID=spellID, delay=delay }
        --p:log('%s: %s params=%s', fw:GetName(), event, toStringSorted(params))
        for _, btnName in ipairs(fw:GetButtons()) do
            ---@type ButtonUIWidget
            _G[btnName].widget:Fire(sourceEvent)
        end

    end)

    ---@param fw FrameWidget
    widget:SetCallback('OnRefreshItemCooldowns', function(fw, event, ...)
        for _, btnName in ipairs(fw:GetButtons()) do
            ---@type ButtonUIWidget
            _G[btnName].widget:UpdateState()
        end
    end)

end

---@param widget FrameWidget
local function RegisterEvents(widget)
    local C = ABP_WidgetConstants.C
    ---@param w FrameWidget
    local function OnPlayerEnterCombat(w) w:SetCombatLockState() end
    ---@param w FrameWidget
    local function OnPlayerLeaveCombat(w) w:SetCombatUnlockState() end
    widget:RegisterEvent(C.PLAYER_REGEN_DISABLED, OnPlayerEnterCombat, widget)
    widget:RegisterEvent(C.PLAYER_REGEN_ENABLED, OnPlayerLeaveCombat, widget)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param widget FrameWidget
local function WidgetMethods(widget)
    local AssertThatMethodArgIsNotNil = Assert.AssertThatMethodArgIsNotNil

    widget.rendered = false
    widget.buttons = {}
    local frame = widget.frame

    function widget:GetName()
        return widget.frame:GetName()
    end

    ---@deprecated Use self#GetIndex()
    function widget:GetFrameIndex() return self:GetIndex() end
    function widget:GetIndex() return self.index end

    ---@return BarData
    function widget:GetConfig()
        return P:GetBar(self:GetIndex())
    end

    function widget:Toggle()
        if self:IsShown() then self:Hide(); return end
        self:Show()
    end

    function widget:IsLockedInCombat() return P:IsBarLockedInCombat(self:GetFrameIndex()) end
    function widget:SetCombatLockState() if self:IsLockedInCombat() then self:LockGroup() end end
    function widget:SetCombatUnlockState() if self:IsLockedInCombat() then self:UnlockGroup() end end

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
        self:ApplyForEachButtons(function(btn)
            --p:log('apply[%s]: %s', btn:GetName(), theState)
            btn:ShowIndex(theState)
        end)
    end
    ---@param state boolean true will show button indices
    function widget:ShowKeybindText(state)
        local theState = (state == true)
        self:GetConfig().show_keybind_text = theState
        ---@param btn ButtonUIWidget
        self:ApplyForEachButtons(function(btn)
            --p:log('ShowKeyBindText[%s]: %s', btn:GetName(), theState)
            btn:ShowKeybindText(theState)
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

    function widget:ToggleGroup()
        if #self.buttons > 0 then
            local firstBtn = _G[self.buttons[1]]
            if firstBtn:IsShown() then self:HideGroup()
            else self:ShowButtons() end
        end
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

    function widget:ShowButtons()
        local isShowKeybindText = self:IsShowKeybindText()
        ---@param btnWidget ButtonUIWidget
        self:ApplyForEachButtons(function(btnWidget)
            btnWidget:ShowKeybindText(isShowKeybindText)
            btnWidget.button:Show()
        end)
    end

    function widget:HideButtons()
        for _, btnName in ipairs(self.buttons) do
            _G[btnName]:Hide()
        end
    end

    function widget:AddButton(buttonName)
        if type(buttonName) ~= 'string' then return end
        tinsert(self.buttons, buttonName)
    end

    function widget:GetButtonCount() return #self.buttons end

    function widget:GetButtons()
        return self.buttons
    end

    function widget:IsRendered()
        return self.rendered
    end

    function widget:IsNotRendered()
        return not self:IsRendered()
    end

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

    function widget:MarkRendered()
        self.rendered = true
    end

    function widget:RefreshActionbarFrame()
        local barData = self:GetBarData()
        local rowSize = barData.widget.rowSize or 1
        local colSize = barData.widget.colSize or 6
        self:SetFrameDimensions()

        local index = 0
        local frameName = self:GetName()
        for row=1, rowSize do
            for col=1, colSize do
                index = index + 1
                local btnName = format('%sButton%s', frameName, tostring(index))
                ---@type ButtonUIWidget
                local btnWidget = _G[btnName].widget
                btnWidget:Resize(row, col)
            end
        end
    end

    function widget:SetFrameDimensions()
        local barData = self:GetBarData()
        local widgetData = barData.widget
        local f = self.frame
        local frameHandle = self.frameHandle
        local widthAdj = self.padding
        local heightAdj = self.padding + self.dragHandleHeight
        local frameWidth = (widgetData.colSize * widgetData.buttonSize) + widthAdj
        frameHandle:SetWidth(frameWidth)
        f:SetWidth(frameWidth)
        f:SetHeight((widgetData.rowSize * widgetData.buttonSize) + heightAdj)
    end
end

--local function getProfileUtil()
--    if not P then P = WidgetLibFactory:GetProfile() end
--    return P
--end

---@return Frame
function _L:GetFrameByIndex(frameIndex)
    local frameName = P:GetFrameNameByIndex(frameIndex)
    return _G[frameName]
end

function _L:IsFrameShownByIndex(frameIndex)
    return self:GetFrameByIndex(frameIndex):IsShown()
end

function _L:Constructor(frameIndex)
    local FrameBackdrop = {
        ---@see LibSharedMedia
        --bgFile = LSM:Fetch(LSM.MediaType.BACKGROUND, "Blizzard Marble"),
        bgFile = LSM:Fetch(LSM.MediaType.BACKGROUND, "Solid"),
        --edgeFile = LSM:Fetch(LSM.MediaType.BORDER, "Blizzard Dialog"),
        tile = false, tileSize = 26, edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    }
    local FrameHandleBackdrop = {
        ---@see LibSharedMedia
        bgFile = LSM:Fetch(LSM.MediaType.BACKGROUND, "Solid"),
        tile = false, tileSize = 26, edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    }

    ---@class Frame
    local f = self:GetFrameByIndex(frameIndex)
    local fh = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate" or nil)
    --fh:SetToplevel(true)

    ---@class FrameWidget
    local widget = {
        p = p,
        profile = P,
        index = frameIndex,
        ---deprecated: Use index instead
        frameIndex = frameIndex,
        GetBarData = function() return P:GetBar(frameIndex) end,
        --options = barData.widget,
        frameHandleHeight = 4,
        dragHandleHeight = 0,
        padding = 2,
        frameStrata = 'LOW',
        frame = f,
        frameHandle = fh
    }
    -- Allows call to RegisterEvent
    AceEvent:Embed(widget)

    widget.frame = f
    f.widget, fh.widget = widget, widget

    f:SetFrameStrata(widget.frameStrata)
    f:SetBackdrop(FrameBackdrop)
    f:SetBackdropColor(1/255, 1/255, 1/255, 1)

    fh:SetBackdrop(FrameHandleBackdrop)
    fh:SetBackdropColor(235/255, 152/255, 45/255, 1)
    fh:EnableMouse(true)
    fh:SetMovable(true)
    fh:SetResizable(true)
    fh:SetHeight(widget.frameHandleHeight)
    fh:SetFrameStrata(widget.frameStrata)
    fh:SetPoint("BOTTOM", f, "TOP", 0, 1)
    fh:SetScript("OnLoad", function() self:RegisterForDrag("LeftButton"); end)
    -- TODO: Overridden in ButtonFactory, will migrate it here
    -- fh:SetScript("OnMouseDown", function() f:StartMoving(); end)
    fh:SetScript("OnMouseUp", function() f:StopMovingOrSizing(); end)
    fh:SetScript("OnDragStart", function() f:StartMoving();  end)
    fh:SetScript("OnDragStop", function() f:StopMovingOrSizing(); end)
    fh:Show()

    RegisterWidget(widget, f:GetName() .. '::Widget')
    WidgetMethods(widget)
    RegisterCallbacks(widget)
    RegisterEvents(widget)

    widget:SetFrameDimensions()

    return widget
end

_L.mt.__call = _L.Constructor

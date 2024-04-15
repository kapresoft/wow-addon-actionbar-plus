--[[-----------------------------------------------------------------------------
PlayerSettingsController: Handles the features configured in Settings
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC
local MSG = GC.M
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'PlayerSettingsController'
--- @class PlayerSettingsController
local L = ns:NewController(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o PlayerSettingsController | ControllerV2
local function PropsAndMethods(o)

    function o.OnCombatLockState()
        o:o():SetActionBarsLockState(true);
    end

    function o.OnCombatUnlockState()
        o:o():SetActionBarsLockState(false);
    end

    function o.OnCooldownTextSettingsChanged()
        o:ForEachNonEmptyButton(function(bw) bw:RefreshTexts() end)
    end

    function o.OnTextSettingsChanged()
        o:ForEachNonEmptyButton(function(bw) bw:RefreshTexts() end)
    end

    function o.OnMouseOverGlowSettingsChanged()
        o:ForEachNonEmptyButton(function(bw) bw:RefreshHighlightEnabled() end)
    end

    --- @param frameIndex Index
    function o.OnButtonSizeChanged(msg, src, frameIndex)
        local fw = o:FrameForAllButton(frameIndex, function(bw)
            bw:SetButtonProperties()
            bw:RefreshTexts()
            bw:UpdateKeybindTextState()
        end); if not fw then return end
        fw:SetFrameDimensions()
        fw:LayoutButtonGrid()
    end

    --- @param frameIndex Index
    function o.OnButtonCountChanged(msg, src, frameIndex)
        p:vv(function() return 'OnButtonCountChanged() called: frameIndex=%s', frameIndex end)

        local fw = o:GetFrameByIndex(frameIndex); if not fw then return end
        if not fw:IsShownInConfig() then return end

        local barConfig = fw:GetConfig()
        local widget = barConfig.widget
        local bf = O.ButtonFactory
        fw:SetFrameDimensions()

        bf:CreateButtons(fw, widget.rowSize, widget.colSize)
        fw:HideUnusedButtons()

        fw:SetInitialState()
        fw:ShowGroupIfEnabled()

        fw = o:FrameForAllButton(frameIndex, function(bw)
            bw:SetButtonProperties()
            bw:RefreshTexts()
            bw:UpdateKeybindTextState()
        end)
        fw:SaveAndScrubDeletedButtons(true)
    end

    --- Automatically called
    --- @see ModuleV2Mixin#Init
    --- @private
    function o:OnAddOnReady()
        self:RegisterMessage(MSG.OnPlayerEnterCombat, o.OnCombatLockState)
        self:RegisterMessage(MSG.OnPlayerLeaveCombat, o.OnCombatUnlockState)
        self:RegisterMessage(MSG.OnCooldownTextSettingsChanged, o.OnCooldownTextSettingsChanged)
        self:RegisterMessage(MSG.OnTextSettingsChanged, o.OnTextSettingsChanged)
        self:RegisterMessage(MSG.OnMouseOverGlowSettingsChanged, o.OnMouseOverGlowSettingsChanged)
        self:RegisterMessage(MSG.OnButtonSizeChanged, o.OnButtonSizeChanged)
        self:RegisterMessage(MSG.OnButtonCountChanged, o.OnButtonCountChanged)
    end

end; PropsAndMethods(L)


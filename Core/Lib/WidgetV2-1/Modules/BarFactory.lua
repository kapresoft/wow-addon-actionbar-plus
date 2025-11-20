--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, MSG, LibStub = ns.O, ns.GC, ns.M, ns.GC.M, ns.LibStub
local P, PI = O.Profile, O.ProfileInitializer

--- todo next: move to bars config
local lcfg = {
    spacing = 6,
}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return BarFactory, Kapresoft_CategoryLogger
local function CreateLib()
    local libName = M.BarFactory or 'BarFactory'
    --- @class BarFactory : BaseLibraryObject
    local newLib = ns:NewLib(libName); if not newLib then return nil end
    local logger = ns:CreateDefaultLogger(libName)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end
p:v(function() return "Loaded: %s", L.name or tostring(L) end)

--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
---
--- @class ActionbarPlusF1Module : ActionbarPlusModule
--- @class ActionbarPlusF2Module : ActionbarPlusModule
--- @class ActionbarPlusF3Module : ActionbarPlusModule
--- @class ActionbarPlusF4Module : ActionbarPlusModule
--- @class ActionbarPlusF5Module : ActionbarPlusModule
--- @class ActionbarPlusF6Module : ActionbarPlusModule
--- @class ActionbarPlusF7Module : ActionbarPlusModule
--- @class ActionbarPlusF8Module : ActionbarPlusModule
--- @class ActionbarPlusF9Module : ActionbarPlusModule
--- @class ActionbarPlusF10Module : ActionbarPlusModule
---
---

--[[-----------------------------------------------------------------------------
Methods: BarModuleMixin
-------------------------------------------------------------------------------]]
--- @class BarModuleMixin
local bmm = {}

--- @param o BarModuleMixin | ActionbarPlusModule
local function PropsAndMethods(o)

    local pp = ns:LC().MODULE:NewLogger('ActionbarPlusModule')

    --- @return ActionbarPlusModule
    function o:New(index)
        -- Create the Ace module dynamically
        local name = "ActionbarPlusF" .. index .. 'Module'
        --self.nameShort = name
        --self.frameName = "ActionbarPlusF" .. index
        --self.index = index

        --- @class ActionbarPlusModule : AceModule
        --- @field index Index
        --- @field frameName Name The name of the frame instance
        --- @field barFrame ActionBarFrame
        ----------------------------------
        ----------------------------------
        local m = ns:a():NewModule(name, "AceEvent-3.0", "AceHook-3.0")
        if not m then return nil end

        --- @type ActionbarPlusModule
        local mod = ns:K():Mixin(m, o)
        -- set index here so it's available in OnInitialize()
        mod.index = index
        mod:Init()

        pp:f1(function() return '%s created; enabled=%s', m:GetName(), m:IsEnabled() end)

        -- Set Global
        -- example: ActionbarPlusF1Module
        _G[name] = m

        return mod
    end

    function o:Init()
        local baseName = 'ActionbarPlusF'
        self.nameShort = baseName .. self.index .. 'Module'
        self.frameName = baseName .. self.index
    end

    function o:GetDebugName() return 'ABP_Module::' .. self.nameShort end

    function o:SetInitialStateDelayed()
        C_Timer.After(0.01, function() self:SetInitialState() end)
    end

    function o:SetInitialState()
        local cfg = self:c()

        if cfg.enabled and self:IsEnabled() then return end
        if self:Disable() then
            pp:vv(function() return '[SetInitialState] Disabled; index=%s', self.index end)
        end
    end

    --- @return Profile_Bar
    function o:c() return P:GetBar(self.index) end

    function o:OnInitialize()
        pp:f1(function() return 'OnInitialize() called; index=%s', self.index end)
        self:SetInitialState()
    end

    function o:OnEnable()
        pp:vv(function() return 'OnEnable() called; index=%s', self.index end)
        return self.frame:Show()
    end
    function o:OnDisable()
        pp:vv(function() return 'OnDisable() called; index=%s', self.index end)
        return self.frame:Hide()
    end

end; PropsAndMethods(bmm)

--[[-----------------------------------------------------------------------------
Methods: BarFactory
-------------------------------------------------------------------------------]]
function L.OnAddOnEnabled(msg, source, addOn)
    p:vv('OnAddOnEnabled() called...')
    L:Init(bmm)
end

--- @param mixin BarModuleMixin
---@param consumerFn ActionBarFrameBuilderConsumerFn
function L:Init(mixin, consumerFn)
    for i = 1, PI.ActionbarCount do
        local mod = mixin:New(i)
        self:CreateBarGroup(mod)
    end
end

--- @param mod ActionbarPlusModule
function L:CreateBarGroup(mod)
    assert(mod)
    local index, frameName = mod.index, mod.frameName
    if _G[frameName] then return _G[frameName] end

    local cfg = mod:c()

    local cols = cfg.widget.colSize
    local rows = cfg.widget.rowSize
    local size = cfg.widget.buttonSize
    local spacing = lcfg.spacing

    --- @type ActionBarFrame
    local frame = L:CreateBarFrame(index)
    mod.frame = frame
    local buttons = L:CreateButtons(frame, index)
    frame.widget.buttonFrames = buttons

    ----------------------------------------------------
    -- resize bar frame based on cols x rows
    ----------------------------------------------------
    local paddingLeft  = 16
    local paddingRight = 16
    local paddingTop   = 16
    local paddingBottom = 16

    local totalWidth  = paddingLeft + (size + spacing) * (cols - 1) + size + paddingRight
    local totalHeight = paddingTop + size * rows + spacing * (rows - 1) + paddingBottom

    frame:SetSize(totalWidth, totalHeight)

    ----------------------------------------------------
    -- layout buttons using cols x rows
    ----------------------------------------------------
    local col, row = 1, 1

    for i, btn in ipairs(buttons) do
        btn:SetSize(size, size)
        btn:ClearAllPoints()

        -- compute row/col based on index
        local indexInGrid = i - 1
        col = (indexInGrid % cols) + 1
        row = math.floor(indexInGrid / cols) + 1

        -- starting offsets
        local startX = 16
        local startY = -paddingTop

        -- compute position
        local x = startX + (size + spacing) * (col - 1)
        local y = startY - (size + spacing) * (row - 1)

        -- anchor inside the frame
        btn:SetPoint("TOPLEFT", mod.frame, "TOPLEFT", x, y)
    end
end

--- @private
--- @param barIndex Index The frame index
--- @return ActionBarFrame
function L:CreateBarFrame(barIndex)
    ----------------------------------------------------
    -- create bar frame from XML virtual template
    ----------------------------------------------------
    local frameName = "ActionbarPlusF" .. barIndex

    --- @type ActionBarFrame
    local f = CreateFrame("Frame", frameName, UIParent, "ABP_BarFrameTemplate_V2_1_1")
    --f:SetScale(UIParent:GetScale())

    --- @type __ActionBarFrameWidget : WidgetBase
    local __widget = {
        index = barIndex,
        frameHandleHeight = 4,
        dragHandleHeight = 0,
        padding = 2,
        --todo next: add to options UI
        horizontalButtonPadding = 1,
        verticalButtonPadding = 1,
        frameStrata = 'MEDIUM',
        frameLevel = 1,
        --- @type ActionBarFrame
        frame = f,
        --- @type FrameHandle
        frameHandle = nil,
        rendered = false,
        --- @type table<number, ButtonUI>
        buttonFrames = {}
    }
    f.widget = __widget

    f:Hide()

    return f
end

--- @param barIndex Index
--- @param barFrame ActionBarFrame
function L:CreateButtons(barFrame, barIndex)
    local cfg = P:GetBar(barIndex)
    local btnSize = cfg.widget.buttonSize
    local cols = cfg.widget.colSize
    local rows = cfg.widget.rowSize
    local btnCount = rows * cols

    local buttons = {}
    for i = 1, btnCount do
        local btnName = GC:ButtonName(barIndex, i)
        --- @type CheckButton
        local btn = CreateFrame("CheckButton", btnName, barFrame, "ABP_ButtonTemplate_V2_1_1")
        btn:SetSize(btnSize, btnSize)
        table.insert(buttons, btn)
        p:f1(function() return 'Btn Created[%s]: %s', btn:GetID(), btn:GetName() end)
    end
    return buttons
end

L:RegisterMessage(MSG.OnAddOnEnabledV2, L.OnAddOnEnabled)

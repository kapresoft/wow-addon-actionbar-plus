--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, MSG, LibStub = ns.O, ns.GC, ns.M, ns.GC.M, ns.LibStub
local P, PI, BM = O.Profile, O.ProfileInitializer, O.BarModule

--- todo next: move to bars config
local lcfg = {
    spacing = 6,
}
local baseLevel = 1000
local baseName = 'ActionbarPlusF'

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
Methods: BarFactory
-------------------------------------------------------------------------------]]
function L.OnAddOnInitialized(msg, source, addOn)
    if not ns:IsV2() then return end
    p:vv('OnAddOnInitialized() called...')
    L:Init(BM)
end

--- @param mixin BarModuleMixin
function L:Init(mixin)
    for i = 1, PI.ActionbarCount do
        self:CreateBarGroup(i, function(barFrame)
            local mod = mixin:New(barFrame)
            mod:OnInitialize()
        end)
    end
end

--- @param barIndex Index The bar frame index
--- @param consumerFn BarFactoryConsumerFn
function L:CreateBarGroup(barIndex, consumerFn)
    assert(barIndex, 'Index is required.')

    local frameName = baseName .. barIndex
    if _G[frameName] then
        return consumerFn and consumerFn(_G[frameName])
    end

    local cfg = P:GetBar(barIndex)
    local cols = cfg.widget.colSize
    local rows = cfg.widget.rowSize
    local size = cfg.widget.buttonSize
    local spacing = lcfg.spacing

    --- @type ActionBarFrame
    local frame = L:CreateBarFrame(barIndex, frameName)
    local buttons = L:CreateButtons(frame, barIndex)
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
        btn:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
    end

    return consumerFn and consumerFn(frame)
end

--- @private
--- @param barIndex Index The frame index
--- @param frameName Name The frame name
--- @return ActionBarFrame
--- @param frameName Name
function L:CreateBarFrame(barIndex, frameName)
    assert(barIndex and frameName, 'Frame and index missing.')

    --- @type ActionBarFrame
    local f = CreateFrame("Frame", frameName, UIParent, "ABP_BarFrameTemplate_V2_1_1")
    f:SetFrameLevel(baseLevel + barIndex * 10)
    f:SetFrameStrata('MEDIUM')
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
        local btn = CreateFrame("CheckButton", btnName, barFrame,
                                "ABP_ButtonTemplate_V2_1_1")
        --btn:GetNormalTexture():SetDrawLayer("BACKGROUND", 0)

        btn:SetAttribute("type", "action");
        btn:SetAttribute("typerelease", "actionrelease");
        btn:SetAttribute("checkselfcast", true);
        btn:SetAttribute("checkfocuscast", true);
        btn:SetAttribute("checkmouseovercast", true);
        btn:RegisterForDrag("LeftButton", "RightButton");
        btn:RegisterForClicks("AnyDown", "LeftButtonDown", "RightButtonDown");

        if barIndex == 2 and i == 1 then
            local texture = select(3, GetSpellInfo("Lesser Heal"))
            p:vv(function() return 'xx Icon[%s]: %s', i, texture end)
            btn.icon:SetTexture(texture)
            btn.icon:SetAllPoints(btn)
            btn:SetAttribute('type', 'spell')
            btn:SetAttribute('spell', 'Lesser Heal(Rank 1)')
        end

        btn:SetSize(btnSize, btnSize)
        table.insert(buttons, btn)
        p:f1(function() return 'Btn Created[%s]: %s', btn:GetID(), btn:GetName() end)
    end
    return buttons
end

L:RegisterMessage(MSG.OnAddOnInitializedV2, L.OnAddOnInitialized)

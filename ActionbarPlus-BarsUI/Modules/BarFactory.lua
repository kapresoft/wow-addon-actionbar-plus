--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace_ABP_BarsUI
local ns = select(2, ...)
--[[-------------------------------------------------------------------
Temporary Config
---------------------------------------------------------------------]]
local barCount = 1

--- @class Profile_Bar_V2
--- @field buttons table<string, Profile_Button>
--- @field widget Profile_Bar_Widget
--- @field anchor Anchor
local Profile_Bar_Config = {
    --- show/hide the actionbar frame
    ["enabled"] = false,
    --- allowed values: {"", "always", "in-combat"}
    ["locked"] = "",
    --- shows the button index
    ["show_button_index"] = true,
    --- shows the keybind text TOP
    ["show_keybind_text"] = true,
    ["widget"] = {
        ["rowSize"] = 1,
        ["colSize"] = 8,
        ["buttonSize"] = 30,
        ["buttonAlpha"] = 0.1,
        ["frame_handle_mouseover"] = false,
        ["frame_handle_alpha"] = 1.0,
        ["show_empty_buttons"] = true
    },
    ["anchor"] = { point="CENTER", relativeTo=nil, relativePoint='CENTER', x=0.0, y=0.0 },
    ["buttons"] = {}
}


--- todo next: move to bars config
local lcfg = {
    spacing = 6,
}
local baseLevel = 1000
local baseName = 'ActionbarPlusF'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'BarFactory'
--- @class BarFactory
local newLib = {}
local p = ns:log(libName)

--- @type BarFactory
local o = newLib

--[[-----------------------------------------------------------------------------
Methods: BarFactory
-------------------------------------------------------------------------------]]
function o:Init()
    for i = 1, barCount do
        self:CreateBarGroup(i, function(barFrame)
            local mod =  ABPV2_BarModule:New(barFrame)
            mod:OnInitialize()
        end)
    end
end

--- @param barIndex Index The bar frame index
--- @param consumerFn BarFactoryConsumerFn
function o:CreateBarGroup(barIndex, consumerFn)
    assert(barIndex, 'Index is required.')

    local frameName = baseName .. barIndex
    if _G[frameName] then
        return consumerFn and consumerFn(_G[frameName])
    end

    local cfg = Profile_Bar_Config
    local cols = cfg.widget.colSize
    local rows = cfg.widget.rowSize
    local size = cfg.widget.buttonSize
    local spacing = lcfg.spacing

    --- @type ActionBarFrame
    local frame = self:CreateBarFrame(barIndex, frameName)
    local buttons = self:CreateButtons(frame, barIndex)
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
function o:CreateBarFrame(barIndex, frameName)
    assert(barIndex and frameName, 'Frame and index missing.')

    --- @type ActionBarFrame
    local f = CreateFrame("Frame", frameName, UIParent, "ABPV2_BarFrameTemplate_V2_1_1")
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

    f:Show()

    return f
end

local function btnName(barIndex, btnIndex)
    return ('ActionbarPlusV2F%sButton%s'):format(barIndex, btnIndex)
end

--- @param barIndex Index
--- @param barFrame ActionBarFrame
function o:CreateButtons(barFrame, barIndex)
    --local cfg = P:GetBar(barIndex)
    local cfg = Profile_Bar_Config
    local btnSize = cfg.widget.buttonSize
    local cols = cfg.widget.colSize
    local rows = cfg.widget.rowSize
    local btnCount = rows * cols
    p('xx CreateButtons::btnCount:', btnCount)

    local buttons = {}
    for i = 1, btnCount do
        local btnName = btnName(barIndex, i)
        --- @type CheckButton
        local btn = CreateFrame("CheckButton", btnName, barFrame,
                                "ABP_ButtonTemplate_V2_1_1")
        btn:SetSize(btnSize, btnSize)
        table.insert(buttons, btn)
    end
    barFrame.buttons = buttons
    return buttons
end

--[[--- @type BarFactoryConsumerFn
o:RegisterMessage(MSG.OnAddOnReady, function()
    if not ActionbarPlusF2Module then return end

    --- @type CheckButton
    local btn = ActionbarPlusF2Module.barFrame.buttons[1]
    local spName = 'Healing Touch'
    local texture = select(3, GetSpellInfo(spName))
    p:vv(function() return 'xx Icon[%s]: %s', i, texture end)
    --btn.NormalTexture:Hide()
    btn.icon:SetTexture(texture)
    btn.icon:SetAllPoints(btn)
    btn:SetAttribute('type', 'spell')
    btn:SetAttribute('spell', spName)
end)]]


C_Timer.After(1, function()
    o:Init()
end)

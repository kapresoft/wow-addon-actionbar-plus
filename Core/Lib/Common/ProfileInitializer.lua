--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format = string.format

 --[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFromMixins = CreateFromMixins

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub
local ConfigNames = GC.Profile_Config_Names

local ATTR, Table = GC.WidgetAttributes, O.Table
local isNotTable, shallow_copy, tinsert = Table.isNotTable, Table.shallow_copy, table.insert

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

--- @class ProfileInitializer : BaseLibraryObject_Initialized
local L = LibStub:NewLibrary(M.ProfileInitializer); if not L then return end
local p = L:GetLogger()
-- todo next deprecate P.baseFrameName
L.baseFrameName = GC.C.BASE_FRAME_NAME

local ACTION_BAR_COUNT = 10
L.ActionbarCount = ACTION_BAR_COUNT

--[[-----------------------------------------------------------------------------
Interface Definitions
-------------------------------------------------------------------------------]]
---FrameDetails is used for initializing defaults for AceDB profile
--- @type table<number, ActionbarInitialSettings>
local ActionbarInitialSettings = {
    [1] = { rowSize = 2, colSize = 6, enable = true },
    [2] = { rowSize = 2, colSize = 6, enable = true },
}
--- @type ActionbarInitialSettings
local ActionbarInitialSettingsDefault = {
    ['enable'] = false,
    ['rowSize'] = 2, ['colSize'] = 5,
    ['frame_handle_mouseover'] = true
}

---@param index number
local function GetActionbarInitialSettings(index)
    local initS = ActionbarInitialSettings[index]
    local d = ActionbarInitialSettingsDefault
    if not initS then
        initS = CreateFromMixins(ActionbarInitialSettingsDefault)
    end
    -- fallback values
    initS.enable = initS.enable or false
    initS.rowSize = initS.rowSize or 2
    initS.colSize = initS.colSize or 5
    initS.frame_handle_mouseover = initS.frame_handle_mouseover or true
    return initS
end

local ButtonDataTemplate = {
    [ATTR.TYPE] = ATTR.SPELL,
    [ATTR.SPELL] = {},
    [ATTR.ITEM] = {},
    [ATTR.MACRO] = {},
    [ATTR.MACRO_TEXT] = {},
    [ATTR.MOUNT] = {},
}

--- @type Profile_Bar_Widget
local defaultWidget = {
    [ConfigNames.rowSize] = 2,
    [ConfigNames.colSize] = 6,
    [ConfigNames.buttonSize] = 35,
    [ConfigNames.alpha] = 0.5,
    [ConfigNames.show_empty_buttons] = true,
    [ConfigNames.frame_handle_mouseover] = false,
    [ConfigNames.frame_handle_alpha] = 1.0,
}

--- @return _RegionAnchor
---@param x number
---@param y number
---@param point RegionPointString Optional
---@param relativePoint RegionPointString Optional
local function CreateDefaultAnchor(x, y, point, relativePoint)
    local p = point or 'TOPLEFT'
    local rp = relativePoint or 'TOPLEFT'
    return { point=p, relativePoint=rp, x=x, y=y, relativeTo=nil }
end

local function CreateActionBarConfig()
    --- @type Profile_Bar
    local barConf = {
        [ConfigNames.show_keybind_text] = false,
        [ConfigNames.show_button_index] = false,
        [ConfigNames.widget] = CreateFromMixins(defaultWidget),
        [ConfigNames.anchor] = {},
        [ConfigNames.buttons] = {},
    }
    return barConf
end

---The defaults provided here will used for the default state of the settings
--- @type Profile_Config
local DEFAULT_PROFILE_DATA = {
    [ConfigNames.character_specific_anchors] = false,
    [ConfigNames.hide_when_taxi] = true,
    [ConfigNames.action_button_mouseover_glow] = true,
    [ConfigNames.hide_text_on_small_buttons] = false,
    [ConfigNames.hide_countdown_numbers] = false,
    [ConfigNames.tooltip_visibility_key] = '',
    [ConfigNames.tooltip_visibility_combat_override_key] = '',
    [ConfigNames.tooltip_anchor_type] = GC.TooltipAnchor.CURSOR_TOPLEFT,
    [ConfigNames.bars] = {},
}
--- @alias LayoutStrategyFn fun(index:number, barConf:Profile_Bar, context:LayoutStrategyContext)

--- @type LayoutStrategyFn
local LayoutFirstTwoTopLeft = function(frameIndex, barConfig, context)
    local x = context.xIncr:get()
    local y = context.yIncr:get()
    if frameIndex == 2 then x = context.xIncr:next() end
    barConfig.anchor = CreateDefaultAnchor(x, y, 'TOPLEFT', 'TOPLEFT')
end

--- First 2 at TOPLEFT, then remaining 2x3 at CENTER
--- @type LayoutStrategyFn
local DefaultLayoutStrategy = function(frameIndex, barConfig, context)
    local xIncrFirstTwo = ns:CreateIncrementer(30, 220)
    local yIncrFirstTwo = ns:CreateIncrementer(-110, -90)

    if frameIndex <= 2 then
        LayoutFirstTwoTopLeft(frameIndex, barConfig, { xIncr = xIncrFirstTwo, yIncr = yIncrFirstTwo })
        return
    end
    local x,y = context.xIncr:get(), context.yIncr:get()
    if frameIndex > 3 then
        --x = x + 200
        x = context.xIncr:next()
        if math.fmod(frameIndex, 3) == 0 then
            --x = -200
            --y = y - 80
            x = context.xIncr:reset()
            y = context.yIncr:next()
        end
    end
    barConfig.anchor = CreateDefaultAnchor(x, y, 'CENTER', 'CENTER')
end

--- @class LayoutStrategyContext
local _LayoutStrategyContext = {
    --- @type Kapresoft_LibUtil_Incrementer
    xIncr = {},
    --- @type Kapresoft_LibUtil_Incrementer
    yIncr = {},
}

--- @param layoutStrategyFn LayoutStrategyFn
local function ApplyLayoutStrategy(layoutStrategyFn)
    local xIncr = ns:CreateIncrementer(-200, 190)
    local yIncr = ns:CreateIncrementer(100, -80)

    --- @type Profile_Bar
    local bars = DEFAULT_PROFILE_DATA[ConfigNames.bars]
    for i = 1, ACTION_BAR_COUNT do
        local barName = GC:GetFrameName(i)
        local barConf = bars[barName]
        layoutStrategyFn(i, barConf, { xIncr = xIncr, yIncr = yIncr })
    end
end

for i = 1, ACTION_BAR_COUNT do
    --- @type Profile_Bar
    local bars = DEFAULT_PROFILE_DATA[ConfigNames.bars]
    local name = GC:GetFrameName(i)
    local barConfig = CreateActionBarConfig(name)
    local init = GetActionbarInitialSettings(i)

    barConfig[ConfigNames.enabled] = init.enable
    barConfig.widget[ConfigNames.rowSize] = init.rowSize
    barConfig.widget[ConfigNames.colSize] = init.colSize
    barConfig.widget[ConfigNames.frame_handle_mouseover] = init.frame_handle_mouseover
    bars[name] = barConfig
end

ApplyLayoutStrategy(DefaultLayoutStrategy)

--- @param frameIndex number
function L:GetFrameNameByIndex(frameIndex)
    assert(type(frameIndex) == 'number',
            'GetFrameNameByIndex(..)| frameIndex should be a number')
    return L.baseFrameName .. tostring(frameIndex)
end

--- @param g Profile_Global_Config
function L:InitGlobalSettings(g)
    g.bars = {}
    for frameIndex=1, ACTION_BAR_COUNT do
        local fn = L:GetFrameNameByIndex(frameIndex)
        self:InitGlobalButtonConfig(g, fn)
    end
end

--- @param g Profile_Global_Config
--- @param frameName string
function L:InitGlobalButtonConfig(g, frameName)
    g.bars[frameName] = { }
    self:InitGlobalButtonConfigAnchor(g, frameName)
    return g.bars[frameName]
end

--- @param g Profile_Global_Config
--- @param frameName string
function L:InitGlobalButtonConfigAnchor(g, frameName)
    local defaultBars = DEFAULT_PROFILE_DATA.bars
    --- @type Global_Profile_Bar
    local btnConf = g.bars[frameName]
    btnConf.anchor = Table.shallow_copy(defaultBars[frameName].anchor)
    return btnConf.anchor
end

function L:GetAllActionBarSizeDetails() return ActionbarInitialSettings end

local function CreateNewProfile() return CreateFromMixins(DEFAULT_PROFILE_DATA) end

function L:InitNewProfile()
    local profile = CreateNewProfile()
    -- todo next Figure out whether it is safe to not initialize these fields
    for i=1, #ActionbarInitialSettings do
        self:InitializeActionbar(profile, i)
    end
    return profile
end

function L:InitializeActionbar(profile, barIndex)
    local barName = 'ActionbarPlusF' .. barIndex
    local frameSpec = ActionbarInitialSettings[barIndex]
    local btnCount = frameSpec.colSize * frameSpec.rowSize
    for btnIndex=1,btnCount do
        self:InitializeButtons(profile, barName, btnIndex)
    end
end

function L:InitializeButtons(profile, barName, btnIndex)
    local btnName = format('%sButton%s', barName, btnIndex)
    local btn = self:CreateSingleButtonTemplate()
    profile.bars[barName].buttons[btnName] = btn
end

function L:CreateSingleButtonTemplate()
    local b = ButtonDataTemplate
    local keys = { ATTR.SPELL, ATTR.ITEM, ATTR.MACRO, ATTR.MACRO_TEXT }
    for _,k in ipairs(keys) do
        if isNotTable(b[k]) then b[k] = {} end
    end
    return b
end

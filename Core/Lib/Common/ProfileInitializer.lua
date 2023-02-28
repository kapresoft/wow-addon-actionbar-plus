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

--[[-----------------------------------------------------------------------------
Instance Properties
-------------------------------------------------------------------------------]]
-- todo next deprecate P.baseFrameName
L.baseFrameName = GC.C.BASE_FRAME_NAME

local ACTION_BAR_COUNT = 10
L.ActionbarCount = ACTION_BAR_COUNT
--- For new profile creation, this is the default visiblity state
L.ActionbarEnableByDefault = false

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

---The defaults provided here will used for the default state of the settings
--- @type Profile_Config
local DEFAULT_PROFILE_DATA = {
    [ConfigNames.character_specific_anchors] = true,
    [ConfigNames.hide_when_taxi] = true,
    [ConfigNames.action_button_mouseover_glow] = true,
    [ConfigNames.hide_text_on_small_buttons] = false,
    [ConfigNames.hide_countdown_numbers] = false,
    [ConfigNames.tooltip_visibility_key] = '',
    [ConfigNames.tooltip_visibility_combat_override_key] = '',
    [ConfigNames.tooltip_anchor_type] = GC.TooltipAnchor.CURSOR_TOPLEFT,
    [ConfigNames.equipmentset_open_character_frame] = true,
    [ConfigNames.equipmentset_open_equipment_manager] = true,
    [ConfigNames.equipmentset_show_glow_when_active] = true,
    [ConfigNames.bars] = {},
}

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param index number
local function GetActionbarInitialSettings(index)
    local initS = ActionbarInitialSettings[index]
    if not initS then initS = CreateFromMixins(ActionbarInitialSettingsDefault) end
    -- fallback values
    initS.enable = initS.enable or L.ActionbarEnableByDefault
    initS.rowSize = initS.rowSize or 2
    initS.colSize = initS.colSize or 5
    initS.frame_handle_mouseover = initS.frame_handle_mouseover or true
    return initS
end

--- @return _RegionAnchor
--- @param x number
--- @param y number
--- @param point RegionPointString Optional
--- @param relativePoint RegionPointString Optional
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

local function InitDefaultProfileData()
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
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o ProfileInitializer
local function Methods(o)
    --- @param frameIndex number
    function o:GetFrameNameByIndex(frameIndex)
        assert(type(frameIndex) == 'number',
                'GetFrameNameByIndex(..)| frameIndex should be a number')
        return o.baseFrameName .. tostring(frameIndex)
    end

    --- @param g Profile_Global_Config
    function o:InitGlobalSettings(g)
        g.bars = {}
        for frameIndex=1, ACTION_BAR_COUNT do
            local fn = o:GetFrameNameByIndex(frameIndex)
            self:InitGlobalButtonConfig(g, fn)
        end
    end

    --- @param g Profile_Global_Config
    --- @param frameName string
    function o:InitGlobalButtonConfig(g, frameName)
        g.bars[frameName] = { }
        self:InitGlobalButtonConfigAnchor(g, frameName)
        return g.bars[frameName]
    end

    --- @param g Profile_Global_Config
    --- @param frameName string
    function o:InitGlobalButtonConfigAnchor(g, frameName)
        local defaultBars = DEFAULT_PROFILE_DATA.bars
        --- @type Global_Profile_Bar
        local btnConf = g.bars[frameName]
        btnConf.anchor = Table.shallow_copy(defaultBars[frameName].anchor)
        return btnConf.anchor
    end

    function o:InitNewProfile()
        local profile = CreateFromMixins(DEFAULT_PROFILE_DATA)
        for name, config in pairs(DEFAULT_PROFILE_DATA.bars) do
            self:InitializeActionbar(profile, name, config)
        end
        P = profile
        return profile
    end

    ---@param barName string
    ---@param barConf Profile_Bar
    function o:InitializeActionbar(profile, barName, barConf)
        local widgetConf = barConf.widget
        local btnCount = widgetConf.colSize * widgetConf.rowSize
        for btnIndex=1,btnCount do
            self:InitializeButtons(profile, barName, barConf, btnIndex)
        end
    end

    ---@param barName string
    ---@param barConf Profile_Bar
    function o:InitializeButtons(profile, barName, barConf, btnIndex)
        local btnName = format('%sButton%s', barName, btnIndex)
        local btn = self:CreateSingleButtonTemplate()
        barConf.buttons[btnName] = btn
    end

    function o:CreateSingleButtonTemplate()
        local b = ButtonDataTemplate
        local keys = { ATTR.SPELL, ATTR.ITEM, ATTR.MACRO, ATTR.MACRO_TEXT }
        for _,k in ipairs(keys) do
            if isNotTable(b[k]) then b[k] = {} end
        end
        return b
    end
end

Methods(L)

--[[-----------------------------------------------------------------------------
Initializer
-------------------------------------------------------------------------------]]
InitDefaultProfileData()

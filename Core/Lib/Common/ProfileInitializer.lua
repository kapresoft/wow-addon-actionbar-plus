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
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local ConfigNames = GC.Profile_Config_Names
local ATTR, Table = GC.WidgetAttributes, ns:Table()
local shallow_copy = Table.shallow_copy

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class ProfileInitializer : BaseLibraryObject_Initialized
local L = LibStub:NewLibrary(M.ProfileInitializer); if not L then return end
local p = ns:LC().PROFILE:NewLogger(M.ProfileInitializer)

--[[-----------------------------------------------------------------------------
Instance Properties
-------------------------------------------------------------------------------]]
-- todo next deprecate P.baseFrameName
L.baseFrameName = GC.C.BASE_FRAME_NAME

--- This is the hard limit
local ACTION_BAR_COUNT = 10

--- The additional rows and cols settings are so that the Profile Defaults will create more row data
--- Having additional row data for profile template means that empty button profiles will
--- be cleaned up more and does not clutter the user conf.
--- WARNING: This will increase addon memory usage
local DEFAULT_PROFILE_ADDITIONAL_ROWS_AND_COLS = 5

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

--- @type Profile_Button
local ButtonDataTemplate = {
    [ATTR.TYPE] = '',
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
--- @param index number
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

--- This function initializes the DEFAULT_PROFILE_DATA var
--- to populate the default Profile Data
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
--- @param o ProfileInitializer
local function Methods(o)

    --- @param g Profile_Global_Config
    function o:InitGlobalSettings(g)
        g.bars = {}
        for frameIndex=1, ACTION_BAR_COUNT do
            local fn = GC:GetFrameName(frameIndex)
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
        btnConf.anchor = shallow_copy(defaultBars[frameName].anchor)
        return btnConf.anchor
    end

    --- DEFAULT_PROFILE_DATA is initialized in #InitDefaultProfileData()
    --- @return Profile_Config
    function o:InitNewProfile()
        --- @type Profile_Config
        local profile = CreateFromMixins(DEFAULT_PROFILE_DATA)
        for i=1, ACTION_BAR_COUNT do
            local barName = GC:GetFrameName(i)
            local barConf = profile.bars[barName]
            self:InitializeActionbar(profile, barName, barConf)

        end
        return profile
    end

    --- @param profile Profile_Config
    --- @param barName string
    --- @param barConf Profile_Bar
    function o:InitializeActionbar(profile, barName, barConf)
        local widgetConf = barConf.widget
        local colSize = widgetConf.colSize + DEFAULT_PROFILE_ADDITIONAL_ROWS_AND_COLS
        local rowSize = widgetConf.rowSize + DEFAULT_PROFILE_ADDITIONAL_ROWS_AND_COLS
        local btnCount = colSize * rowSize
        for btnIndex=1,btnCount do
            self:InitializeButtons(profile, barName, barConf, btnIndex)
        end
    end

    --- @param profile Profile_Config
    --- @param barName string
    --- @param barConf Profile_Bar
    --- @param btnIndex Index
    function o:InitializeButtons(profile, barName, barConf, btnIndex)
        local btnName = format('%sButton%s', barName, btnIndex)
        barConf.buttons[btnName] = self:CreateSingleButtonTemplate()
    end

    --- @return Profile_Button
    function o:CreateSingleButtonTemplate() return CreateFromMixins(ButtonDataTemplate) end
end

Methods(L)

--[[-----------------------------------------------------------------------------
Initializer
-------------------------------------------------------------------------------]]
InitDefaultProfileData()

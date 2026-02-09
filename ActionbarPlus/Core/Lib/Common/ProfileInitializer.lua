--- @alias BarConfNameSupplierFn fun(barIndex:Index) : Name
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
local Compat = O.Compat

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
    ["spec2Init"] = 0,
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
    [ConfigNames.tooltip_visibility_key] = GC.TooltipKeyName.SHIFT,
    [ConfigNames.tooltip_visibility_combat_override_key] = GC.TooltipKeyName.SHIFT,
    [ConfigNames.tooltip_anchor_type] = GC.TooltipAnchor.CURSOR_TOPLEFT,
    [ConfigNames.equipmentset_open_character_frame] = true,
    [ConfigNames.equipmentset_open_equipment_manager] = true,
    [ConfigNames.equipmentset_show_glow_when_active] = true,
    [ConfigNames.spec2_init] = nil,
    [ConfigNames.bars] = {},
}

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param index number
--- @return ActionbarInitialSettings
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
        [ConfigNames.show_keybind_text] = true,
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

--- This function initializes the DEFAULT_PROFILE_DATA var
--- to populate the default Profile Data
--- @param barConfNameSupplierFn BarConfNameSupplierFn | "function(barIndex) return 'barName' end"
local function InitDefaultProfileData(barConfNameSupplierFn)
    local xIncr = ns:CreateIncrementer(-200, 190)
    local yIncr = ns:CreateIncrementer(100, -80)
    local layoutStrategyFn = DefaultLayoutStrategy

    for i = 1, ACTION_BAR_COUNT do
        --- @type Profile_Bar
        local bars = DEFAULT_PROFILE_DATA[ConfigNames.bars]
        local name = barConfNameSupplierFn(i)
        local barConfig = CreateActionBarConfig(name)
        local init = GetActionbarInitialSettings(i)

        barConfig[ConfigNames.enabled] = init.enable
        barConfig.widget[ConfigNames.rowSize] = init.rowSize
        barConfig.widget[ConfigNames.colSize] = init.colSize
        barConfig.widget[ConfigNames.frame_handle_mouseover] = init.frame_handle_mouseover
        bars[name] = barConfig

        layoutStrategyFn(i, barConfig, { xIncr = xIncr, yIncr = yIncr })
    end

end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o ProfileInitializer
local function Methods(o)

    local specCount = ns:IsRetail() and 4 or 2

    --- @param g Global_Profile_Config
    --- @param barConfNameSupplierFn BarConfNameSupplierFn | "function(barIndex) return 'barName' end"
    function o:InitGlobalSettings(g, barConfNameSupplierFn)
        g.bars = {}
        for frameIndex=1, ACTION_BAR_COUNT do
            local globalBarConf = barConfNameSupplierFn(frameIndex)
            self:InitGlobalButtonConfig(g, globalBarConf)
        end
    end

    --- @param g Global_Profile_Config
    --- @param barConfName Name
    function o:InitGlobalButtonConfig(g, barConfName)
        g.bars[barConfName] = { }
        self:InitGlobalButtonConfigAnchor(g, barConfName)
        return g.bars[barConfName]
    end

    --- @param g Global_Profile_Config
    --- @param barConfName string
    function o:InitGlobalButtonConfigAnchor(g, barConfName)
        local defaultBars = DEFAULT_PROFILE_DATA.bars
        --- @type Global_Profile_Bar
        local btnConf = g.bars[barConfName]
        btnConf.anchor = shallow_copy(defaultBars[barConfName].anchor)
        return btnConf.anchor
    end

    --- DEFAULT_PROFILE_DATA is initialized in #InitDefaultProfileData()
    --- @param barConfNameSupplierFn BarConfNameSupplierFn | "function(barIndex) return 'barName' end"
    --- @see Profile#CreateDefaultProfile This is called by Profile
    --- @return Profile_Config
    function o:InitNewProfile(barConfNameSupplierFn)
        InitDefaultProfileData(barConfNameSupplierFn)

        --- @type Profile_Config
        local profile = CreateFromMixins(DEFAULT_PROFILE_DATA)
        for i=1, ACTION_BAR_COUNT do
            local barName = barConfNameSupplierFn(i)
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

    --- Note that Talent functions are not yet available in this method.
    ---
    --- This helps cleanup unused buttons if applied properly.
    --- If there are no changes in the button conf, it will not be
    --- saved in the ActionbarPlus.lua profile file.
    --- @param profile Profile_Config
    --- @param barName string
    --- @param barConf Profile_Bar
    --- @param btnIndex Index
    function o:InitializeButtons(profile, barName, barConf, btnIndex)
        local btnName = format('%sButton%s', barName, btnIndex)
        barConf.buttons[btnName] = self:CreateSingleButtonTemplate()
        for specId = 2, specCount do
            local btnConfName = ns:GetSpecConfigName(btnIndex, specId)
            barConf.buttons[btnConfName] = self:CreateSingleButtonTemplate()
        end
    end

    --- @return Profile_Button
    function o:CreateSingleButtonTemplate() return CreateFromMixins(ButtonDataTemplate) end
end

Methods(L)


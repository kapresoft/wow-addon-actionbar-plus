--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = ABP_Namespace()
local LibStub, Core, O = ns.O.LibStub, ns.Core, ns.O

local GC = O.GlobalConstants
local ATTR, Table = GC.WidgetAttributes, O.Table
local isNotTable, shallow_copy = Table.isNotTable, Table.shallow_copy

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

--- @class ProfileInitializer : BaseLibraryObject_Initialized
local P = LibStub:NewLibrary(Core.M.ProfileInitializer)
if not P then return end

local p = P:GetLogger()
P.baseFrameName = 'ActionbarPlusF'

--[[-----------------------------------------------------------------------------
Interface Definitions
-------------------------------------------------------------------------------]]
---FrameDetails is used for initializing defaults for AceDB profile
local FrameDetails = {
    [1] = { rowSize = 2, colSize = 6 },
    [2] = { rowSize = 6, colSize = 2 },
    [3] = { rowSize = 3, colSize = 5 },
    [4] = { rowSize = 2, colSize = 6 },
    [5] = { rowSize = 2, colSize = 6 },
    [6] = { rowSize = 2, colSize = 6 },
    [7] = { rowSize = 2, colSize = 6 },
    [8] = { rowSize = 4, colSize = 6 },
}

local ButtonDataTemplate = {
    [ATTR.TYPE] = ATTR.SPELL,
    [ATTR.SPELL] = {},
    [ATTR.ITEM] = {},
    [ATTR.MACRO] = {},
    [ATTR.MACRO_TEXT] = {},
    [ATTR.MOUNT] = {},
}
local EnabledBars = {
    ["ActionbarPlusF1"] = true,
    ["ActionbarPlusF2"] = true,
}

local ConfigNames = GC.Profile_Config_Names

local xIncr = ns:CreateIncrementer(30, 220)
local yIncr = ns:CreateIncrementer(-130, -90)
local defaultWidget = {
    ["rowSize"] = 2, ["colSize"] = 6, ["buttonSize"] = 35,
    ["alpha"] = 0.5, ["show_empty_buttons"] = true,
    ["frame_handle_mouseover"] = false,
    ["frame_handle_alpha"] = 1.0,
}
---The defaults provided here will used for the default state of the settings
--- @type Profile_Config
local DEFAULT_PROFILE_DATA = {
    --- @deprecated lock_actionbars is no longer used
    [ConfigNames.lock_actionbars] = false,
    [ConfigNames.character_specific_anchors] = false,
    [ConfigNames.hide_when_taxi] = true,
    [ConfigNames.action_button_mouseover_glow] = true,
    [ConfigNames.hide_text_on_small_buttons] = false,
    [ConfigNames.hide_countdown_numbers] = false,
    [ConfigNames.tooltip_visibility_key] = '',
    [ConfigNames.tooltip_visibility_combat_override_key] = '',
    [ConfigNames.tooltip_anchor_type] = GC.TooltipAnchor.CURSOR_TOPLEFT,
    [ConfigNames.bars] = {
        ["ActionbarPlusF1"] = {
            ["enabled"] = EnabledBars["ActionbarPlusF1"] or false,
            ["show_keybind_text"] = false,
            ["show_button_index"] = false,
            ["widget"] = Table.shallow_copy(defaultWidget),
            --- @type _RegionAnchor
            ["anchor"] = {
                point="TOPLEFT", relativeTo=nil, relativePoint='TOPLEFT', x=xIncr:get(), y=yIncr:get()
            },
            ["buttons"] = {
                ["ActionbarPlusF1Button1"] = {
                    ["type"] = "spell",
                    ["spell"] = {
                        ["minRange"] = 0,
                        ["id"] = 6603,
                        ["label"] = "Attack",
                        ["name"] = "Attack",
                        ["castTime"] = 0,
                        ["maxRange"] = 0,
                        ["link"] = "|cff71d5ff|Hspell:6603:0|h[Attack]|h|r",
                        ["icon"] = 135641,
                        ["rank"] = "",
                    },
                }
            },
        },
        ["ActionbarPlusF2"] = {
            ["enabled"] = EnabledBars["ActionbarPlusF2"] or false,
            ["show_keybind_text"] = false,
            ["show_button_index"] = false,
            ["widget"] = Table.shallow_copy(defaultWidget),
            --- @type _RegionAnchor
            ["anchor"] = {
                point="TOPLEFT", relativeTo=nil, relativePoint='TOPLEFT', x=xIncr:next(), y=yIncr:get()
            },
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF3"] = {
            ["enabled"] = EnabledBars["ActionbarPlusF3"] or false,
            ["show_keybind_text"] = false,
            ["show_button_index"] = false,
            ["widget"] = Table.shallow_copy(defaultWidget),
            --- @type _RegionAnchor
            ["anchor"] = {
                point="TOPLEFT", relativeTo=nil, relativePoint='TOPLEFT', x=xIncr:next(), y=yIncr:get()
            },
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF4"] = {
            ["enabled"] = EnabledBars["ActionbarPlusF4"] or false,
            ["show_keybind_text"] = false,
            ["show_button_index"] = false,
            ["widget"] = Table.shallow_copy(defaultWidget),
            --- @type _RegionAnchor
            ["anchor"] = {
                point="TOPLEFT", relativeTo=nil, relativePoint='TOPLEFT', x=xIncr:next(), y=yIncr:get()
            },
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF5"] = {
            ["enabled"] = EnabledBars["ActionbarPlusF5"] or false,
            ["show_keybind_text"] = false,
            ["show_button_index"] = false,
            ["widget"] = Table.shallow_copy(defaultWidget),
            --- @type _RegionAnchor
            ["anchor"] = {
                point="TOPLEFT", relativeTo=nil, relativePoint='TOPLEFT', x=xIncr:reset(), y=yIncr:next()
            },
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF6"] = {
            ["enabled"] = EnabledBars["ActionbarPlusF6"] or false,
            ["show_keybind_text"] = false,
            ["show_button_index"] = false,
            ["widget"] = Table.shallow_copy(defaultWidget),
            --- @type _RegionAnchor
            ["anchor"] = {
                point="TOPLEFT", relativeTo=nil, relativePoint='TOPLEFT', x=xIncr:next(), y=yIncr:get()
            },
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF7"] = {
            ["enabled"] = EnabledBars["ActionbarPlusF7"] or false,
            ["show_keybind_text"] = false,
            ["show_button_index"] = false,
            ["widget"] = Table.shallow_copy(defaultWidget),
            --- @type _RegionAnchor
            ["anchor"] = {
                point="TOPLEFT", relativeTo=nil, relativePoint='TOPLEFT', x=xIncr:next(), y=yIncr:get()
            },
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF8"] = {
            ["enabled"] = EnabledBars["ActionbarPlusF8"] or false,
            ["show_keybind_text"] = false,
            ["show_button_index"] = false,
            ["widget"] = Table.shallow_copy(defaultWidget),
            --- @type _RegionAnchor
            ["anchor"] = {
                point="TOPLEFT", relativeTo=nil, relativePoint='TOPLEFT', x=xIncr:next(), y=yIncr:get()
            },
            ["buttons"] = {
            },
        },
    },
}

--- @param frameIndex number
function P:GetFrameNameByIndex(frameIndex)
    assert(type(frameIndex) == 'number',
            'GetFrameNameByIndex(..)| frameIndex should be a number')
    return P.baseFrameName .. tostring(frameIndex)
end

--- @param g Profile_Global_Config
function P:InitGlobalSettings(g)
    g.bars = {}

    for frameIndex=1, #FrameDetails do
        local fn = P:GetFrameNameByIndex(frameIndex)
        self:InitGlobalButtonConfig(g, fn)
    end

end

--- @param g Profile_Global_Config
--- @param frameName string
function P:InitGlobalButtonConfig(g, frameName)
    g.bars[frameName] = { }
    self:InitGlobalButtonConfigAnchor(g, frameName)
    return g.bars[frameName]
end

--- @param g Profile_Global_Config
--- @param frameName string
function P:InitGlobalButtonConfigAnchor(g, frameName)
    local defaultBars = DEFAULT_PROFILE_DATA.bars
    --- @type Global_Profile_Bar
    local btnConf = g.bars[frameName]
    btnConf.anchor = Table.shallow_copy(defaultBars[frameName].anchor)
    return btnConf.anchor
end

function P:GetAllActionBarSizeDetails() return FrameDetails end

local function CreateNewProfile() return shallow_copy(DEFAULT_PROFILE_DATA) end

function P:InitNewProfile()
    local profile = CreateNewProfile()
    for i=1, #FrameDetails do
        self:InitializeActionbar(profile, i)
    end
    return profile
end

function P:InitializeActionbar(profile, barIndex)
    local barName = 'ActionbarPlusF' .. barIndex
    local frameSpec = FrameDetails[barIndex]
    local btnCount = frameSpec.colSize * frameSpec.rowSize
    for btnIndex=1,btnCount do
        self:InitializeButtons(profile, barName, btnIndex)
    end
end

function P:InitializeButtons(profile, barName, btnIndex)
    local btnName = format('%sButton%s', barName, btnIndex)
    local btn = self:CreateSingleButtonTemplate()
    profile.bars[barName].buttons[btnName] = btn
end

function P:CreateSingleButtonTemplate()
    local b = ButtonDataTemplate
    local keys = { ATTR.SPELL, ATTR.ITEM, ATTR.MACRO, ATTR.MACRO_TEXT }
    for _,k in ipairs(keys) do
        if isNotTable(b[k]) then b[k] = {} end
    end
    return b
end

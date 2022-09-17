--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local format = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local O, Core, LibStub = __K_Core:LibPack_GlobalObjects()
local ATTR, Table = O.CommonConstants.WidgetAttributes, O.Table
local isNotTable, shallow_copy = Table.isNotTable, Table.shallow_copy

-- ## Functions ------------------------------------------------

---@class ProfileInitializer
local P = LibStub:NewLibrary(Core.M.ProfileInitializer)

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
}

local SPELL_TEMPLATE = {
    spell = {
        castTime = 3000,
        icon = 132803,
        id = 27090,
        label = 'Conjure Water (Rank 9)',
        link = '[Conjure Water]',
        maxRange = 0,
        minRange = 0,
        name = 'Conjure Water',
        rank = 'Rank 9'
    }
}

local ITEM_TEMPLATE = {
    item = {
        id = 20857,
        name = 'Honey Bread',
        icon = 133964,
        link = '[Honey Bread]',
    }
}

local DEFAULT_PROFILE_DATA = {
    ["lock_actionbars"] = false,
    ["hide_when_taxi"] = true,
    ["tooltip_visibility_key"] = '',
    ["tooltip_visibility_combat_override_key"] = '',
    ["bars"] = {
        ["ActionbarPlusF1"] = {
            ["enabled"] = true,
            ["widget"] = { ["rowSize"] = 2, ["colSize"] = 6, ["buttonSize"] = 35, },
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
            ["enabled"] = true,
            ["widget"] = { ["rowSize"] = 6, ["colSize"] = 2, ["buttonSize"] = 35 },
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF3"] = {
            ["enabled"] = false,
            ["widget"] = { ["rowSize"] = 3, ["colSize"] = 5, ["buttonSize"] = 35 },
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF4"] = {
            ["enabled"] = false,
            ["widget"] = { ["rowSize"] = 2, ["colSize"] = 6, ["buttonSize"] = 35 },
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF5"] = {
            ["enabled"] = false,
            ["widget"] = { ["rowSize"] = 2, ["colSize"] = 6, ["buttonSize"] = 35 },
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF6"] = {
            ["enabled"] = false,
            ["widget"] = { ["rowSize"] = 2, ["colSize"] = 6, ["buttonSize"] = 35 },
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF7"] = {
            ["enabled"] = false,
            ["widget"] = { ["rowSize"] = 2, ["colSize"] = 6, ["buttonSize"] = 35 },
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF8"] = {
            ["enabled"] = false,
            ["widget"] = { ["rowSize"] = 4, ["colSize"] = 6, ["buttonSize"] = 35 },
            ["buttons"] = {
            },
        },
    },
}

function P:GetAllActionBarSizeDetails()
    return FrameDetails
end

local function CreateNewProfile()
    return shallow_copy(DEFAULT_PROFILE_DATA)
end

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

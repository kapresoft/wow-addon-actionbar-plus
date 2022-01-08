local format, tostring, isTable, isNotTable = string.format, tostring, table.isTable, table.isNotTable
local ATTR = WidgetAttributes

local P = {}
ProfileInitializer = P

local FrameDetails = {
    [1] = { rowSize = 2, colSize = 6 },
    [2] = { rowSize = 6, colSize = 2 },
    [3] = { rowSize = 3, colSize = 5 },
    [4] = { rowSize = 2, colSize = 6 },
    [5] = { rowSize = 2, colSize = 6 },
    [6] = { rowSize = 2, colSize = 6 },
    [7] = { rowSize = 2, colSize = 6 },
    [8] = { rowSize = 3, colSize = 6 },
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
        icon = 134134,
        id = 27101,
        label = 'Conjure Mana Emerald',
        link = '[Conjure Mana Emerald]',
        maxRange = 0,
        minRange = 0,
        name = 'Conjure Mana Emerald',
        rank = ''
    }
}

local DEFAULT_PROFILE_DATA = {
    ["bars"] = {
        ["ActionbarPlusF1"] = {
            ["enabled"] = true,
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
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF3"] = {
            ["enabled"] = false,
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF4"] = {
            ["enabled"] = false,
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF5"] = {
            ["enabled"] = false,
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF6"] = {
            ["enabled"] = false,
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF7"] = {
            ["enabled"] = false,
            ["buttons"] = {
            },
        },
        ["ActionbarPlusF8"] = {
            ["enabled"] = false,
            ["buttons"] = {
            },
        },
    },
}

function P:GetAllActionBarSizeDetails()
    return FrameDetails
end

local function CreateNewProfile()
    return table.shallow_copy(DEFAULT_PROFILE_DATA)
end

function P:InitNewProfile()
    local profile = CreateNewProfile()
    --PrettyPrint.setup({ indent_size = 2, level_width = 120, show_all = true })
    for barName,_  in pairs(profile.bars) do
        self:CreateButtonsTemplate(profile, barName)
    end
    --print('DEFAULT_PROFILE_DATA: ' .. PrettyPrint.pformat(DEFAULT_PROFILE_DATA))
    --print('DEFAULT_PROFILE_DATA: ', table.toStringSorted(DEFAULT_PROFILE_DATA))
    return profile
end

function P:CreateButtonsTemplate(profile, barName)
    local buttons = profile.bars[barName]
    for i=1, #FrameDetails do
        local btnName = format('%sButton%s', barName, tostring(i))
        local btnData = buttons[btnName]
        self:CreateSingleButtonTemplate(profile, barName, btnName)
        buttons[btnName] = btnData
    end
    --print('Buttons: ', table.toStringSorted(buttons))
    --print('Buttons: ', PrettyPrint.pformat(buttons))
    return buttons
end

function P:CreateSingleButtonTemplate(profile, barName, btnName)
    --error(table.toStringSorted(DEFAULT_PROFILE_DATA.bars))
    local buttonsKey = 'buttons'
    local buttons = profile.bars[barName][buttonsKey]
    local btnData = buttons[btnName]
    if isNotTable(btnData) then
        btnData = ButtonDataTemplate
    end
    local keys = { ATTR.SPELL, ATTR.ITEM, ATTR.MACRO, ATTR.MACRO_TEXT }
    for _,k in ipairs(keys) do
        if isNotTable(btnData[k]) then btnData[k] = {} end
    end
    profile.bars[barName][buttonsKey][btnName] = btnData
    --print(format('%s btnData: ', btnName), PrettyPrint.pformat(DEFAULT_PROFILE_DATA.bars[barName][btnName]))
    return b
end




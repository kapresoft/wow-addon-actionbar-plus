local type, pairs, tostring = type, pairs, tostring
local LibStub, M = ABP_LibGlobals:LibPack()
local _, Table = ABP_LibGlobals:LibPackUtils()
local Assert = LibStub(M.Assert)
local CC = ABP_CommonConstants
local BAttr = CC.ButtonAttributes
local WAttr = CC.WidgetAttributes

local isTable, isNotTable, tsize, tinsert, tsort
    = Table.isTable, Table.isNotTable, Table.size, table.insert, table.sort
local AssertThatMethodArgIsNotNil = Assert.AssertThatMethodArgIsNotNil
local ProfileInitializer = LibStub(M.ProfileInitializer)

local ActionType = { WAttr.SPELL, WAttr.ITEM, WAttr.MACRO, WAttr.MACRO_TEXT }

---@class Profile
local P = LibStub:NewLibrary(M.Profile)
if not P then return end

---- ## Start Here ----

local SingleBarTemplate = {
    enabled = false,
    buttons = {}
}

local ProfileTemplate = {
    ["bars"] = {
        ["ActionbarPlusF1"] = {
            ["enabled"] = false,
            ["buttons"] = {
                ['ActionbarPlusF1Button1'] = {
                    ['type'] = 'spell',
                    ['spell'] = {
                        -- spellInfo
                    }
                }
            }
        },
        ["ActionbarPlusF2"] = {["enabled"] = false, ["buttons"] = {}},
        ["ActionbarPlusF3"] = {["enabled"] = false, ["buttons"] = {}},
        ["ActionbarPlusF4"] = {["enabled"] = false, ["buttons"] = {}},
        ["ActionbarPlusF5"] = {["enabled"] = false, ["buttons"] = {}},
        ["ActionbarPlusF6"] = {["enabled"] = false, ["buttons"] = {}},
        ["ActionbarPlusF7"] = {["enabled"] = false, ["buttons"] = {}},
        ["ActionbarPlusF8"] = {["enabled"] = false, ["buttons"] = {}},
    }
}

---@see API#GetSpellinfo
local ButtonTemplate = { ['type'] = nil, [BAttr.SPELL] = {} }

---- ## Start Here ----

---@class ProfileConfigNames
local ConfigNames = {
    ['lock_actionbars'] = 'lock_actionbars'
}

local SPELL = { id = nil, name = nil, icon = nil, label = nil }
local ITEM = { id = nil, name = nil, icon = nil, label = nil }
local MACRO = { index = nil, name = nil, icon = nil }
local MACROTEXT = { name = nil, icon = nil, body = nil }
local DETAILS = { spell = SPELL, item = ITEM, macro = MACRO, macrotext = MACROTEXT }
local TOOLTIP = { text = nil, link = nil }
local BUTTON = { type = nil, name = nil, icon = nil, macrotext = nil, tooltip = TOOLTIP, details = DETAILS }


local function assertProfile(p)
    assert(isTable(p), "profile is not a table")
end

-- Implicit
-- self.adddon = ActionBarPlus
-- self.profile = profile

-- ##########################################################################

local FrameDetails = ProfileInitializer:GetAllActionBarSizeDetails()

-- ##########################################################################

P.maxFrames = 8
P.baseFrameName = 'ActionbarPlusF'

function P:GetFrameConfig()
    return FrameDetails
end

function P:GetFrameConfigByIndex(frameIndex)
    AssertThatMethodArgIsNotNil(frameIndex, 'frameIndex', 'GetFrameConfigByIndex(frameIndex)')
    return FrameDetails[frameIndex]
end

function P:GetTemplate()
    return {
        Button = ButtonTemplate
    }
end

function P:GetButtonData(frameIndex, buttonName)
    local barData = self:GetBar(frameIndex)
    if not barData then return end
    local buttons = barData.buttons
    --if not buttons then return nil end
    local btnData = buttons[buttonName]
    if type(buttons[buttonName]) ~= 'table' then
        buttons[buttonName] = self:GetTemplate()
    end
    return buttons[buttonName]
end

---@param widget ButtonUIWidget
function P:ResetButtonData(widget)
    local btnData = widget:GetConfig()
    for _, a in ipairs(ActionType) do btnData[a] = {} end
    btnData[WAttr.TYPE] = WAttr.SPELL
end

function P:InitDELETEME(newProfile)
    assertProfile(newProfile)

    if type(newProfile.bars) ~= 'table' then
        newProfile.bars = self:CreateBarsTemplate()
    end

    for _,bar in pairs(newProfile.bars) do
        if type(bar['buttons']) ~= 'table' then
            newProfile.bars['buttons'] = {}
        end
    end
end

function P:CreateDefaultProfile(profileName)
    return ProfileInitializer:InitNewProfile(profileName)
end

function P:OnAfterInitialize()
    -- do nothing for now
end

function P:CreateBarsTemplate()
    local bars = {}
    for i=1, self:GetMaxFrames() do
        local frameName = self:GetFrameNameByIndex(i)
        bars[frameName] = {
            enabled = false,
            buttons = {}
        }
    end

    return bars
end

-- /run ABP_Table.toString(Profile:GetBar(1))
function P:GetBar(frameIndex)
    AssertThatMethodArgIsNotNil(frameIndex, 'frameIndex', 'GetBar(frameIndex)')

    if isNotTable(self.profile.bars) then return end
    local frameName = self:GetFrameNameByIndex(frameIndex)
    local bar = self.profile.bars[frameName]
    if isNotTable(bar) then
        self.profile.bars[frameName] = self:CreateBarsTemplate()
        bar = self.profile.bars[frameName]
    end

    return bar
end

function P:GetBars()
    return self.profile.bars
end

function P:GetBarSize()
    local bars = P:GetBars()
    if isNotTable(bars) then return 0 end
    return tsize(bars)
end

function P:SetBarEnabledState(frameIndex, isEnabled)
    local bar = self:GetBar(frameIndex)
    bar.enabled = isEnabled
end

function P:IsBarEnabled(frameIndex)
    local bar = self:GetBar(frameIndex)
    return bar.enabled
end

function P:IsBarIndexEnabled(frameIndex)
    return self:IsBarNameEnabled(self:GetFrameNameByIndex(frameIndex))
end

function P:IsBarNameEnabled(frameName)
    if not self.profile.bars then return false end
    local bar = self.profile.bars[frameName]
    if isNotTable(bar) then return false end
    return bar.enabled
end

function P:GetBaseFrameName() return self.baseFrameName end

function P:GetFrameNameByIndex(frameIndex)
    return self:GetBaseFrameName() .. tostring(frameIndex)
end

function P:GetMaxFrames()
    return #FrameDetails
end

function P:GetAllFrameNames()
    local fnames = {}
    for i=1, self:GetMaxFrames() do
        local fn = self:GetFrameNameByIndex(i)
        tinsert(fnames, fn)
    end
    tsort(fnames)
    return fnames
end

function P:GetButtonsByIndex(frameIndex)

    local barData = self:GetBar(frameIndex)
    if barData then
        return barData.buttons
    end

    return nil
end

local _buttons = {
    spells = {
       ['12345'] = 'Button1',
       ['12345'] = 'Button2'
    },
    items = {},
    macros = {}
}

function P:FindButtonsBySpellById(spellId)
    local buttons = {}
    for barName, bar in pairs(self:GetBars()) do
        for buttonName, button in pairs(bar.buttons) do
            if 'spell' == button.type and button.spell and spellId == button.spell.id then
                buttons[buttonName] = button.spell
            end
        end
    end
    return buttons
end

function P:GetAllActionBarSizeDetails()
    return FrameDetails
end

function P:GetActionBarSizeDetailsByIndex(frameIndex)
    return FrameDetails[frameIndex]
end

---@return boolean True if the action bar is locked
function P:IsLockActionBars()
    return self.profile[ConfigNames.lock_actionbars]
end

---@return ProfileConfigNames
function P:GetConfigNames() return ConfigNames end

local format, type, pairs, ipairs = string.format, type, pairs, ipairs
local isTable, isNotTable, tsize = table.isTable, table.isNotTable, table.size
local tostring, pack, unpack = tostring, table.pack, table.unpackIt
local AssertThatMethodArgIsNotNil = Assert.AssertThatMethodArgIsNotNil

local PU = ProfileUtil
local P = LibFactory:NewAceLib('Profile')
if not P then return end

---- ## Start Here ----

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

function P:Init(newProfile)
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

function P:OnAfterInitialize()
    -- do nothing for now
end

function P:CreateBarsTemplate()
    local bars = {}
    for i=1, PU:GetMaxFrames() do
        local frameName = PU:GetFrameNameFromIndex(i)
        bars[frameName] = {
            enabled = false,
            buttons = {}
        }
    end

    return bars
end

-- /run table.toString(Profile:GetBar(1))
function P:GetBar(frameIndex)
    AssertThatMethodArgIsNotNil(frameIndex, 'frameIndex', 'GetBar(frameIndex)')

    if isNotTable(self.profile.bars) then return end
    local frameName = PU:GetFrameNameFromIndex(frameIndex)
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
    return self:IsBarNameEnabled(PU:GetFrameNameFromIndex(frameIndex))
end

function P:IsBarNameEnabled(frameName)
    local bar = self.profile.bars[frameName]
    if isNotTable(bar) then return false end
    return bar.enabled
end

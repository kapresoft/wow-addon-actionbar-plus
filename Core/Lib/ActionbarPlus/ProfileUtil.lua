local tostring = tostring

-- DELETE ME
local P = {
    maxFrames = 8,
    baseFrameName = 'ActionbarPlusF'
}
ProfileUtil = P

local SingleBarTemplate = {
    enabled = false,
    buttons = {}
}

local ProfileTemplate = {
    ["bars"] = {
        ["ActionbarPlusF1"] = {["buttons"] = {}, ["enabled"] = false},
        ["ActionbarPlusF2"] = {["buttons"] = {}, ["enabled"] = false},
        ["ActionbarPlusF3"] = {["buttons"] = {}, ["enabled"] = false},
        ["ActionbarPlusF4"] = {["buttons"] = {}, ["enabled"] = false},
        ["ActionbarPlusF5"] = {["buttons"] = {}, ["enabled"] = false},
        ["ActionbarPlusF6"] = {["buttons"] = {}, ["enabled"] = false},
        ["ActionbarPlusF7"] = {["buttons"] = {}, ["enabled"] = false},
        ["ActionbarPlusF8"] = {["buttons"] = {}, ["enabled"] = false}
    }
}

function P:GetMaxFrames() return self.maxFrames end
function P:GetBaseFrameName() return self.baseFrameName end

function P:GetFrameNameFromIndex(frameIndex)
    return self:GetBaseFrameName() .. tostring(frameIndex)
end
--[[-----------------------------------------------------------------------------
ActionButton.lua
-------------------------------------------------------------------------------]]

-- WoW APIs
local CreateFrame = CreateFrame

-- Lua APIs
local format = string.format

-- Local APIs
local LibStub, M = ABP_LibGlobals:LibPack()


--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {

}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local function NewInstance()
    --local frame = CreateFrame("Frame", "New AceLib Wow AddonFrame", UIParent)
    --frame:SetScript("OnEvent", OnEvent)
    --frame:RegisterEvent("PLAYER_LOGIN")

    -- profile is injected OnAfterInitialize()
    local properties = {
        addon = nil,
        profile = nil
    }

    ---@class ActionButton
    local _L = LibStub:NewLibrary('ActionbarPlus-ActionButton-1.0', 1)
    _L.mt.__index = properties

    for method, func in pairs(methods) do
        _L[method] = func
    end

    return _L
end

ActionButton = NewInstance()